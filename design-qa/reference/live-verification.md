# Live Verification Runbook — Gate 12 Commands & Probes

Pass conditions, state/viewport matrices, N-A rules, and the completion criterion live in SKILL.md Gate 12. This file owns the execution: exact commands, probe JavaScript, and evidence.

## Setup

The official CLI uses Chrome by default. Screenshots count only from the Chrome engine. On a machine whose default engine is not Chrome (for example Lightpanda in `~/.agent-browser/config.json`), run the same commands with `AGENT_BROWSER_ENGINE=chrome` on every call, or use a wrapper such as `agent-browser-chrome`. Keep one engine for the whole session.

```bash
agent-browser skills get core        # load the CLI workflow reference
AB="agent-browser --session <app>-qa" # ISOLATED session — parallel agents share the default
                                             # instance and will hijack your tabs mid-verification
# resolve the target: project dev/preview command (package.json scripts) or supplied URL
# static single-file builds: file:///absolute/path/index.html works directly
PROBES="$PI_SKILL_DIR/scripts/probes"         # design-qa's probe files; without PI_SKILL_DIR, the
                                             # scripts/probes folder beside design-qa's SKILL.md
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
$AB set media light reduced-motion   # dark reduced-motion for a dark page
```

Verify the emulation took: `$AB eval "matchMedia('(prefers-reduced-motion: reduce)').matches"`. When it reports `false`, the fallback ladder is:

1. Confirm a `@media (prefers-reduced-motion: reduce)` block exists in the source (read the CSS file directly — `document.styleSheets` throws `SecurityError` on `file://` external sheets).
2. Inject the equivalent rules via `eval` and verify their CSS effect (animations/transitions neutralized).
3. JavaScript that branches on `matchMedia` at load time cannot be exercised this way — when the page has such branches, record the reduced-motion probe as `N-A — emulation unavailable, JS branch unverified` with the source evidence. N-A is never a pass; it must appear in the report.

## Machine probes (run via `$AB eval`)

Each probe file in `$PROBES` is one JavaScript expression; `$AB eval` prints its result. Run the file; reading it is optional. The short overflow, request and dead-air probes stay inline here (dead air needs its `marketing` constant set per page).

Horizontal overflow (at 375px):

```js
document.documentElement.scrollWidth <= window.innerWidth
```

Heading order — first **visible** heading is an h1, exactly one visible h1, no forward skips (hidden headings don't exist for the accessibility tree):

```bash
$AB eval "$(cat "$PROBES/headings.js")"
```

Cross-check against `$AB snapshot -i` — the accessibility tree is the authority.

Rendered contrast — normalizes ANY color syntax (oklch/hsl/named) by drawing it to a 1×1 canvas and reading the pixel back (string parsing is unsafe: modern Chromium serializes `fillStyle` in the original color space). Enumerates EVERY element with direct text (no tag allowlist — `<div>` text counts), composites alpha through **all** ancestor layers, probes input borders for the 3:1 non-text floor, and applies the correct text tier (3:1 for ≥24px or ≥18.66px bold; 4.5:1 otherwise):

```bash
$AB eval "$(cat "$PROBES/contrast.js")"
```

Empty array = pass. Any `MANUAL` row means the probe could not measure — check that element in the screenshot, never assume it passed. Outside this probe's reach — judge in screenshot review: text over images/gradients, meaningful icons/SVG, focus-ring contrast.

Target size (at 375px) — two buckets: below 24px fails outright (WCAG floor); interactive controls 24–43px are listed for the 44px product-target judgment in screenshot review:

```bash
$AB eval "$(cat "$PROBES/targets.js")"
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

```bash
$AB eval "$(cat "$PROBES/landing.js")"
```

Reading the result on a marketing page: any `rules` entry = a section-level seam — **fail** unless the screenshot proves it is component anatomy (repetition count is a hint, never proof — three bordered `<section>`s are three seams). A single non-sticky `HEADER`/`FOOTER` seam = judge. `transitions ≤ 2` in document order (base→emphasis and emphasis/base→footer); returning to base between bands counts as a transition. Sub-60vw seams and exotic emissions escape this probe — the full-page screenshot is the backstop. App shells are exempt — their seams are shell anatomy.

## Render probes (overflow, wrapping, overlap, alignment)

Run these four probes in every cell, after the machine probes above:

```bash
for p in clip wrap overlap align; do $AB eval "$(cat "$PROBES/$p.js")"; done   # tier, counts, FAIL rows
$AB eval "DQ_JUDGE=1; $(cat "$PROBES/overlap.js")"                           # same, plus every JUDGE row
```

Each prints `{tier, counts: {fail, judge}, fail: [...]}`. Tier `FAIL`: each FAIL row fails Gate 12. Tier `JUDGE`: rerun that probe with `DQ_JUDGE=1` to get the `judge` rows, check each against the screenshot, and record the verdict. Tier `PASS`: nothing to review. Rows name the text (first 25–40 characters), so find each one in the screenshot. Shared terms:

- **1px tolerance**: `scrollWidth`, `clientWidth` and `clientHeight` are integers, so a 1px difference is rounding, not a defect.
- **4px step**: the Gate 4 grid unit. An offset of a full step is a visible misalignment; a smaller offset can be optical alignment and goes to JUDGE.
- **Money or metric**: text that contains a currency sign next to a digit, or a number followed by %, k, M, B or a currency code.
- **Visible text**: text whose box is wider and taller than 1px, inside the visible area that all its clipping ancestors leave (each clipped axis cuts it). Screen-reader-only text and hover-swap copies hidden by `overflow: hidden` are not visible.
- **Stage**: every probe in `scripts/probes/` skips the descendants of a stageshow stage root (`.ss-stage`); `film.mjs` checks them. overlap.js still compares the stage box with its host siblings.
- **Label**: an element whose descendants are all inline. A card link that holds headings and paragraphs is a container, not a label.

**clip.js**: text overflow and clipping (Gate 8 wrap-first). Text is measured against its clip box: the nearest box, the element itself or an ancestor, with `overflow: hidden` or `clip`. FAIL: glyphs spill past the element's box; text cut by the clip box with no ellipsis or line clamp (a line the clip box shows only in part, or at least one font size of the element's own text hidden; glyphs past the line box are descender overflow, not a cut); a heading, money or metric truncated; a truncation with no recovery path. JUDGE: a truncation whose full value is in `title` or `aria-label` (confirm in the screenshot that the design fixes this cell's width); a truncation inside or around a link, button or tooltip trigger (`aria-describedby`, `data-tooltip`): open that detail or tooltip path and confirm it shows the full value. A scroll region (`overflow: auto` or `scroll`) and its direct child keep their content reachable and are skipped.

**wrap.js**: unwanted wrapping. Counts the rendered lines of visible text. FAIL: a control label (button, tab, summary, or a link with its own background or border) on more than one line; one word broken across lines. A button, tab or summary label is measured as rendered, whatever wrapper element holds its one text; a control with several texts (a name over an email) holds fields, not one label. JUDGE: one number or money token split across lines (`$12,000,000` over two lines); a `label`, `th`, `dt` or `legend` on more than one line. Headings, titles, money and metric labels, prose and containers wrap freely between words (Gate 8 wrap-first).

**overlap.js**: overlap of sibling boxes. Compares the visible line boxes of every text run (the glyph box trimmed to the computed `line-height`, so tight leading is not overlap) and the border boxes of controls and media, across elements where neither contains the other. Text runs of `display: inline` elements that share one block are skipped; inline-block, control and media boxes are always compared. FAIL: two in-flow boxes intersect by more than 1px on both axes. JUDGE: the intersection is a deliberate layer: it involves an `absolute`, `fixed` or `sticky` box (a badge on an avatar, a sticky bar) or a transformed box (a carousel slide, an animation mid-flight); the two boxes sit in grid items placed over each other (grid items overlap only by explicit placement); it is media on media (an avatar stack); or both runs hold the same text (a duplicated text effect).

**align.js**: sibling alignment in lockups. Checks the visible children of every flex row and every vertical stack (a child that its clipping ancestors hide completely, such as a collapsed `height: 0; overflow: hidden` panel, is skipped):

- **Icon and text**: an `svg` or `img` (alone or wrapped) beside a text sibling in the same row. Compares the icon's vertical centre with the centre of the text's first line.
- **Label and value**: two one-line labels side by side in the same row. Compares their first baselines, measured with a zero-height inline-block marker. A label whose text sits directly in a flex or grid box is skipped: the marker would become a flex or grid item.
- **Left edges of a stack**: the labels among the children of a block or column flex container. Compares each label's left edge with the most common left edge.

Offset ≤ 1px: PASS. Above 1px and below 4px: JUDGE (optical alignment is possible). A full 4px step or more: FAIL. These cases go to JUDGE at any size: a multi-line text beside an icon (an avatar beside a name and a subtitle) when the icon is centred on neither the first line nor the whole block; label and value in different font sizes; a stack label offset by a whole multiple of 4px (a deliberate indent is possible); a stack label centred in its parent; a stack label or stack with a `transform` (an animation can be mid-flight).

## Other render checks

Focus visibility: key-tab through the page and screenshot mid-cycle — every stop shows a visible ring.

Layout shift: screenshot immediately after load and again after network idle; differing layouts = unreserved async space.

## Evidence

Per cell (state × viewport), record: state name, how it was produced, viewport, screenshot path, errors/console/failed-request output, every probe result. Findings carry: gate check, severity, screenshot path, repro steps. Keep artifacts under one directory per run (`design-qa-live/<app>-<state>-<viewport>.png`), with the before-and-after captures (SKILL.md "Before and after") in its `before/`, `after/`, and `diff/` folders. For each render probe, record the tier, the counts, every FAIL row, and a verdict per JUDGE row.
