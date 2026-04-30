# Data-Dense UI (Tables, Dashboards, Financial Data)

- MUST use `tabular-nums` on all numeric columns.
- MUST right-align numbers in table columns.
- MUST pair every metric with context: "Revenue: $2.4M (+12% MoM)" not just "$2.4M".
- MUST use conventional color coding: green = positive, red = negative. NEVER invert.
- SHOULD use compact row heights for data tables (36-40px rows).
- SHOULD show units/currencies inline, not in separate columns.
- SHOULD limit primary dashboards to 4-5 key visualizations. Tabs/drill-down for depth.
- SHOULD use subtle alternating backgrounds OR border-bottom for table rows. Never both.
- SHOULD offer compact mode for power users.
- NEVER add decorative chart elements (3D effects, unnecessary grid lines, gradient fills).
- NEVER truncate critical data (numbers, IDs). Truncate descriptions instead.

## Performance

- MUST lazy-load below-fold content and images.
- MUST prevent layout shift (reserve space for async content).
- MUST debounce search inputs (300ms).
- MUST use virtual scrolling for 100+ item lists.
- SHOULD use `contain: content` on independent sections.
- NEVER animate layout properties.
- NEVER use `will-change` permanently.
- NEVER load all data upfront — paginate or infinite scroll.
