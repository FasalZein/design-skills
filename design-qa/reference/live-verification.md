# Live Verification Runbook — Gate 12 Commands & Probes

Pass conditions, state/viewport matrices, N-A rules, and the completion criterion live in SKILL.md Gate 12. This file owns the execution: exact commands, probe JavaScript, and evidence.

## Setup

```bash
agent-browser skills get core        # load the CLI workflow reference
AB="agent-browser --session <app>-qa" # ISOLATED session — parallel agents share the default
                                      # instance and will hijack your tabs mid-verification
# resolve the target: project dev/preview command (package.json scripts) or supplied URL
# static single-file builds: file:///absolute/path/index.html works directly
```

Use `$AB` for every command below; `$AB close` when done. Run each Gate 12 session fresh — stale tabs carry console history that pollutes error capture.

## Per-cell loop (every required state × viewport)

Responsive and state logic often runs once at load, so **set the viewport first and navigate fresh for every cell** — resizing an open page is not a valid mobile test. Collect all evidence per cell:

```bash
$AB set viewport 375 812          # BEFORE navigation
$AB open "$URL"                   # fresh navigation for this cell
$AB errors                        # must print nothing
$AB console                       # zero errors; warnings judged
$AB snapshot -i                   # accessibility tree: headings, roles, names
$AB screenshot "$EVIDENCE_DIR/<app>-<state>-375.png"
# then run every probe below (via $AB eval) in this same cell
```

Repeat with `set viewport 1440 900` (and `768 1024` when a tablet breakpoint exists). Failed asset/API requests:

```js
performance.getEntriesByType('resource').filter(r => r.responseStatus >= 400 || (r.responseStatus === 0 && r.duration > 0)).map(r => r.name)
```

## State setup

Drive each required state through the app itself (navigate, filter to zero results, submit invalid input, block the API for error states) or project fixtures. Record how each state was produced — that's the repro step for any finding. A state that should exist but cannot be exposed = failing state check (SKILL.md rule).

Dark mode / reduced motion:

```bash
$AB eval "document.documentElement.classList.add('dark')"   # or the project's toggle
$AB set media --reduced-motion reduce
```

## Machine probes (run via `$AB eval`)

Horizontal overflow (at 375px):

```js
document.documentElement.scrollWidth <= window.innerWidth
```

Heading order — first heading is an h1, exactly one h1, no forward skips:

```js
(() => { const hs=[...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].map(h=>+h.tagName[1]);
  return { startsAtH1: hs[0]===1, oneH1: hs.filter(l=>l===1).length===1,
           noSkip: hs.every((l,i)=>i===0||l<=hs[i-1]+1) }; })()
```

Rendered contrast — normalizes ANY color syntax (oklch/hsl/named) by drawing it to a 1×1 canvas and reading the pixel back (string parsing is unsafe: modern Chromium serializes `fillStyle` in the original color space). Composites alpha over the resolved background, walks up through transparent backgrounds, and applies the correct tier (3:1 for large text = ≥24px or ≥18.66px bold; 4.5:1 otherwise). Placeholders probed explicitly:

```js
(() => {
  const cv = document.createElement('canvas'); cv.width = cv.height = 1;
  const ctx = cv.getContext('2d', { willReadFrequently: true });
  const parse = v => { if (!v) return null;
    ctx.fillStyle = '#123456'; ctx.fillStyle = v;
    if (ctx.fillStyle === '#123456' && v.replace(/\s/g,'').toLowerCase() !== '#123456') return null;
    ctx.clearRect(0,0,1,1); ctx.fillRect(0,0,1,1);
    const d = ctx.getImageData(0,0,1,1).data; return [d[0], d[1], d[2], d[3]/255]; };
  const lum = ([r,g,b]) => { const f = v => { v/=255; return v<=.03928 ? v/12.92 : ((v+.055)/1.055)**2.4 };
    return .2126*f(r)+.7152*f(g)+.0722*f(b); };
  const comp = (fg, bg) => fg[3] >= 1 ? fg : [0,1,2].map(i => fg[i]*fg[3] + bg[i]*(1-fg[3])).concat([1]);
  const bgOf = el => { let acc = null;
    for (let n = el; n; n = n.parentElement) {
      const c = parse(getComputedStyle(n).backgroundColor); if (!c) continue;
      if (c[3] === 0) continue;
      if (acc) return comp(acc, c);            // partial overlay composited over this layer
      if (c[3] >= 1) return c; acc = c;
    } return acc ? comp(acc, [255,255,255,1]) : [255,255,255,1]; };
  const fails = [];
  for (const e of document.querySelectorAll('h1,h2,h3,h4,h5,h6,p,li,td,th,span,label,a,button,dt,dd,figcaption,input,textarea')) {
    const text = e.matches('input,textarea') ? e.placeholder : (e.childNodes.length && [...e.childNodes].some(n=>n.nodeType===3&&n.textContent.trim()) ? e.textContent : '');
    if (!text?.trim() || !e.offsetHeight) continue;
    const st = getComputedStyle(e);
    const fg = parse(e.matches('input,textarea') ? (getComputedStyle(e,'::placeholder').color || st.color) : st.color);
    if (!fg) { fails.push({t:text.slice(0,30), r:'MANUAL — unparseable color'}); continue; }
    const bg = bgOf(e); const c = comp(fg, bg);
    const L1 = lum(c), L2 = lum(bg);
    const r = (Math.max(L1,L2)+.05)/(Math.min(L1,L2)+.05);
    const px = parseFloat(st.fontSize), bold = parseInt(st.fontWeight) >= 700;
    const floor = (px >= 24 || (px >= 18.66 && bold)) ? 3 : 4.5;
    if (r < floor) fails.push({t:text.slice(0,30), r:+r.toFixed(2), need:floor});
  }
  return fails.slice(0,40);
})()
```

Empty array = pass. Any `MANUAL` row means the probe could not measure — check that element in the screenshot, never assume it passed. Text over images/gradients is outside this probe — judge it in screenshot review.

Target size (at 375px) — two buckets: below 24px fails outright (WCAG floor); interactive controls 24–43px are listed for the 44px product-target judgment in screenshot review:

```js
(() => { const els=[...document.querySelectorAll('button,a,[role=button],input,select,[onclick]')]
    .map(e=>({e, r:e.getBoundingClientRect()})).filter(x=>x.r.width>0&&x.r.height>0);
  const name = x => (x.e.textContent?.trim() || x.e.getAttribute('aria-label') || x.e.tagName).slice(0,20);
  return { fail: els.filter(x=>x.r.width<24||x.r.height<24).map(name),
           judge44: els.filter(x=>(x.r.width<44||x.r.height<44)&&x.r.width>=24&&x.r.height>=24).map(name) }; })()
```

`fail` non-empty = probe failure. Every primary control appearing in `judge44` fails the review unless it is a genuinely secondary/inline control.

Dead air (at 1440px) — merges every visible text/visual element into occupied bands, then reports empty bands between them. `fail` = above the Gate 4 limit (+ tolerance); `judge` = large but possibly a declared marketing feature:

```js
(() => { const scrollers=[...document.querySelectorAll('*')].filter(e=>e.scrollHeight>e.clientHeight+50);
  const root=scrollers.sort((a,b)=>b.scrollHeight-a.scrollHeight)[0]||document.documentElement;
  const leaves=[...root.querySelectorAll('*')].filter(e=>{ if(!e.offsetHeight||e.offsetHeight>600) return false;
    return [...e.childNodes].some(n=>n.nodeType===3&&n.textContent.trim())||e.matches('svg,img,canvas,button,input,select'); })
    .map(e=>{const r=e.getBoundingClientRect();return {t:(e.textContent||e.tagName).trim().slice(0,20),top:r.top+root.scrollTop,bottom:r.bottom+root.scrollTop};})
    .sort((a,b)=>a.top-b.top);
  const bands=[]; let cur=null;
  for(const l of leaves){ if(cur&&l.top<=cur.end+4){cur.end=Math.max(cur.end,l.bottom);cur.last=l.t;}
    else{if(cur)bands.push(cur);cur={start:l.top,end:l.bottom,last:l.t};}}
  if(cur)bands.push(cur);
  const marketing = /* set from the declared archetype */ false;
  const FAIL = marketing ? 256 : 128, JUDGE = marketing ? 128 : 64;
  const out={fail:[],judge:[]};
  for(let i=1;i<bands.length;i++){const g=Math.round(bands[i].start-bands[i-1].end);
    if(g>FAIL) out.fail.push({gap:g,after:bands[i-1].last,before:bands[i].last});
    else if(g>JUDGE) out.judge.push({gap:g,after:bands[i-1].last,before:bands[i].last});}
  return out; })()
```

Set `marketing` from the declared archetype before running. `fail` non-empty = probe failure. `judge` rows are section-boundary air on marketing pages (stacked paddings — usually legal) but floating-content bugs inside one continuous surface — check each against the screenshot.

Focus visibility: key-tab through the page and screenshot mid-cycle — every stop shows a visible ring.

Layout shift: screenshot immediately after load and again after network idle; differing layouts = unreserved async space.

## Evidence

Per cell (state × viewport), record: state name, how it was produced, viewport, screenshot path, errors/console/failed-request output, every probe result. Findings carry: gate check, severity, screenshot path, repro steps. Keep artifacts under one directory per run (`design-qa-live/<app>-<state>-<viewport>.png`).
