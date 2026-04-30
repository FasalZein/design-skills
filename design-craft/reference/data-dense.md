# Data-Dense UI (Tables, Dashboards, Financial Data)

## Table Rules

- MUST use `tabular-nums` on all numeric columns.
- MUST right-align numbers in table columns.
- MUST pair every metric with context: "Revenue: $2.4M (+12% MoM)" not just "$2.4M".
- MUST use conventional color coding: green = positive, red = negative. NEVER invert.
- SHOULD use compact row heights for data tables (36-40px rows).
- SHOULD show units/currencies inline, not in separate columns.
- SHOULD use subtle alternating backgrounds OR border-bottom for table rows. Never both.
- SHOULD offer compact mode for power users.
- NEVER truncate critical data (numbers, IDs). Truncate descriptions instead.

## Dashboard Composition

Choose a layout pattern based on the dashboard's purpose:

| Pattern | Structure | Best for |
|---------|-----------|----------|
| **Hero metric + grid** | One large KPI card spanning full width, 2-3 column grid below | Executive summaries, status overviews |
| **Side-by-side panels** | Equal or 2:1 split, each panel with its own data story | Comparison views, before/after, dual datasets |
| **Stream + detail** | Scrollable feed/list on left, expanded detail on right | Log viewers, ticket queues, email-style interfaces |
| **Dense grid** | Uniform small cards, 3-4 columns | Monitoring walls, multi-metric dashboards |

**Composition rules:**
- Every dashboard needs a **focal point** — a hero metric, a primary chart, or a status indicator that answers "how are we doing?" in one glance.
- Group related metrics spatially. Revenue metrics cluster together; user metrics cluster together. Don't interleave unrelated data.
- Fill the grid. If you have 5 items in a 3-column layout, make one item span 2 columns — don't leave a hole.
- Secondary metrics go in a summary bar (horizontal strip of 3-5 small stat cards) above or below the primary content.

## Visualization Choices

Pick the right format based on what the user needs to *do* with the data:

| Format | When to use | When NOT to use |
|--------|------------|-----------------|
| **Inline indicator** (colored dot, badge, arrow) | Status at a glance inside a table row or card | When the value matters more than the status |
| **Sparkline** (tiny line/bar, no axes) | Trend direction inside a compact space — table cells, stat cards | When the user needs to read exact values |
| **Mini chart** (small, 1-2 labels) | Trend + rough magnitude in a card or sidebar widget | When comparison or drill-down is needed |
| **Full chart** (axes, legend, tooltip, hover) | Primary data story that deserves a dedicated panel | When the data has < 3 points or fits better as a number |

**Chart essentials (when you use a full chart):**
- Label axes. Always. Include units.
- Show tooltips on hover with the exact value + context.
- Design the empty state (no data yet) and loading state (skeleton with the chart's aspect ratio).
- Limit to 5-7 series per chart. Beyond that, group or offer filters.
- Use the semantic color system — don't hardcode chart colors.

## Background Treatments by Aesthetic Direction

Data-dense UIs benefit from subtle surface variation to create depth and section boundaries. Match to the aesthetic direction from the planning gate:

| Aesthetic | Background options |
|-----------|-------------------|
| **Editorial / warm** | Warm off-white base (`oklch(0.97 0.01 80)`), subtle paper grain via CSS noise, tinted section bands |
| **Technical / stark** | Pure neutral base, faint dot grid (`radial-gradient` repeating pattern), thin rule lines between sections |
| **Friendly / soft** | Soft radial gradient behind hero metrics, pastel-tinted card surfaces, gentle shadow layering |
| **Bold / expressive** | Mesh gradient accent panels, aurora wash on header areas, high-contrast dark sections for emphasis |
| **Neutral / professional** | Alternating gray-50/white sections, minimal — rely on borders and spacing over color |

**Rules:**
- Background treatments mark section boundaries — they replace, not supplement, heavy divider lines.
- Limit to 2-3 distinct surface levels per view. More creates visual noise.
- Decorative backgrounds go behind low-density areas (headers, hero metrics). Dense data areas stay clean.
- For dark mode: reduce gradient intensity by 40-50%, never invert grain/texture patterns.

## Performance

- MUST lazy-load below-fold content and images.
- MUST prevent layout shift (reserve space for async content).
- MUST debounce search inputs (300ms).
- MUST use virtual scrolling for 100+ item lists.
- SHOULD use `contain: content` on independent sections.
- NEVER add decorative chart elements (3D effects, unnecessary grid lines, gradient fills on charts).
- NEVER animate layout properties.
- NEVER use `will-change` permanently.
- NEVER load all data upfront — paginate or infinite scroll.
