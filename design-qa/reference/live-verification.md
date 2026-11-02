# Live Verification Runbook — Gate 12 Commands & Probes

Pass conditions, state/viewport matrices, N-A rules, and the completion criterion live in SKILL.md Gate 12. This file owns the execution: exact commands, probe JavaScript, and evidence.

## Setup

```bash
agent-browser-chrome skills get core        # load the CLI workflow reference
AB="agent-browser-chrome --session <app>-qa" # ISOLATED session — parallel agents share the default
                                             # instance and will hijack your tabs mid-verification
# agent-browser-chrome = agent-browser with AGENT_BROWSER_ENGINE=chrome (pixels for screenshots and
# canvas contrast). Plain agent-browser runs Lightpanda here and renders no pixels. Keep one engine
# for every command of the session.
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

Verify the emulation took: `$AB eval "matchMedia('(prefers-reduced-motion: reduce)').matches"`. When it reports `false` (known agent-browser-chrome gap), the fallback ladder is:

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

## Render probes (overflow, wrapping, overlap, alignment)

Run these four probes in every cell, after the machine probes above. Each returns `{fail, judge}`. Tier: `fail` non-empty = **FAIL**; else `judge` non-empty = **JUDGE** (check each row against the screenshot and record the verdict); else **PASS**. Shared terms:

- **1px tolerance**: `scrollWidth`, `clientWidth` and `clientHeight` are integers, so a 1px difference is rounding, not a defect.
- **4px step**: the Gate 4 grid unit. An offset of a full step is a visible misalignment; a smaller offset can be optical alignment and goes to JUDGE.
- **Money or metric**: text that contains a currency sign next to a digit, or a number followed by %, k, M, B or a currency code.
- **Visible text**: text whose box is wider and taller than 1px, inside its nearest clipping ancestor. Screen-reader-only text and hover-swap copies hidden by `overflow: hidden` are not visible.
- **Label**: an element whose descendants are all inline. A card link that holds headings and paragraphs is a container, not a label.

<!-- probe:clip -->
Text overflow and clipping (Gate 8 wrap-first). FAIL: glyphs spill past the element's box; text cut by `overflow: hidden` or `clip` with no ellipsis or line clamp (a vertical cut counts when at least one font size of text is hidden; less is descender overflow); a heading, money or metric truncated; any truncation whose full value has no `title` or `aria-label`. JUDGE: other truncation with the full value reachable; confirm in the screenshot that the design fixes this cell's width. A scroll region (`overflow: auto` or `scroll`) and its direct child keep their content reachable and are skipped:

```js
(() => { const TOL = 1;
  const MONEY = /[$€£¥₹]\s?\d|\d[\d,.]*\s?(%|[kKMB]\b|USD|EUR|GBP|AED|SAR)/;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const out = {fail: [], judge: []};
  for (const e of document.querySelectorAll('body *')) {
    const box = e.getBoundingClientRect();
    if (!vis(e) || box.width <= TOL || box.height <= TOL || e.matches('input,textarea,select,option,script,style')) continue;
    const texts = [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
    if (!texts.length) continue;
    const s = getComputedStyle(e), ps = e.parentElement && getComputedStyle(e.parentElement);
    if (/auto|scroll/.test(s.overflowX + s.overflowY) || (ps && /auto|scroll/.test(ps.overflowX + ps.overflowY))) continue;
    let left = Infinity, right = -Infinity;
    for (const n of texts) { const g = document.createRange(); g.selectNodeContents(n);
      for (const q of g.getClientRects()) if (q.width > TOL) { left = Math.min(left, q.left); right = Math.max(right, q.right); } }
    const t = e.textContent.trim().replace(/\s+/g, ' '), row = {t: t.slice(0, 40), scroll: e.scrollWidth, client: e.clientWidth};
    const cutX = e.scrollWidth > e.clientWidth + TOL, cutY = e.scrollHeight - e.clientHeight >= parseFloat(s.fontSize);
    const clamped = s.webkitLineClamp !== 'none' && e.scrollHeight > e.clientHeight + TOL;
    if (s.overflowX === 'visible' && s.overflowY === 'visible') {
      if (left < box.left - TOL || right > box.right + TOL) out.fail.push({...row, why: 'spills out of its box'});
      continue; }
    const truncated = (s.textOverflow === 'ellipsis' && cutX) || clamped;
    if (!truncated) { if (cutX || cutY) out.fail.push({...row, why: 'cut without ellipsis'}); continue; }
    const holder = e.closest('[title],[aria-label]');
    const full = holder && (holder.title || holder.getAttribute('aria-label') || '').includes(t);
    if (e.matches('h1,h2,h3,h4,h5,h6') || MONEY.test(t)) out.fail.push({...row, why: 'title, money or metric truncated'});
    else if (!full) out.fail.push({...row, why: 'truncated, full value unreachable'});
    else out.judge.push({...row, why: 'truncated: confirm the design fixes this width'});
  }
  return out; })()
```

<!-- probe:wrap -->
Unwanted wrapping. Counts the rendered lines of visible text. FAIL: a control label (button, tab, summary, or a link with its own background or border) on more than one line; a money or metric label on more than one line; one word broken across lines. JUDGE: a `label`, `th`, `dt` or `legend` on more than one line. Only labels are checked: headings, prose and containers wrap freely (wrap-first):

```js
(() => { const TOL = 1;
  const MONEY = /[$€£¥₹]\s?\d|\d[\d,.]*\s?(%|[kKMB]\b|USD|EUR|GBP|AED|SAR)/;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clear = c => /rgba\(0, 0, 0, 0\)|transparent/.test(c);
  const clipBox = n => { for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) {
      const s = getComputedStyle(a); if (s.overflowX !== 'visible' || s.overflowY !== 'visible') return a.getBoundingClientRect(); } return null; };
  const shown = (q, c) => q.width > TOL && q.height > TOL && (!c ||
    (Math.min(q.bottom, c.bottom) - Math.max(q.top, c.top) > TOL && Math.min(q.right, c.right) - Math.max(q.left, c.left) > TOL));
  const lines = e => { const tops = [], it = document.createTreeWalker(e, NodeFilter.SHOW_TEXT);
    for (let n; (n = it.nextNode());) { if (!n.textContent.trim() || !vis(n.parentElement)) continue;
      const c = clipBox(n), g = document.createRange(); g.selectNodeContents(n);
      for (const q of g.getClientRects()) if (shown(q, c) && !tops.some(t => Math.abs(t - q.top) < q.height / 2)) tops.push(q.top); }
    return tops.length; };
  const inlineOnly = e => [...e.querySelectorAll('*')].every(d => /^inline|contents|none/.test(getComputedStyle(d).display));
  const isControl = e => { if (e.matches('button,[role=button],[role=tab],summary')) return true;
    if (!e.matches('a')) return false; const s = getComputedStyle(e);
    return s.display !== 'inline' && (!clear(s.backgroundColor) || parseFloat(s.borderTopWidth) > 0); };
  const out = {fail: [], judge: []};
  for (const e of document.querySelectorAll('body *')) {
    const box = e.getBoundingClientRect();
    if (!vis(e) || box.width <= TOL || box.height <= TOL || !inlineOnly(e)) continue;
    const control = isControl(e);
    if (!control && ![...e.childNodes].some(n => n.nodeType === 3 && n.textContent.trim())) continue;
    if (!control && e.parentElement?.closest('button,[role=button],[role=tab],summary')) continue;   // reported with its control
    const n = lines(e); if (n < 2) continue;
    const t = e.textContent.trim().replace(/\s+/g, ' '), row = {t: t.slice(0, 40), lines: n};
    if (control) out.fail.push({...row, why: 'control label wraps'});
    else if (!/\s/.test(t)) out.fail.push({...row, why: 'word broken across lines'});
    else if (MONEY.test(t) && t.split(' ').length <= 4) out.fail.push({...row, why: 'money or metric wraps'});
    else if (e.matches('label,th,dt,legend')) out.judge.push({...row, why: 'label wraps'});
  }
  return out; })()
```

The money row applies to labels of four words or fewer, so a sentence that mentions a price can still wrap.

<!-- probe:overlap -->
Overlap of sibling boxes. Compares the visible line boxes of every text run (the glyph box trimmed to the computed `line-height`, so tight leading is not overlap) and the border boxes of controls and media, across elements where neither contains the other. Inline runs that share one block are skipped. FAIL: two in-flow boxes intersect by more than 1px on both axes. JUDGE: the intersection is a deliberate layer: it involves an `absolute`, `fixed` or `sticky` box (a badge on an avatar, a sticky bar) or a transformed box (a carousel slide, an animation mid-flight); the two boxes sit in grid items placed over each other (grid items overlap only by explicit placement); it is media on media (an avatar stack); or both runs hold the same text (a duplicated text effect):

```js
(() => { const TOL = 1;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clipBox = n => { for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) {
      const s = getComputedStyle(a); if (s.overflowX !== 'visible' || s.overflowY !== 'visible') return a.getBoundingClientRect(); } return null; };
  const cut = (q, c) => { if (!c) return q; const l = Math.max(q.left, c.left), r = Math.min(q.right, c.right), t = Math.max(q.top, c.top), b = Math.min(q.bottom, c.bottom);
    return {left: l, right: r, top: t, bottom: b, width: r - l, height: b - t}; };
  const block = e => { for (let n = e; n; n = n.parentElement) if (!/^inline/.test(getComputedStyle(n).display) || n === document.body) return n; };
  const layered = (e, stop) => { for (let n = e; n && n !== stop; n = n.parentElement) { const s = getComputedStyle(n);
      if (/absolute|fixed|sticky/.test(s.position) || s.transform !== 'none') return true; } return false; };
  const MEDIA = 'img,svg,video,canvas', BOX = 'button,input,select,textarea,[role=button],' + MEDIA;
  const items = [];
  for (const e of document.querySelectorAll('body *')) {
    if (!vis(e)) continue;
    if (e.matches(BOX) && !e.parentElement.closest('button,svg,[role=button]')) {
      const r = cut(e.getBoundingClientRect(), clipBox(e)); if (r.width > TOL && r.height > TOL) items.push({e, r, media: e.matches(MEDIA)}); continue; }
    if (e.closest('button,svg,[role=button]')) continue;
    const s = getComputedStyle(e);
    if (/rgba\(0, 0, 0, 0\)|transparent/.test(s.webkitTextFillColor) && s.backgroundClip !== 'text') continue;
    for (const n of e.childNodes) { if (n.nodeType !== 3 || !n.textContent.trim()) continue;
      const c = clipBox(n), g = document.createRange(); g.selectNodeContents(n);
      const lh = parseFloat(s.lineHeight) || 0;   // 'normal' parses to NaN: keep the glyph box
      for (const q of g.getClientRects()) { const trim = lh && q.height > lh ? (q.height - lh) / 2 : 0;
        const r = cut({left: q.left, right: q.right, top: q.top + trim, bottom: q.bottom - trim}, c);
        if (r.right - r.left > TOL && r.bottom - r.top > TOL) items.push({e, r, text: n.textContent.trim()}); } }
  }
  const out = {fail: [], judge: []}, seen = new Set(), all = [...document.querySelectorAll('*')];
  for (let i = 0; i < items.length; i++) for (let j = i + 1; j < items.length; j++) {
    const a = items[i], b = items[j];
    if (a.e === b.e || a.e.contains(b.e) || b.e.contains(a.e)) continue;
    const w = Math.min(a.r.right, b.r.right) - Math.max(a.r.left, b.r.left);
    const h = Math.min(a.r.bottom, b.r.bottom) - Math.max(a.r.top, b.r.top);
    if (w <= TOL || h <= TOL) continue;
    if (/^inline/.test(getComputedStyle(a.e).display) && /^inline/.test(getComputedStyle(b.e).display) && block(a.e) === block(b.e)) continue;
    const key = [all.indexOf(a.e), all.indexOf(b.e)].sort((x, y) => x - y).join('-');
    if (seen.has(key)) continue; seen.add(key);
    let common = a.e.parentElement; while (common && !common.contains(b.e)) common = common.parentElement;
    const name = x => (x.textContent.trim() || x.getAttribute('aria-label') || x.tagName).slice(0, 25);
    const row = {a: name(a.e), b: name(b.e), w: Math.round(w), h: Math.round(h)};
    const gridStack = common && /grid/.test(getComputedStyle(common).display);
    const deliberate = layered(a.e, common) || layered(b.e, common) || gridStack || (a.media && b.media) || (a.text && a.text === b.text);
    (deliberate ? out.judge : out.fail).push(row);
  }
  return out; })()
```

<!-- probe:align -->
Sibling alignment in lockups. Checks the children of every flex row and every vertical stack:

- **Icon and text**: an `svg` or `img` (alone or wrapped) beside a text sibling in the same row. Compares the icon's vertical centre with the centre of the text's first line.
- **Label and value**: two one-line labels side by side in the same row. Compares their first baselines, measured with a zero-height inline-block marker. A label whose text sits directly in a flex or grid box is skipped: the marker would become a flex or grid item.
- **Left edges of a stack**: the labels among the children of a block or column flex container. Compares each label's left edge with the most common left edge.

Offset ≤ 1px: PASS. Above 1px and below 4px: JUDGE (optical alignment is possible). A full 4px step or more: FAIL. These cases go to JUDGE at any size: a multi-line text beside an icon (an avatar beside a name and a subtitle) when the icon is centred on neither the first line nor the whole block; label and value in different font sizes; a stack label offset by a whole multiple of 4px (a deliberate indent is possible); a stack label centred in its parent; a stack label or stack with a `transform` (an animation can be mid-flight):

```js
(() => { const TOL = 1, STEP = 4;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const kids = p => [...p.children].filter(c => { const r = c.getBoundingClientRect();
    return vis(c) && r.width > TOL && r.height > TOL && !/absolute|fixed/.test(getComputedStyle(c).position); });
  const inlineOnly = e => [...e.querySelectorAll('*')].every(d => /^inline|contents|none/.test(getComputedStyle(d).display));
  const isLabel = c => !c.matches('svg,img') && c.textContent.trim() && inlineOnly(c);
  const isIcon = c => c.matches('svg,img') || (c.children.length === 1 && c.children[0].matches('svg,img') && !c.textContent.trim());
  const rects = c => { const g = document.createRange(); g.selectNodeContents(c); return [...g.getClientRects()].filter(q => q.width > TOL && q.height > TOL); };
  const firstLine = c => { const it = document.createTreeWalker(c, NodeFilter.SHOW_TEXT, {acceptNode: n => n.textContent.trim() ? 1 : 3});
    const n = it.nextNode(); if (!n) return null; const g = document.createRange(); g.selectNodeContents(n); return g.getClientRects()[0]; };
  const lineCount = c => { const tops = []; for (const q of rects(c)) if (!tops.some(t => Math.abs(t - q.top) < q.height / 2)) tops.push(q.top); return tops.length; };
  const baseline = c => { const it = document.createTreeWalker(c, NodeFilter.SHOW_TEXT, {acceptNode: n => n.textContent.trim() ? 1 : 3});
    const n = it.nextNode(); if (!n || /flex|grid/.test(getComputedStyle(n.parentNode).display)) return null;   // a marker in a flex or grid box becomes an item, not inline
    const m = document.createElement('span');
    m.style.cssText = 'display:inline-block;width:0;height:0;vertical-align:baseline';
    n.parentNode.insertBefore(m, n); const y = m.getBoundingClientRect().top; m.remove(); return {y, fs: getComputedStyle(n.parentNode).fontSize}; };
  const sameRow = (a, b) => { const x = a.getBoundingClientRect(), y = b.getBoundingClientRect(); return Math.min(x.bottom, y.bottom) - Math.max(x.top, y.top) > TOL; };
  const cy = r => r.top + r.height / 2;
  const name = c => (c.textContent.trim() || c.getAttribute('aria-label') || c.tagName).slice(0, 25);
  const out = {fail: [], judge: []};
  const grade = (d, row, judgeOnly) => { d = Math.round(d * 10) / 10; if (d <= TOL) return;
    (d < STEP || judgeOnly ? out.judge : out.fail).push({...row, off: d}); };
  for (const p of document.querySelectorAll('body, body *')) {
    if (!vis(p)) continue;
    const s = getComputedStyle(p), cs = kids(p); if (cs.length < 2) continue;
    if (/flex/.test(s.display) && !/column/.test(s.flexDirection)) for (let i = 1; i < cs.length; i++) {
      const [a, b] = [cs[i - 1], cs[i]]; if (!sameRow(a, b)) continue;
      const icon = isIcon(a) ? a : isIcon(b) ? b : null, text = icon === a ? b : a;
      if (icon && text.textContent.trim()) { const l = firstLine(text); if (!l) continue;
        const ic = cy(icon.getBoundingClientRect()), multi = lineCount(text) > 1;
        if (multi && Math.abs(ic - cy(text.getBoundingClientRect())) <= TOL) continue;
        grade(Math.abs(ic - cy(l)), {kind: 'icon-text', a: name(icon), b: name(text)}, multi); }
      else if (!icon && isLabel(a) && isLabel(b) && lineCount(a) === 1 && lineCount(b) === 1) {
        const x = baseline(a), y = baseline(b); if (!x || !y) continue;
        grade(Math.abs(x.y - y.y), {kind: 'label-value', a: name(a), b: name(b)}, x.fs !== y.fs); }
    }
    const stack = (/flex/.test(s.display) && /column/.test(s.flexDirection)) || s.display === 'block';
    const labels = stack ? cs.filter(c => isLabel(c) && !/^inline/.test(getComputedStyle(c).display)) : [];
    if (labels.length >= 2) { const lefts = labels.map(c => Math.round(c.getBoundingClientRect().left));
      const count = {}; lefts.forEach(l => count[l] = (count[l] || 0) + 1);
      const mode = +Object.keys(count).sort((x, y) => count[y] - count[x])[0];
      const pr = p.getBoundingClientRect();
      labels.forEach((c, i) => { const r = c.getBoundingClientRect(), d = Math.abs(lefts[i] - mode);
        const centred = Math.abs((r.left - pr.left) - (pr.right - r.right)) <= TOL && r.width < pr.width - TOL;
        const moving = getComputedStyle(c).transform !== 'none' || s.transform !== 'none';
        grade(d, {kind: 'stack-left', a: name(c), b: name(p)}, centred || moving || d % STEP === 0); });
    }
  }
  return out; })()
```

## Other render checks

Focus visibility: key-tab through the page and screenshot mid-cycle — every stop shows a visible ring.

Layout shift: screenshot immediately after load and again after network idle; differing layouts = unreserved async space.

## Evidence

Per cell (state × viewport), record: state name, how it was produced, viewport, screenshot path, errors/console/failed-request output, every probe result. Findings carry: gate check, severity, screenshot path, repro steps. Keep artifacts under one directory per run (`design-qa-live/<app>-<state>-<viewport>.png`), with the before-and-after captures (SKILL.md "Before and after") in its `before/`, `after/`, and `diff/` folders. For each render probe, record the tier and every FAIL and JUDGE row.
