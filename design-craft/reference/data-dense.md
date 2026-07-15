# Data-Dense UI — Tables, Dashboards, Charts

Data UI answers questions. Every table, KPI, and chart earns its place by answering one — decoration that looks like data is the worst slop because it lies.

## Tables

- `tabular-nums` on all numeric columns; numbers right-aligned; units/currencies inline ("$2.4M"), not in separate columns.
- Every metric pairs with context: "Revenue: $2.4M (+12% MoM)" — never a bare number.
- Conventional color coding: green = positive, red = negative, never inverted, always with a redundant cue (arrow, sign) for color-blind users.
- Row height is a density decision: 24px extreme (monitoring walls only) · 32px compact · **40px default** · 48px comfortable · 64px multi-line/spacious. Density-toggle rule: [spacing.md](spacing.md).
- Row separation: subtle alternating backgrounds OR border-bottom — never both.
- Truncate descriptions, never numbers or IDs.
- When a table and a chart show the same data, coordinate them: hovering a row highlights the mark, and vice versa.

## Dashboard composition

| Pattern | Structure | Best for |
|---------|-----------|----------|
| **Hero metric + grid** | One large KPI spanning full width, 2-3 column grid below | Executive summaries, status overviews |
| **Side-by-side panels** | Equal or 2:1 split, each panel its own data story | Comparisons, before/after, dual datasets |
| **Stream + detail** | Scrollable feed/list left, expanded detail right | Logs, ticket queues, email-style tools |
| **Dense grid** | Uniform small cards, 3-4 columns | Monitoring walls, multi-metric dashboards |

- Every dashboard has a **focal point** answering "how are we doing?" in one glance — one hero metric or one KPI strip, never a wall of equal hero cards (guardrail).
- Group related metrics spatially; don't interleave revenue and user metrics.
- Fill the grid: 5 items in 3 columns → one spans 2. No holes.
- Secondary metrics: one horizontal KPI strip (single bordered container with an internal grid — not individual cards).

**KPI anatomy** — value (`tabular-nums`, largest element) + metric name + period ("last 30 days") + comparison context (+12% vs prior, with arrow) + optional real sparkline. A number alone is a poster, not a metric.

## Choosing the visualization

First by what the user does with it:

| Format | Use | Not |
|--------|------|-----|
| **Inline indicator** (dot, badge, arrow) | Status at a glance in rows/cards | When the value matters more than the status |
| **Sparkline** | Trend direction in compact space — legitimate only with real history, paired with current value, period, and delta | Placeholder squiggles; when exact values are needed → delta arrow instead |
| **Mini chart** (1-2 labels) | Trend + rough magnitude in a widget | When comparison or drill-down is needed |
| **Full chart** | The primary data story | Data with <3 points — that's a number, not a chart |

Then by the question:

| Question | Chart |
|---|---|
| How do categories compare? | Bar (horizontal when labels are long) |
| How did it change over time? | Line, area for cumulative volume |
| How far from target/plan? | Bar from the target baseline, bullet chart |
| What are the parts of the whole? | Stacked bar; pie/donut only for 2–3 parts where "about half" is the message |
| How is it distributed? | Histogram, box plot |
| Do two measures relate? | Scatter |
| Where geographically? | Map with sequential fill |

## Chart craft

- **Baselines:** bar/column charts start at zero — length IS the encoding. Line charts may use a non-zero range when the variation is the story; label the range visibly.
- Axes labeled with units; 2–8 tick labels; grid lines muted (they're furniture, not content).
- Direct-label series where space allows — a detached legend forces eye ping-pong; legends only past ~4 series.
- Limit to 5–7 series; beyond that, group, filter, or split.
- Palette by data type from semantic tokens, never hardcoded: **categorical** (distinct hues, ≤7), **sequential** (one hue, lightness ramp) for magnitude, **diverging** (two hues through neutral) for deviation. Redundant encoding (shape, pattern, label) alongside color.
- **Uncertainty:** when it changes interpretation (forecasts, small samples), show it — shaded band + plain-language note. False precision is a lie in axes clothing.
- Tooltips on hover with exact value + context; disclosed aggregation ("daily average") when data is rolled up.
- Decorative failures: 3D, dual y-axes by default, gradient/shadow fills on marks, axis-free "trend" art.

## Chart states & degradation

- Design empty ("No data for this range" + range picker), loading (skeleton at the chart's aspect ratio — no layout shift), and error states for every chart.
- Responsive degradation is a decision: full chart → mini chart (fewer labels) → sparkline + value → value + delta. Never a horizontally-scrolling axis chart on mobile.

## Chart accessibility floor

- Every chart has a text summary of its takeaway ("Revenue grew 12% over Q3, driven by…") — for screen readers and for scanners.
- The underlying data is reachable as a table (visible toggle or `<figure>` + accessible table).
- Live-updating charts announce meaningful changes via a polite live region, not per-tick.

## Performance

- Lazy-load below-fold panels; reserve space for async content (zero layout shift).
- Debounce search inputs (300ms); virtualize 100+ item lists; paginate — never load everything upfront.
- `contain: content` on independent sections.
- Never animate layout properties; no permanent `will-change`.

## Backgrounds

Dashboard surfaces come from the derived neutral scale — stop-50/stop-100 alternation, thin rules, at most one emphasis panel ([composition.md](composition.md) zone rules). Dense data areas stay clean; treatments go behind low-density chrome only.
