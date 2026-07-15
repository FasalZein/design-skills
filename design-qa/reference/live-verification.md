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
performance.getEntriesByType('resource')
  .filter(r => r.responseStatus >= 400 || (r.responseStatus === 0 && new URL(r.name, location.href).origin === location.origin))
  .map(r => r.name)
```

Same-origin `responseStatus: 0` = a failed request (connection refused, blocked) even when application code caught it silently. Cross-origin `0` is opaque (no Timing-Allow-Origin), not a failure — verify those by effect instead: `document.fonts.status === 'loaded'` for fonts, `img.complete && img.naturalWidth > 0` for images.

## State setup

Drive each required state through the app itself (navigate, filter to zero results, submit invalid input, block the API for error states) or project fixtures. Record how each state was produced — that's the repro step for any finding. A state that should exist but cannot be exposed = failing state check (SKILL.md rule).

Dark mode / reduced motion:

```bash
$AB eval "document.documentElement.classList.add('dark')"   # or the project's toggle
$AB set media --reduced-motion reduce
```

Verify the emulation took: `$AB eval "matchMedia('(prefers-reduced-motion: reduce)').matches"`. When it reports `false` (known agent-browser gap), the fallback ladder is:

1. Confirm a `@media (prefers-reduced-motion: reduce)` block exists in the source (read the CSS file directly — `document.styleSheets` throws `SecurityError` on `file://` external sheets).
2. Inject the equivalent rules via `eval` and verify their CSS effect (animations/transitions neutralized).
3. JavaScript that branches on `matchMedia` at load time cannot be exercised this way — when the page has such branches, record the reduced-motion probe as `N-A — emulation unavailable, JS branch unverified` with the source evidence. N-A is never a pass; it must appear in the report.

## Machine probes (run via `$AB eval`)

Horizontal overflow (at 375px):

```js
document.documentElement.scrollWidth <= window.innerWidth
```

Heading order — first **visible** heading is an h1, exactly one visible h1, no forward skips (hidden headings don't exist for the accessibility tree):

```js
(() => { const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const hs=[...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].filter(vis).map(h=>+h.tagName[1]);
  return { startsAtH1: hs[0]===1, oneH1: hs.filter(l=>l===1).length===1,
           noSkip: hs.every((l,i)=>i===0||l<=hs[i-1]+1) }; })()
```

Cross-check against `$AB snapshot -i` — the accessibility tree is the authority.

Rendered contrast — normalizes ANY color syntax (oklch/hsl/named) by drawing it to a 1×1 canvas and reading the pixel back (string parsing is unsafe: modern Chromium serializes `fillStyle` in the original color space). Enumerates EVERY element with direct text (no tag allowlist — `<div>` text counts), composites alpha through **all** ancestor layers, probes input borders for the 3:1 non-text floor, and applies the correct text tier (3:1 for ≥24px or ≥18.66px bold; 4.5:1 otherwise):

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
  const over = (top, bot) => { const a = top[3] + bot[3]*(1-top[3]); if (!a) return [0,0,0,0];
    return [0,1,2].map(i => (top[i]*top[3] + bot[i]*bot[3]*(1-top[3]))/a).concat([a]); };
  const bgOf = el => { let acc = [0,0,0,0];
    for (let n = el; n; n = n.parentElement) {
      const c = parse(getComputedStyle(n).backgroundColor); if (!c || c[3] === 0) continue;
      acc = over(acc, c); if (acc[3] >= 0.999) return acc;
    } return over(acc, [255,255,255,1]); };
  const ratio = (a, b) => { const L1 = lum(a), L2 = lum(b); return (Math.max(L1,L2)+.05)/(Math.min(L1,L2)+.05); };
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const fails = [];
  for (const e of document.querySelectorAll('*')) {
    if (!vis(e) || !e.offsetHeight) continue;
    const st = getComputedStyle(e);
    // text (any element with a direct text node; placeholders for inputs)
    const text = e.matches('input,textarea') ? e.placeholder
      : ([...e.childNodes].some(n => n.nodeType === 3 && n.textContent.trim()) ? e.textContent : '');
    if (text?.trim()) {
      const fg = parse(e.matches('input,textarea') ? (getComputedStyle(e,'::placeholder').color || st.color) : st.color);
      if (!fg) fails.push({t:text.slice(0,30), r:'MANUAL — unparseable color'});
      else { const bg = bgOf(e), c = over(fg, bg);   // element's own background sits behind its text
        const px = parseFloat(st.fontSize), bold = parseInt(st.fontWeight) >= 700;
        const floor = (px >= 24 || (px >= 18.66 && bold)) ? 3 : 4.5;
        const r = ratio(c, bg);
        if (r < floor) fails.push({t:text.slice(0,30), r:+r.toFixed(2), need:floor}); }
    }
    // non-text: control borders need 3:1 against the surrounding surface
    if (e.matches('input,select,textarea,button,[role=button]') && parseFloat(st.borderTopWidth) > 0 && st.borderTopStyle !== 'none' && !/rgba\(0, 0, 0, 0\)|transparent/.test(st.borderTopColor)) {
      const bc = parse(st.borderTopColor), bg = bgOf(e.parentElement || e);
      if (bc) { const r = ratio(over(bc, bg), bg);
        if (r < 3) fails.push({t:'border:' + (e.name || e.type || e.tagName), r:+r.toFixed(2), need:3}); }
    }
  }
  return fails.slice(0,40);
})()
```

Empty array = pass. Any `MANUAL` row means the probe could not measure — check that element in the screenshot, never assume it passed. Outside this probe's reach — judge in screenshot review: text over images/gradients, meaningful icons/SVG, focus-ring contrast.

Target size (at 375px) — two buckets: below 24px fails outright (WCAG floor); interactive controls 24–43px are listed for the 44px product-target judgment in screenshot review:

```js
(() => { const els=[...document.querySelectorAll('button,a,[role=button],[role=link],input,select,textarea,[onclick]')]
    .map(e=>{ // the real hit target: wrapping label, or the label[for] pointing at this control
      let t = e.closest('label');
      if (!t && e.id) t = document.querySelector(`label[for="${CSS.escape(e.id)}"]`);
      const own = e.getBoundingClientRect(), lab = t ? t.getBoundingClientRect() : own;
      return {e, r: (lab.width*lab.height > own.width*own.height) ? lab : own}; })
    .filter(x=>x.r.width>0&&x.r.height>0);
  const name = x => (x.e.textContent?.trim() || x.e.getAttribute('aria-label') || x.e.tagName).slice(0,20);
  return { fail: els.filter(x=>x.r.width<24||x.r.height<24).map(name),
           judge44: els.filter(x=>(x.r.width<44||x.r.height<44)&&x.r.width>=24&&x.r.height>=24).map(name) }; })()
```

`fail` non-empty = probe failure. Every primary control appearing in `judge44` fails the review unless it is a genuinely secondary/inline control.

Dead air (at 1440px) — merges every visible text/visual element into occupied bands, then reports empty bands between them. `fail` = above the Gate 4 limit (+ tolerance); `judge` = large but possibly a declared marketing feature:

```js
(() => { const scrollers=[...document.querySelectorAll('*')].filter(e=>e.scrollHeight>e.clientHeight+50);
  const root=scrollers.sort((a,b)=>b.scrollHeight-a.scrollHeight)[0]||document.documentElement;
  const vis=e=>e.checkVisibility?e.checkVisibility({checkOpacity:true,visibilityProperty:true}):e.offsetHeight>0;
  const leaves=[...root.querySelectorAll('*')].filter(e=>{ if(!e.offsetHeight||e.offsetHeight>600||!vis(e)) return false;
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

Landing continuity (marketing pages, at 1440px) — render-level, so it catches every emission style (logical properties, arbitrary class names). Sticky/fixed bars are exempt (their seam is chrome, not a section boundary):

```js
(() => { const vw = innerWidth;
  const sectionLevel = e => { const p = e.parentElement;
    return e.matches('section,footer,header') || (p && (p === document.body || p.tagName === 'MAIN')); };
  const seam = (e, s, r) => {
    const top = parseFloat(s.borderTopWidth) > 0 && s.borderTopStyle !== 'none';
    const bot = parseFloat(s.borderBottomWidth) > 0 && s.borderBottomStyle !== 'none';
    const hr = e.tagName === 'HR' || (r.height <= 2 && !/rgba\(0, 0, 0, 0\)|transparent/.test(s.backgroundColor));
    const shadow = /(^|,)\s*(inset\s+)?0(px)?\s+-?[12]px\s+0/.test(s.boxShadow || '');
    let pseudo = false;
    for (const which of ['::before','::after']) { const ps = getComputedStyle(e, which);
      if (ps.content !== 'none' && parseFloat(ps.height) <= 2 && parseFloat(ps.width) > vw*0.5
          && !/rgba\(0, 0, 0, 0\)|transparent/.test(ps.backgroundColor)) pseudo = true; }
    return top || bot || hr || shadow || pseudo; };
  const names = [...document.querySelectorAll('*')].filter(e => {
    const r = e.getBoundingClientRect(); if (r.width < vw*0.6) return false;
    const s = getComputedStyle(e);
    if (s.position === 'sticky' || s.position === 'fixed') return false;
    if (e.closest('table,thead,tbody,ul,ol')) return false;
    if (!sectionLevel(e)) return false;   // component-internal seams are anatomy; screenshot is the backstop
    return seam(e, s, r);
  }).map(e => e.tagName + '.' + String(e.className).split(' ')[0]);
  const rules = {}; names.forEach(n => rules[n] = (rules[n]||0) + 1);
  // background TRANSITIONS in document order (not distinct colors)
  const bands = [...document.querySelectorAll('body > *, main > *, main section')]
    .filter(e => { const r = e.getBoundingClientRect(); return r.width >= vw*0.6 && r.height > 120; })
    .sort((a,b) => a.getBoundingClientRect().top - b.getBoundingClientRect().top)
    .map(e => getComputedStyle(e).backgroundColor);
  let transitions = 0;
  for (let i = 1; i < bands.length; i++) if (bands[i] !== bands[i-1]) transitions++;
  return { rules, transitions };
})()
```

Reading the result on a marketing page: any `rules` entry = a section-level seam — **fail** unless the screenshot proves it is component anatomy (repetition count is a hint, never proof — three bordered `<section>`s are three seams). A single non-sticky `HEADER`/`FOOTER` seam = judge. `transitions ≤ 2` in document order (base→emphasis and emphasis/base→footer); returning to base between bands counts as a transition. Sub-60vw seams and exotic emissions escape this probe — the full-page screenshot is the backstop. App shells are exempt — their seams are shell anatomy.

Focus visibility: key-tab through the page and screenshot mid-cycle — every stop shows a visible ring.

Layout shift: screenshot immediately after load and again after network idle; differing layouts = unreserved async space.

## Evidence

Per cell (state × viewport), record: state name, how it was produced, viewport, screenshot path, errors/console/failed-request output, every probe result. Findings carry: gate check, severity, screenshot path, repro steps. Keep artifacts under one directory per run (`design-qa-live/<app>-<state>-<viewport>.png`).
