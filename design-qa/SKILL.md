---
name: design-qa
description: Binary pass/fail quality gates for UI code — run before shipping any component, page, or feature. Use when the user asks to QA, audit, review, or harden UI, before merging UI work, or after any design implementation to verify it. Covers anti-slop, accessibility, consistency, interaction states, performance, responsive, and live in-browser verification.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.css", "**/*.scss"]
---

# Design QA

Structured quality gate for UI code. Run against any component, page, or feature before shipping. Every check is binary — pass or fail. Report ONLY failures. Silence = quality.

## Fast Scan

```bash
bash "$PI_SKILL_DIR/scripts/design-scan.sh" [target-dir] --fix        # Full scan with fixes
bash "$PI_SKILL_DIR/scripts/design-scan.sh" [target-dir] --no-ui      # Skip upstream primitives
bash "$PI_SKILL_DIR/scripts/design-scan.sh" [target-dir] --json       # JSON for CI
bash "$PI_SKILL_DIR/scripts/design-scan.sh" [target-dir] --critical-only
```

If `$PI_SKILL_DIR` is unset, resolve the script relative to this SKILL.md's directory.

Requires: ripgrep (`rg`). Optional: ast-grep (`sg`).

After the fast scan, run the manual gates below for judgment-based checks. Read the code, run each gate in order, report failures with line numbers and fixes. Finish with Gate 12 (live verification) whenever the app can be rendered — the rendered page outranks source-level passes.

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
| No eyebrow scaffolding | Zero tiny uppercase tracked kickers repeated above every section; zero "01 / 02 / 03" section markers outside real sequences |
| No side-stripe accents | Zero `border-left`/`border-right` >1px used as colored accents |
| No ghost-cards | Zero elements pairing a 1px border with a soft box-shadow ≥16px blur |
| No over-rounding | Zero `border-radius` ≥24px on cards, sections, or inputs |
| No reflex cream bg | Body/section background is not a warm near-white picked "for warmth" (`--paper`/`--cream`/`--sand`-style tokens = flag) |
| Font is intentional | Not using Inter/Roboto/Arial as a "just pick something" default |

## Gate 2: Typography

| Check | How to Verify |
|-------|--------------|
| Project type scale only | Zero arbitrary font sizes: `text-[*px]`, `text-[*rem]`, `font-size:` |
| Letter-spacing by size only | Negative tracking only on display text (text-3xl+, floor -0.04em); positive tracking only on small uppercase labels. `tracking-wide+` on body text = flag |
| Numeric data: tabular-nums | All `<td>`, `<th>` with numbers, prices, counts, dates use `tabular-nums` |
| Headings: text-balance | All `<h1>`-`<h6>` use `text-balance` or `text-pretty` |
| Line length controlled | Body text has `max-w-prose` or equivalent (45-75ch) |
| Max 3 font weights | More than 3 distinct `font-*` weights per view = flag |
| Web fonts are woff2 | Owned font assets are `.woff2` (`.woff` legacy fallback only). `.ttf`/`.otf` served = flag |
| No faked bold/italic | `font-synthesis: none` set; every used weight/style has a loaded file |
| Mobile inputs ≥ 16px | Input text ≥ 16px on mobile viewports; zoom never disabled to compensate |

## Gate 3: Color

| Check | How to Verify |
|-------|--------------|
| No hardcoded colors | Zero hex (`#[0-9a-f]`), `rgb(`, `hsl(`, `oklch(` in JSX/TSX |
| No pure black/white areas | `bg-black`, `bg-white`, `#000`, `#fff` on containers/pages = flag |
| No gray on colored bg | `text-gray-*` or `text-muted-*` on colored backgrounds = flag |
| Status colors semantic | green=success, red=error, amber=warning, blue=info. No inversions |
| Contrast ≥ 4.5:1 | WCAG AA against actual rendered bg. APCA: \|Lc\| ≥ 75 body, ≥ 60 labels, ≥ 45 large. OKLCH: ΔL ≥ 0.4 body |
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
| Hit areas don't collide | Expanded hit targets of adjacent interactive controls never overlap |
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
| Truncation recoverable | Material truncated text reachable in full — tooltip, expansion, or detail view |
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
| No mount animation on defaults | Default-state `AnimatePresence` uses `initial={false}` (deliberate first-load entrances exempt) |
| No parent CSS-var animation | Parent custom properties not updated per-frame to drive child transforms |
| Hidden-tab timers pause | Timed toasts/auto-dismiss pause while document is hidden |
| Content visible without JS animation | No content whose visibility depends on a class-triggered transition firing (ships blank in hidden tabs/headless) |
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

## Gate 12: Live Verification (agent-browser)

Static gates read source; this gate checks the **rendered page**. Run whenever a dev server exists or can be started. Load the CLI workflow first: `agent-browser skills get core`. Then verify — every check binary:

| Check | Pass Condition |
|-------|---------------|
| Page renders | Screenshot at 1440px and 375px — no blank sections, no overlapping text, no horizontal scroll at 375px |
| Console clean | Zero errors and zero React/hydration warnings in the browser console on load and after primary interactions |
| Interaction states real | Hover + focus a primary button and screenshot — visible state change for each; tab through the page — focus ring visible on every interactive element |
| Headings render in order | Accessibility snapshot shows h1→h2→h3 with one h1 |
| Rendered contrast | Sample body text + its actual rendered background from the screenshot — ≥ 4.5:1 |
| Dark mode (if present) | Toggle and screenshot — no unreadable text, no pure-black bg, no invisible borders |
| Long content survives | Inject/enter a 100+ char string in a title or input — no layout break, truncation has full-value access |
| Empty state renders | Navigate to a list with no data — message + CTA visible, not a blank region |
| Reduced motion respected | Emulate `prefers-reduced-motion: reduce` — positional animations gone, content still visible |
| Mobile tap targets | At 375px, primary actions ≥ 44px and reachable without horizontal scroll |

Attach screenshot paths to the QA report. A failure here outranks any static-gate pass — the rendered page is the product.

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

**Severity:** Critical = accessibility violations, anti-slop, broken interaction states, live-verification failures (blank render, console errors, unreadable contrast). High = missing loading states, hardcoded colors, no empty states. Medium = missing text-balance, non-debounced inputs, missing tabular-nums.

## Quick-Check (6 items for fast PR reviews)

1. No anti-slop patterns (Gate 1)
2. No hardcoded colors (Gate 3)
3. Focus visible on all interactives (Gate 6)
4. Empty states exist (Gate 8)
5. No layout animations (Gate 9)
6. Renders clean at 1440px + 375px with zero console errors (Gate 12)
