---
name: design-qa
description: Universal UI quality gates — accessibility, consistency, hardening, performance, responsive checks. Pre-ship checklist. Works with any AI agent, any framework.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.css", "**/*.scss"]
---

# Design QA

Structured quality gate for UI code. Run against any component, page, or feature before shipping. Every check is binary — pass or fail. Report ONLY failures. Silence = quality.

## Fast Scan

```bash
bash design-qa/scripts/design-scan.sh [target-dir] --fix        # Full scan with fixes
bash design-qa/scripts/design-scan.sh [target-dir] --no-ui       # Skip upstream primitives
bash design-qa/scripts/design-scan.sh [target-dir] --json        # JSON for CI
bash design-qa/scripts/design-scan.sh [target-dir] --critical-only
```

Requires: ripgrep (`rg`). Optional: ast-grep (`sg`).

After the fast scan, run the manual gates below for judgment-based checks. Read the code, run each gate in order, report failures with line numbers and fixes.

---

## Gate 1: Anti-Slop (Critical)

| Check | Pass Condition |
|-------|---------------|
| No purple-blue gradients | Zero purple/blue/violet gradient combinations |
| No gradient text | Zero `bg-clip-text text-transparent bg-gradient-*` on metrics/headings |
| No glassmorphism | Zero decorative `backdrop-blur` (functional blur like overlays OK) |
| No hero metric template | Not using big-number-in-card with small-label-below pattern |
| No identical card grid | Cards in a grid have varied content/layout, not 3x identical template |
| No glow effects | Zero `shadow-*-*/glow` or colored `box-shadow` spread |
| No nested cards | Zero Card/panel inside other Card/panel |
| Font is intentional | Not using Inter/Roboto/Arial as a "just pick something" default |

## Gate 2: Typography

| Check | How to Verify |
|-------|--------------|
| Project type scale only | Zero arbitrary font sizes: `text-[*px]`, `text-[*rem]`, `font-size:` |
| No letter-spacing mods | Zero `tracking-*`, `letter-spacing` unless in design spec |
| Numeric data: tabular-nums | All `<td>`, `<th>` with numbers, prices, counts, dates use `tabular-nums` |
| Headings: text-balance | All `<h1>`-`<h6>` use `text-balance` or `text-pretty` |
| Line length controlled | Body text has `max-w-prose` or equivalent (45-75ch) |
| Max 3 font weights | More than 3 distinct `font-*` weights per view = flag |

## Gate 3: Color

| Check | How to Verify |
|-------|--------------|
| No hardcoded colors | Zero hex (`#[0-9a-f]`), `rgb(`, `hsl(`, `oklch(` in JSX/TSX |
| No pure black/white areas | `bg-black`, `bg-white`, `#000`, `#fff` on containers/pages = flag |
| No gray on colored bg | `text-gray-*` or `text-muted-*` on colored backgrounds = flag |
| Status colors semantic | green=success, red=error, amber=warning, blue=info. No inversions |
| Contrast ≥ 4.5:1 | WCAG AA. APCA: \|Lc\| ≥ 60 body, ≥ 45 large. OKLCH: ΔL ≥ 0.4 body |
| No inline oklch | Zero `bg-[oklch(...)]` in JSX. OKLCH belongs in CSS tokens only |
| Max 2 accent colors | Count distinct accent/brand colors per view |

## Gate 4: Spacing

| Check | How to Verify |
|-------|--------------|
| No magic numbers | Zero `p-[*]`, `m-[*]`, `gap-[*]` with non-standard values. Multiples of 4px only |
| Semantic spacing hierarchy | Sections > groups > items spacing. Consistent within page |
| No triple responsive padding | `p-2 md:p-4 lg:p-6 xl:p-8` = flag. One value per semantic context |
| 4px grid alignment | All spacing values are multiples of 4px (0.25rem) |

## Gate 5: Component Reuse

| Check | How to Verify |
|-------|--------------|
| Existing primitives used | Custom `<button>`, `<input>`, `<dialog>` when project equivalents exist = flag |
| No primitive mixing | Imports from multiple UI libraries in same file = flag |
| CVA for variants | Inline ternary chains for 3+ style variants = flag |
| data-slot attributes | Component roots missing `data-slot` = flag (if project convention) |

## Gate 6: Interaction States

| Check | How to Verify |
|-------|--------------|
| Hover on all interactives | Every `<Button>`, clickable card, table row action has hover styles |
| Focus visible | `:focus-visible` ring on buttons, inputs, links. NEVER `outline: none` without replacement |
| Disabled state | `disabled:opacity-*` + `disabled:pointer-events-none`. Not just visual |
| Loading states | Async actions show loading indicator. Buttons disable during submission |
| Icon-only: aria-label | Every icon-only button has `aria-label` |
| Destructive → AlertDialog | Delete/discard/overwrite uses AlertDialog, not Dialog or window.confirm |
| Errors inline | Errors next to trigger, not only in toast/banner |
| Focus restored on close | Dialog close restores focus to opener |
| Initial focus on open | Dialogs set initial focus on first interactive or explicit target |
| aria-expanded | Accordion/collapsible triggers have `aria-expanded` + `aria-controls` |
| aria-busy | Containers receiving async content use `aria-busy={true}` |
| Paste not blocked | No `onPaste={e => e.preventDefault()}` |

## Gate 7: Accessibility

| Check | How to Verify |
|-------|--------------|
| Semantic HTML | `<button>` for actions, `<a>` for nav. No `<div onClick>` |
| Heading hierarchy | h1→h2→h3, no skipping. One h1 per page |
| Alt text on images | Every `<img>` has `alt`. Decorative: `alt=""` |
| Form labels | Every input has `<label>` (via `htmlFor` or wrapping). Not just placeholder |
| Keyboard nav | Logical tab order, no traps, no `tabIndex` > 0 |
| ARIA live regions | Dynamic updates use `aria-live="polite"` or `role="status"` |
| Color not sole indicator | Status never by color alone — pair with icon, text, or pattern |
| Touch targets ≥ 44px | `min-h-11 min-w-11` or equivalent on mobile |
| prefers-reduced-motion | All animations respect `prefers-reduced-motion: reduce` |
| h-dvh not h-screen | Zero `h-screen`. Use `h-dvh` |

## Gate 8: Edge Cases

| Check | How to Verify |
|-------|--------------|
| Empty states designed | Every list/table/grid has empty state with message + CTA |
| Long text handled | `truncate`, `line-clamp-*`, or `break-words` on names/titles/descriptions |
| Flex/grid overflow | Flex children have `min-w-0`. Grid children have `min-w-0 min-h-0` |
| Numbers formatted | Large numbers use `Intl.NumberFormat` |
| Dates formatted | Dates use `Intl.DateTimeFormat` or relative format |
| Skeletons match layout | Skeleton shapes mirror actual content, not generic rectangles |
| Double-submit prevented | Form submit buttons disable during async |
| Error recovery | Every error state has retry action or clear path forward |

## Gate 9: Performance

| Check | How to Verify |
|-------|--------------|
| No layout animations | Zero `animate-*`/`transition-*` on width/height/top/left/margin/padding |
| No permanent will-change | `will-change` only within animation scope |
| No animated blur | No `backdrop-blur` + `transition`/`animate` together |
| Images lazy loaded | Below-fold: `loading="lazy"` |
| No layout shift | Async content has reserved space |
| Lists virtualized | 100+ items use virtual scrolling |
| Inputs debounced | Search/filter: 200-300ms debounce |
| Cleanup on unmount | useEffect cleanup cancels subscriptions, aborts fetch |
| No console.log | Zero `console.log/warn/error` not wrapped in dev check |

## Gate 10: Responsive

| Check | How to Verify |
|-------|--------------|
| Mobile layout works | No horizontal scroll. Content reflows to single column |
| Touch targets adequate | 44x44px minimum on mobile |
| No hidden core features | `hidden md:block` on essential functionality = flag |
| Logical CSS properties | `margin-inline-start/end` for RTL support |
| No fixed widths on text | `w-24`/`w-[200px]` on text containers = flag |
| Zoom not disabled | No `user-scalable=no` or `maximum-scale=1` |

## Gate 11: Error Resilience

| Check | How to Verify |
|-------|--------------|
| API errors by code | 401→login, 403→permission, 404→not found, 429→rate limit, 500→error |
| Error boundaries | React error boundaries around major sections |
| Double-submit prevented | Form submit disables during async |
| Optimistic rollback | Failed optimistic updates revert state + show error |

---

## Report Format

```markdown
## QA Report: [Component/Page Name]

### Critical (must fix before merge)
- **[Gate]: [Check]** — [File:Line] — [Issue and fix]

### High (fix soon)
- **[Gate]: [Check]** — [File:Line] — [Issue and fix]

### Medium (improve when touching this code)
- **[Gate]: [Check]** — [File:Line] — [Issue and fix]
```

**Severity:** Critical = accessibility violations, anti-slop, broken interaction states. High = missing loading states, hardcoded colors, no empty states. Medium = missing text-balance, non-debounced inputs, missing tabular-nums.

## Quick-Check (5 items for fast PR reviews)

1. No anti-slop patterns (Gate 1)
2. No hardcoded colors (Gate 3)
3. Focus visible on all interactives (Gate 6)
4. Empty states exist (Gate 8)
5. No layout animations (Gate 9)
