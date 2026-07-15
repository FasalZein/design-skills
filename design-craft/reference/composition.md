# Composition — Shells, Sidebars, Lockups, Sections

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

States: inactive items at reduced opacity (60–70% text, 40–50% icons); hover restores full opacity on a subtle tint; active = tonal fill (stop-100/200 of the shell's own scale) + full opacity + medium weight — not a side-stripe. Color: same hue family as content, 1–2 lightness steps apart — no chroma cliff. A deliberately dark shell beside light content is legal only when the shell's hue family matches and nav text still meets contrast floors.

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

## 5. Feature sections

Choose by content, not template:

- **Asymmetric anchor:** one large cell (product surface, screenshot, or live demo) + 2–4 supporting cells of different sizes. The grid earns cells with differentiated content — different lengths, media, depth.
- **Editorial rows:** alternating 60/40 text-media rows; each row makes one claim with one proof (screenshot, metric, quote).
- **Dense capability list:** for many small features — two-column text list with icon + one-line each, no cards.

Icon-heading-two-lines × N identical cells is the pattern to escape (guardrail table). Cells with real content of honestly different weight cannot look identical.

**Complete when:** no two adjacent cells share identical structure and length; every claim has a proof or a product surface.

## 6. Pricing

Derive from the actual pricing model: usage-based → calculator or rate table; seat-based → per-seat row with volume breaks; flat tiers → comparison. A 3-tier grid is legal only when the product genuinely has 3 comparable tiers — then differentiate honestly (feature deltas, not green-check walls), highlight one tier by elevation/weight (not a "Most Popular" pill), and put the billing toggle above with both prices visible.

**Complete when:** every number is real or clearly labeled example; the recommended plan is visually decidable in 5 seconds; annual/monthly math is consistent.

## 7. Social proof

Layers, in credibility order: named customer + quantified outcome ("cut deploy time 40% at Linear") → attributed quote with name/role/company → real logo row (≤6, grayscale, permission assumed). Marquees, invented counts, and stock-face avatars are the guardrail's fake-proof row — with nothing real, ship nothing; an honest product section beats fabricated trust.

**Complete when:** every proof element names a real, checkable source.

## 8. Footer

Mirror the real information architecture: link only pages that exist, grouped by actual site areas; add utilities (theme toggle, language, legal, socials that exist). One row of links + copyright is a complete footer for a small product. The four-column Product/Company/Resources/Legal scaffold with dead links is the template tell.

**Complete when:** every link resolves; column count ≤ real content groups.

## 9. Background zones & section variety

All section backgrounds come from one neutral scale (kernel rule). Legal variety within that:

| Aesthetic | Treatment |
|---|---|
| Editorial | stop-50 base, stop-50/stop-100 alternation, hairline rules between blocks |
| Technical / stark | stop-50 base, thin rules, border treatments |
| Friendly / soft | soft radial stop-50→stop-100, gentle shadow layering |
| Bold / expressive | ONE dark (stop-950) or primary-tinted emphasis panel per page; rest neutral |

Plus: density shifts (airy hero → dense grid → spacious close), one emphasis panel, real media, or a bounded brand texture ([spacing.md](spacing.md) texture rules). Flat white void everywhere is visual poverty; a different color per section is the opposite failure.

**Complete when:** section boundaries are perceptible in the squint test without any hue change between sections.

## Shell patterns (copy-paste)

```css
.auto-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
.sticky-aside { position: sticky; top: 1rem; align-self: start; }
.content-aside { display: grid; grid-template-columns: minmax(0, 1fr) minmax(240px, 320px); }
```

**Progressive disclosure:** step-by-step flows over 12-field forms; sheets/drawers for contextual detail (parent stays visible); dialogs only for decisions that must block. ONE primary action per view.
