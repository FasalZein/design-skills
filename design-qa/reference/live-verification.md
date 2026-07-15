# Live Verification Runbook — Gate 12 Commands & Probes

Pass conditions, state/viewport matrices, N-A rules, and the completion criterion live in SKILL.md Gate 12. This file owns the execution: exact commands, probe JavaScript, and evidence.

## Setup

```bash
agent-browser skills get core        # load the CLI workflow reference
# resolve the target: project dev/preview command (package.json scripts) or supplied URL
# static single-file builds: file:///absolute/path/index.html works directly
```

Run each Gate 12 session fresh — stale tabs carry console history that pollutes error capture.

## Per-viewport loop

```bash
agent-browser set viewport 1440 900        # before navigation
agent-browser open "$URL"
agent-browser errors                        # must print nothing
agent-browser console                       # zero errors/warnings that matter
agent-browser snapshot -i                   # accessibility tree: headings, roles, names
agent-browser screenshot gate12-1440-loaded.png
agent-browser set viewport 375 812
agent-browser screenshot gate12-375-loaded.png
```

Repeat `set viewport 768 1024` when the layout has a tablet breakpoint.

## State setup

Drive each required state through the app itself (navigate, filter to zero results, submit invalid input, throttle/block the API for error states) or project fixtures. Record how each state was produced — that's the repro step for any finding. A state that should exist but cannot be exposed = failing state check (SKILL.md rule).

Dark mode / reduced motion:

```bash
agent-browser eval "document.documentElement.classList.add('dark')"   # or the project's toggle
agent-browser set media --reduced-motion reduce
```

## Machine probes (run via `agent-browser eval`)

Horizontal overflow (at 375px):

```js
document.documentElement.scrollWidth <= window.innerWidth
```

Heading order:

```js
(() => { const hs=[...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].map(h=>+h.tagName[1]);
  const oneH1 = hs.filter(l=>l===1).length===1;
  const noSkip = hs.every((l,i)=>i===0||l<=hs[i-1]+1);
  return {oneH1, noSkip}; })()
```

Rendered contrast (body text vs nearest opaque background; WCAG relative luminance):

```js
(() => { const lum = c => { const [r,g,b]=c.match(/\d+(\.\d+)?/g).map(Number).slice(0,3).map(v=>{v/=255;return v<=.03928?v/12.92:((v+.055)/1.055)**2.4}); return .2126*r+.7152*g+.0722*b };
  const bg = el => { for(let n=el;n;n=n.parentElement){ const c=getComputedStyle(n).backgroundColor; if(c&&!c.includes('0, 0, 0, 0')&&c!=='transparent') return c } return 'rgb(255,255,255)' };
  return [...document.querySelectorAll('p,li,td,span,label')].filter(e=>e.innerText?.trim()&&e.offsetHeight).slice(0,80).map(e=>{const c=getComputedStyle(e).color,b=bg(e);const L1=lum(c),L2=lum(b);const r=(Math.max(L1,L2)+.05)/(Math.min(L1,L2)+.05);return {t:e.innerText.slice(0,30),r:+r.toFixed(2)}}).filter(x=>x.r<4.5); })()
```

Empty array = pass. Semi-transparent layered backgrounds can fool this probe — confirm those hits in the screenshot before reporting.

Target size (at 375px):

```js
[...document.querySelectorAll('button,a,[role=button],input,select')].filter(e=>{const r=e.getBoundingClientRect();return r.width>0&&(r.width<24||r.height<24)}).map(e=>e.textContent?.slice(0,20)||e.ariaLabel)
```

Flags below the 24px WCAG floor; judge 24–44px primary controls against the 44px product target in review.

Focus visibility: `agent-browser` key-tab through the page (or `eval` a focus walk) and screenshot mid-cycle — every stop shows a visible ring.

Layout shift: screenshot immediately after load and again after network idle; differing layouts = unreserved async space.

## Evidence

Per state × viewport, record: state name, how it was produced, viewport, screenshot path, errors/console output, probe results. Findings carry: gate check, severity, screenshot path, repro steps. Keep artifacts under one directory per run (`design-qa-live/<app>-<viewport>-<state>.png`).
