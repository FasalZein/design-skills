# Composition — Shells, Sidebars, Lockups, Section Headers

Public-page sections (features, pricing, proof, footer, background zones) follow design-taste-frontend's house rules and section library.

Recipes for composing complete surfaces. Every numeric value is a product-UI default: change it deliberately when the aesthetic is the feature, and prove the change in the live render (design-qa Gate 12). Each recipe ends with its completion check.

## 1. App shell & sidebar

Geometry:

- Sidebar: 240–280px expanded; 48–72px collapsed icon rail; fixed width (never `%`).
- Top bar: 56–64px, `grid-template-rows: auto 1fr`, content region owns the scroll.
- Content: `1fr` and `min-w-0` — the shell never scrolls as a whole.

```css
.shell { display: grid; grid-template-columns: 260px minmax(0, 1fr); height: 100dvh; }
.shell-collapsed { grid-template-columns: 56px minmax(0, 1fr); }
```

Sidebar anatomy, top to bottom:

1. **Header** — product identity; optional workspace switcher. Same height as the top bar so the shell's horizontal seam aligns.
2. **Scrollable nav** — the only scrolling part. Items are icon + 13–14px/500 label + optional count badge, 32–36px tall, full-width hit area, 8px inset from the sidebar edge. Group with uppercase micro-labels (kernel case rule) or spacing; ≤7 items per group.
3. **Footer bookend** — utilities (settings, help, user) pinned at the bottom. A sidebar that just trails off reads unfinished.

States: inactive items recede through a muted text color that still meets the 4.5:1 floor on the shell surface (icons 3:1); hover moves to full text color on a subtle tint; active = tonal fill (stop-100/200 of the shell's own scale) + full text color + medium weight — not a side-stripe. Color: same hue family as content, 1–2 lightness steps apart — no chroma cliff. A deliberately dark shell beside light content is legal only when the shell's hue family matches and nav text still meets contrast floors.

Mobile: the sidebar becomes a drawer (overlay + focus trap) or bottom nav (3–5 items) — never a squeezed 200px column.

**Complete when:** header/nav/footer all present; active state visible without color vision; collapsed rail keeps labels as tooltips/aria-labels; content column wins the squint test (blur your eyes — the primary element and the groupings must still read; used throughout this file).

## 2. Gutters & containers

- Page gutter: 16px mobile, 24–32px desktop. Pick per breakpoint and use everywhere — the #1 alignment bug is one section at 24px beside another at 32px.
- Top-level containers align to the page grid; children space themselves with tokens.
- `max-width` is a default (65–80rem for content pages), not a law — full-bleed sections still align their *content* to the same gutters.
- Vertical section spacing on marketing pages: vary it (kernel rhythm rule); app content regions keep constant 16–24px padding.

**Complete when:** every section's left text edge aligns at every breakpoint (overlay a vertical line in the screenshot to check).

## 3. Metadata / date lockup

For label + value pairs (detail panels, page headers, receipts, specs) use a semantic description list, two columns:

```css
.meta { display: grid; grid-template-columns: minmax(96px, 40%) 1fr; row-gap: 8px; column-gap: 16px; }
.meta dt { color: var(--muted-foreground); }
.meta dd { font-variant-numeric: tabular-nums; }
```

- Labels left column, values right, both top-aligned; values share one left edge — that edge is what reads as "aligned".
- Dates render in one format per surface, `tabular-nums`; relative time ("2h ago") pairs with the absolute value in a `title` attribute or adjacent caption.
- Absent values render an em dash (—), never blank, never "N/A" mixed with "-".
- Below ~480px the grid stacks: label above value, 4px gap, 12–16px between pairs.

For a single inline lockup (icon + label + date on one row): one flex row, `items-baseline` for text-with-text, `items-center` only when an icon is present, gaps from the ladder (8px), and the date gets `whitespace-nowrap`.

**Complete when:** all values share a left edge, dates share one format, no pair wraps mid-lockup at 375px.

## 4. Detail & settings surfaces

- Detail page: primary content (2fr) + supporting rail (1fr — metadata lockup, related items, activity). A single centered column on a wide viewport wastes the screen; a full-width one is unreadable.
- Settings: grouped sections, each `title + one-line description` on the left (or above) and controls on the right — the two-column settings grid (`minmax(180px, 30%) 1fr`). Rows 48–56px min-height with hairline separators; destructive zone last, visually separated.
- Actions live with what they act on: row-level actions at row end, page-level actions in the page header — one primary per view.

**Complete when:** every control's label states what it does (not "Enabled"); groups are scannable by title alone; save behavior (auto vs explicit) is consistent across the page.

## 4b. Section header row

Every titled region (Monitors, Incidents, Activity) uses one origin row: heading + optional one-line description on the left, the section's controls (filters, search, view toggle) on the right of the **same row**, baseline-aligned. Controls bind to the surface they act on — floating between two sections they belong to neither. Content (table, list, cards) starts one group unit (16–24px) below the taller side. Adjacent columns (list + aside) start at the same y — the section origin, not each element's preferred position.

**Complete when:** heading and controls share a baseline; content top edges align across all columns of the section.

## Shell patterns (copy-paste)

```css
.auto-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
.sticky-aside { position: sticky; top: 1rem; align-self: start; }
.content-aside { display: grid; grid-template-columns: minmax(0, 1fr) minmax(240px, 320px); }
```

**Progressive disclosure:** step-by-step flows over 12-field forms; sheets/drawers for contextual detail (parent stays visible); dialogs only for decisions that must block. ONE primary action per view.
