---
name: design-qa
description: Universal UI quality gates — accessibility, consistency, hardening, performance, responsive checks. Pre-ship checklist. Works with any AI agent, any framework.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.css", "**/*.scss"]
---

# Design QA

A structured quality gate for UI code. Run this against any component, page, or feature before shipping. Every check is binary — pass or fail.

---

## How to Use

### Fast Scan (automated, <1 second)

Run the scanner first — it catches regex-detectable issues instantly:

```bash
# Full scan with fix suggestions
bash design-qa/scripts/design-scan.sh [target-dir] --fix

# Skip upstream UI primitives (components/ui/)
bash design-qa/scripts/design-scan.sh [target-dir] --fix --no-ui

# JSON output for CI/tooling
bash design-qa/scripts/design-scan.sh [target-dir] --json

# Critical issues only
bash design-qa/scripts/design-scan.sh [target-dir] --critical-only
```

**Requires:** ripgrep (`rg`). Optional: ast-grep (`sg`) for structural checks.

### Deep Review (LLM-powered, for what scanners can't catch)

After the fast scan, run the manual gates for judgment-based checks:

1. Read the component/page code
2. Run through each gate in order (they're prioritized)
3. Report failures with specific line numbers and fixes
4. Do NOT report passes — only failures. Silence = quality.

---

## Gate 1: Anti-Slop Check (Critical)

Scan for AI-generated aesthetic fingerprints. ANY of these = immediate flag.

| Check | Pass Condition |
|-------|---------------|
| No purple-blue gradients | Zero instances of purple/blue/violet gradient combinations |
| No gradient text | Zero `bg-clip-text text-transparent bg-gradient-*` on metrics/headings |
| No glassmorphism | Zero `backdrop-blur` used decoratively (functional blur like overlays OK) |
| No hero metric template | Not using big-number-in-card with small-label-below pattern |
| No identical card grid | Cards in a grid have varied content/layout, not 3x identical template |
| No glow effects | Zero `shadow-*-*/glow` or `box-shadow` with colored spread |
| No nested cards | Zero Card/panel components rendered inside other Card/panel components |
| Font is intentional | Not using Inter/Roboto/Arial as a "just pick something" default |

**If any fail:** Flag as "AI slop detected" with the specific pattern and location.

---

## Gate 2: Typography Consistency

| Check | How to Verify |
|-------|--------------|
| Uses project type scale only | Grep for arbitrary font sizes: `text-[*px]`, `text-[*rem]`, `font-size:`. Only project-defined scale levels allowed. Exception: `text-[11px]` for micro if in the project scale. |
| No letter-spacing modifications | Grep for `tracking-*`, `letter-spacing`. Should be zero unless explicitly in design spec. |
| Numeric data uses tabular-nums | All `<td>`, `<th>` with numbers, all price/count/date displays use `tabular-nums` or `font-variant-numeric: tabular-nums`. |
| Headings use text-balance | All `<h1>`-`<h6>` and heading-role elements use `text-balance` or `text-pretty`. |
| Line length controlled | Body text containers have `max-w-prose` or equivalent (45-75ch). |
| Max 3 font weights per view | Count distinct `font-*` weights used. More than 3 = flag. |

---

## Gate 3: Color Consistency

| Check | How to Verify |
|-------|--------------|
| No hardcoded colors | Grep for hex (`#[0-9a-f]`), `rgb(`, `hsl(`, `oklch(` in JSX/TSX. All color must come from tokens/utilities. |
| No pure black/white on large areas | `bg-black`, `bg-white`, `#000`, `#fff` on containers, pages, cards = flag. Tokens should provide tinted equivalents. |
| No gray on colored backgrounds | Any `text-gray-*` or `text-muted-*` on a colored (non-white, non-neutral) background = flag. Use a shade of the background color. |
| Status colors are semantic | Success = green, Error = red, Warning = amber, Info = blue. Any inversion = flag. |
| Contrast ratio ≥ 4.5:1 | WCAG 2.x: ≥ 4.5:1 normal, ≥ 3:1 large. APCA (preferred for new projects): \|Lc\| ≥ 60 body, \|Lc\| ≥ 45 large/heading. OKLCH proxy: ΔL ≥ 0.4 body, ΔL ≥ 0.3 large. |
| No inline oklch values | No `bg-[oklch(...)]` or `text-[oklch(...)]` in JSX. OKLCH values belong in CSS token definitions only. |
| Accent color limited | Count distinct accent/brand colors per view. More than 2 = flag. |

---

## Gate 4: Spacing Consistency

| Check | How to Verify |
|-------|--------------|
| No magic numbers | Grep for arbitrary spacing: `p-[*]`, `m-[*]`, `gap-[*]`, `space-*-[*]` with non-standard values. All spacing should use tokens or framework scale (multiples of 4px). |
| Semantic spacing hierarchy | Sections use largest gaps, groups use medium, items use small. Consistent within the page. |
| No triple-layered responsive padding | `p-2 md:p-4 lg:p-6 xl:p-8` = flag. Pick one value per semantic context. |
| 4px grid alignment | All spacing values are multiples of 4px (0.25rem). |

---

## Gate 5: Component Reuse

| Check | How to Verify |
|-------|--------------|
| Existing primitives used | Custom `<button>`, `<input>`, `<dialog>`, `<select>` when project has component equivalents = flag. |
| No primitive mixing | Imports from multiple UI libraries (Radix + Base UI + Headless UI) in same file = flag. |
| CVA for variants | Inline ternary chains for 3+ style variants instead of CVA/cva = flag. |
| data-slot attributes | Component root elements missing `data-slot` = flag (if project uses this convention). |

---

## Gate 6: Interaction States

| Check | How to Verify |
|-------|--------------|
| All buttons have hover state | Every `<Button>` or `<button>` has hover styles (via variant or explicit). |
| Focus visible on all interactive elements | `:focus-visible` ring on buttons, inputs, links, checkboxes, selects. NEVER `outline: none` without replacement. |
| Disabled state implemented | Conditional disable uses `disabled:opacity-*` + `disabled:pointer-events-none`. Not just visual. |
| Loading states exist | Async actions (form submit, data fetch) show loading indicator. Buttons disable during submission. |
| Icon-only buttons have aria-label | Every button with only an icon child has `aria-label="descriptive text"`. |
| Destructive actions use AlertDialog | Delete, discard, overwrite actions use AlertDialog, not plain Dialog or window.confirm. |
| Error messages are inline | Errors shown next to the trigger, not only in toast/banner. |
| Focus restored on dialog close | Closing a dialog/modal restores focus to the element that opened it. |
| Initial focus set on dialog open | Dialogs set initial focus on first interactive element or explicit target on open. |
| aria-expanded on expandables | Accordion, collapsible, disclosure triggers have `aria-expanded` + `aria-controls`. |
| aria-busy on loading containers | Containers receiving async content use `aria-busy={true}` while loading. |
| Paste not blocked | No `onPaste={e => e.preventDefault()}` on any input. |

---

## Gate 7: Accessibility

| Check | How to Verify |
|-------|--------------|
| Semantic HTML | `<button>` for actions, `<a>` for navigation, `<nav>`, `<main>`, `<header>`. No `<div onClick>`. |
| Heading hierarchy | h1 → h2 → h3 in order, no skipping levels. One h1 per page. |
| Alt text on images | Every `<img>` has `alt` attribute. Decorative images: `alt=""`. |
| Form labels | Every input has an associated `<label>` (via `htmlFor` or wrapping). Not just placeholder. |
| Keyboard navigation | Tab order is logical. No keyboard traps. All functionality reachable via keyboard. No `tabIndex` > 0 (disrupts natural tab order). |
| ARIA live regions | Dynamic content updates (toast, status change, async results) use `aria-live="polite"` or `role="status"`. |
| Color not sole indicator | Status/state never communicated by color alone — always pair with icon, text, or pattern. |
| Touch targets ≥ 44x44px | All interactive elements on mobile meet minimum touch target. Check for `min-h-11 min-w-11` or equivalent. |
| prefers-reduced-motion | All animations respect `prefers-reduced-motion: reduce`. |
| h-dvh not h-screen | Grep for `h-screen`. Replace with `h-dvh`. |

---

## Gate 8: Edge Case Hardening

| Check | How to Verify |
|-------|--------------|
| Empty states designed | Every list/table/grid has an empty state with message + CTA. Not blank or "No results". |
| Long text handled | Names, titles, descriptions have `truncate`, `line-clamp-*`, or `break-words`. Test with 100+ char strings. |
| Flex/grid overflow prevented | Flex children have `min-w-0`. Grid children have `min-w-0 min-h-0`. |
| Numbers formatted | Large numbers use locale-aware formatting (Intl.NumberFormat). Not raw `123456789`. |
| Dates formatted | Dates use relative or locale format (Intl.DateTimeFormat). Not raw ISO strings. |
| Loading skeletons match layout | Skeleton shapes mirror actual content structure. Not generic gray rectangles. |
| Double-submit prevented | Form submit buttons disable during async operation. |
| Error recovery exists | Every error state has a retry action or clear path forward. |

---

## Gate 9: Performance

| Check | How to Verify |
|-------|--------------|
| No layout animations | Grep for `animate-*` or `transition-*` on `width`, `height`, `top`, `left`, `margin`, `padding`. Only `transform` and `opacity` allowed. |
| No permanent will-change | Grep for `will-change` in CSS. Should only appear within animation scope, not on static elements. |
| No large blur animations | Grep for `backdrop-blur` + `transition`/`animate` together. Static blur OK, animated blur = GPU killer. |
| Images lazy loaded | Below-fold images use `loading="lazy"`. |
| No layout shift | Async content has reserved space (fixed height, skeleton). |
| Lists virtualized | Lists with 100+ potential items use virtual scrolling. |
| Inputs debounced | Search/filter inputs debounce with 200-300ms delay. |
| Cleanup on unmount | useEffect cleanup returns that cancel subscriptions, abort fetch, remove listeners. |
| No console.log in production | Grep for `console.log`, `console.warn`, `console.error` not wrapped in dev check. |

---

## Gate 10: Responsive Design

| Check | How to Verify |
|-------|--------------|
| Mobile layout works | No horizontal scroll. Content reflows to single column. |
| Touch targets adequate | Interactive elements have min 44x44px hit area on mobile. |
| No hidden core features | `hidden md:block` on essential functionality = flag. Adapt, don't hide. |
| Logical CSS properties | `margin-left/right` → `margin-inline-start/end` for RTL support. |
| Fixed widths avoided on text | `w-24` or `w-[200px]` on text containers = flag. Use padding + flexible width. |
| Zoom not disabled | No `user-scalable=no` or `maximum-scale=1` in viewport meta. WCAG violation. |
| Input method aware | Touch-heavy interactions use `@media (pointer: coarse)` for larger targets. |

---

## Gate 11: Error Resilience

| Check | How to Verify |
|-------|--------------|
| API errors handled by code | 401→redirect to login, 403→permission message, 404→not found, 429→rate limit, 500→generic error. Not all errors treated the same. |
| Error boundaries exist | React error boundaries around major sections. One component crash doesn't take down the page. |
| Double-submit prevented | Form submit buttons disable during async. No `onClick` without loading guard. |
| Optimistic updates have rollback | If using optimistic UI, failed operations revert state and show error. |

---

## Report Format

When running a QA review, output ONLY failures:

```markdown
## QA Report: [Component/Page Name]

### Critical (must fix before merge)
- **[Gate]: [Check]** — [File:Line] — [Specific issue and fix]

### High (fix soon)
- **[Gate]: [Check]** — [File:Line] — [Specific issue and fix]

### Medium (improve when touching this code)
- **[Gate]: [Check]** — [File:Line] — [Specific issue and fix]

### Summary
- X critical, Y high, Z medium issues
- Top pattern: [most repeated issue type]
```

**Severity Guide:**
- **Critical:** Accessibility violations (WCAG A/AA), anti-slop failures, broken interaction states, no error handling
- **High:** Missing loading states, hardcoded colors, inconsistent spacing, no empty states
- **Medium:** Suboptimal typography, missing text-balance, non-debounced inputs, missing tabular-nums

---

## Quick-Check Mode

For fast reviews (PR review, code review), check only these 5:

1. No anti-slop patterns (Gate 1)
2. No hardcoded colors (Gate 3, first check)
3. Focus visible on all interactive elements (Gate 6)
4. Empty states exist (Gate 8)
5. No layout animations (Gate 9)

If all 5 pass, the component is probably fine. If any fail, run the full gate sequence.
