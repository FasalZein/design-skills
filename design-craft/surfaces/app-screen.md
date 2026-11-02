# Surface: app-screen

A screen people work in: tools, dashboards, settings, forms, inboxes, editors. Read this file down to the "Recipes" heading, once. Read a recipe only when its trigger fires: `rg -n '^### ' <this file>` gives each recipe's line, then read from that line to the next recipe.

## Project Context Scan

Run it while you gather facts. Tokens are material, not a direction. Find the token layer (components.json, Tailwind v4 `@theme` or tailwind.config, the global CSS `:root`, DESIGN.md), catalog it, then grade it:

- **Owned**: the values belong to this product: tinted neutrals, a deliberate radius, a chosen face. Reuse them. Derive only the missing roles, in harmony with the existing hues.
- **Stock**: library defaults or values copied from another app: shadcn's chroma-0 neutrals (`oklch(L 0 0)` or `0 0% L%` on `--foreground`, `--primary`, `--muted-foreground`), `--radius` 0.5rem or 0.625rem, Inter or Geist as the only face. Stock tokens are never a direction. The token changes are a primitive-level decision in the design tree; once decided, change neutral hue, radius and type in the token layer before composing, and keep component code on semantic tokens.
- **None**: greenfield. The palette is a primitive-level decision; the Primitive palette pass (better-colors) answers it.

The design-qa scanner reports a stock token layer as `STOCK_TOKEN`.

Done when the draft names the grade and, for stock, the token changes.

## Design Decision Gate

These are the app-screen decisions in the design tree. Each one is closed by DESIGN.md or the brief, or it is open. Attended: the open ones join the frontier. Headless: an open one is an open part (DECISION NEEDED). Write the gate line into the report draft before the first edit.

1. **Structural archetype**: app shell (sidebar + content), focused tool (centered workspace), dashboard (data-dense grid), or editorial (long-form reading). A marketing page is the public-page surface.
2. **Visual density**: sparse, balanced or dense.
3. **Aesthetic direction**: a specific adjective pair, never "modern" or "clean".
4. **Initial mode from the physical scene**: one sentence on who uses this, where, under what light, in what mood. It picks light or dark; the other mode remaps the semantic tokens.
5. **Typeface**: from the brief's world, with a verified source and license. A stock face (Inter, Geist, DM Sans, Roboto) needs a stated reason.
6. **Token grade and palette strategy**: the scan's grade, plus restrained, committed, full palette or drenched.
7. **Composition**: the shell recipe below.
8. **The unforgettable choice**: if someone saw 10 similar screens today, which one concrete visual or structural choice makes them remember this one?
9. **Swap test and category reflex**: if a template layout and Inter would go unnoticed in its place, the choice defaulted; remake it. If the palette or look is guessable from the product category alone, or from category plus anti-reference ("fintech but not navy, so terminal dark"), rework it.

Done when the gate line answers all nine, each with its source (DESIGN.md, the brief, or a verdict). "Existing" or "brownfield" answers none of items 3, 8 and 9: the existing tokens are material, and the answer names the direction built from them.

## Recipes

Every number is a product-UI default. Change it when DESIGN.md names the change, and prove it in the live checks.

### App shell and sidebar (trigger: the part is a shell, a sidebar or a top bar)

- Sidebar: 240-280px expanded; 48-72px collapsed icon rail; a fixed width, never %.
- Top bar: 56-64px, `grid-template-rows: auto 1fr`; the content region owns the scroll.
- Content: `1fr` and `min-w-0`; the shell never scrolls as a whole.

```css
.shell { display: grid; grid-template-columns: 260px minmax(0, 1fr); height: 100dvh; }
.shell-collapsed { grid-template-columns: 56px minmax(0, 1fr); }
```

Sidebar anatomy, top to bottom:
1. **Header**: product identity, an optional workspace switcher. Same height as the top bar, so the shell's horizontal seam aligns.
2. **Scrollable nav**: the only scrolling part. Items are icon + 13-14px/500 label + an optional count badge, 32-36px tall, full-width hit area, 8px inset from the sidebar edge. Group with uppercase micro-labels or spacing; at most 7 items per group.
3. **Footer bookend**: utilities (settings, help, user) pinned at the bottom.

States: inactive items recede through a muted text color that still meets 4.5:1 on the shell surface (icons 3:1); hover moves to the full text color on a subtle tint; active is a tonal fill from the shell's own scale + full text color + medium weight. The shell takes the content's hue family, 1-2 lightness steps apart. A dark shell beside light content passes when the hue family matches and nav text meets the contrast floors.

Mobile: the sidebar becomes a drawer (overlay + focus trap) or a bottom nav of 3-5 items.

Gutters: 16px on mobile, 24-32px on desktop, one value per breakpoint for every section. Top-level containers align to the page grid; full-bleed sections align their content to the same gutters. App content regions keep a constant 16-24px padding.

```css
.auto-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
.sticky-aside { position: sticky; top: 1rem; align-self: start; }
.content-aside { display: grid; grid-template-columns: minmax(0, 1fr) minmax(240px, 320px); }
```

Done when header, nav and footer exist; the active state reads without color vision; the collapsed rail keeps labels as tooltips or aria-labels; every section's left text edge aligns at every breakpoint; and the content column wins the squint test (blur your eyes: the primary element and the groups still read).

### Lockups and section header rows (trigger: label and value pairs, dates, icon and text rows, or a titled region with controls)

Label and value pairs (detail panels, page headers, receipts, specs) use a description list, two columns:

```css
.meta { display: grid; grid-template-columns: minmax(96px, 40%) 1fr; row-gap: 8px; column-gap: 16px; }
.meta dt { color: var(--muted-foreground); }
.meta dd { font-variant-numeric: tabular-nums; }
```

- Labels left, values right, both top-aligned; all values share one left edge.
- Dates use one format per surface, with `tabular-nums`; a relative time ("2h ago") pairs with the absolute value in a `title` attribute or a caption.
- An absent value renders an em dash (—).
- Below ~480px the grid stacks: label above value, 4px gap, 12-16px between pairs.

An inline lockup (icon + label + date on one row) is one flex row: `items-baseline` for text with text, `items-center` only when an icon is present, an 8px gap, and `whitespace-nowrap` on the date.

A titled region (Monitors, Incidents, Activity) has one origin row: the heading on the left, the region's controls (filters, search, view toggle) on the right of the same row, baseline-aligned. Content starts 16-24px below the taller side. Adjacent columns (list + aside) start at the same y.

Done when all values share a left edge, dates share one format, no pair wraps mid-lockup at 375px, heading and controls share a baseline, and content top edges align across the region's columns.

### Detail and settings surfaces (trigger: a detail page or a settings page)

- Detail page: primary content (2fr) + a supporting rail (1fr: metadata lockup, related items, activity).
- Settings: grouped sections in a two-column grid (`minmax(180px, 30%) 1fr`), the group title on the left and its controls on the right. A group carries a description line only when it adds information the controls cannot show. Rows 48-56px min-height with hairline separators; the destructive zone comes last and stands apart.
- Actions sit with what they act on: row actions at the row end, page actions in the page header, one primary action per view.
- Contextual detail opens in a sheet or drawer (the parent stays visible); a dialog only for a decision that must block. A long form becomes steps.

Done when every control's label states what it does (never "Enabled"), the groups scan by title alone, and save behavior (auto or explicit) is one rule for the page.

### Loading and async states (trigger: the part fetches data or runs an action that leaves the client)

Every async data region designs four states: loading, populated, empty, error. Timing picks the loading treatment:

| Wait | Treatment |
|---|---|
| < 1s | No blocking indicator; in-control feedback only (a button's pending state) |
| 1-4s | A skeleton in the shape of the incoming content, or an in-control spinner for actions |
| > 4s | Measurable progress when the work reports it (percent, steps, "3 of 12 files") |
| > 10s | Explicit status + a way to cancel or leave; the work survives navigation |

- Skeleton: the real content's shape and count (3 expected rows, 3 skeleton rows), the same reserved space (zero shift on arrival), `aria-hidden="true"` on the skeleton and `aria-busy="true"` on the region with a polite status. The skeleton leaves on the first data.
- An action runs idle, pending, then success or error. Pending: the control is disabled against a second activation, its label shows progress ("Saving…"), focus stays on it. Success shows where the action happened. Error appears at the point of action with a retry, and the user's input stays.
- An empty message inside a data region sits where the first row would sit, top-anchored, and the region collapses to the message's height. A full-page empty may center.
- Optimistic updates only for safe, reversible, frequent actions (toggle, star, reorder): apply at once, roll back visibly on failure, show pending on timeout, reconcile to the server's value.

Done when each async region shows all four states behind the state toggle and the loading treatment matches its expected wait.

### Charts (trigger: the part is a chart)

- Every chart designs empty ("No data for this range" + the range picker), loading (a skeleton at the chart's aspect ratio, zero layout shift) and error states.
- Responsive degradation is a decision: full chart, then mini chart (fewer labels), then sparkline + value, then value + delta. On phones, degrade rather than scroll an axis chart sideways.
- Each chart has a text summary of its takeaway ("Revenue grew 12% over Q3, driven by…"), its data reachable as a table (a visible toggle or a `<figure>` with an accessible table), and live updates announced through a polite live region for meaningful changes only.

Done when the chart has its three extra states, a degradation step per breakpoint, a summary and a data table.

### CJK text (trigger: the product serves Chinese, Japanese or Korean users)

- Per-language stacks chosen by the `lang` attribute; platform stacks ("PingFang SC", "Hiragino Sans", "Noto Sans JP", "Apple SD Gothic Neo") over webfonts, which are megabytes unless subset.
- Tracking stays 0 on CJK glyphs; `text-spacing-trim` and `text-autospace` as progressive enhancements.
- Measure ~40 glyphs per line; body line height 1.7-1.9. Test mixed Latin and CJK lines with real localized strings.

Done when each language has its stack and the live checks include a localized screenshot.

### Symptoms (trigger: a screenshot reads wrong and the cause is unclear)

| Symptom | Likely cause | Fix |
|---|---|---|
| Decent but generic | Stock tokens, equal-weight cards, uniform padding | Grade the tokens; remove a widget, merge a region, flatten one surface |
| Everything competes | Several primary-weight elements | One dominant element; mute the rest |
| Cramped | Uniform tight spacing | Larger gaps between sections, tight gaps inside groups |
| Empty despite content | Oversized gaps, thin type | Tighter item spacing, more weight on key elements |
| Floaty content islands | `min-height` + centering, stacked margins | Height from content; the parent owns gaps through `gap` |
| Ragged two-column section | Heading, controls and aside start at different y | One section origin row (Lockups recipe) |
| Clips on real content | Fixed heights | `min-h` + `overflow-y-auto` on scroll regions |
| Sidebar fights content | Too bright, equal weight | Dim the shell 1-2 steps; inactive items recede, still at the contrast floor |

Done when the symptom's fix is applied and re-shot.
