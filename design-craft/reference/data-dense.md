# Data-Dense UI — Charts

Tables, KPIs, chart choice, dashboard composition, and the tells of generated dashboards: design-taste-frontend `references/app-screens.md`. This file keeps the chart floors it does not carry.

## Chart states

- Design empty ("No data for this range" + range picker), loading (skeleton at the chart's aspect ratio, zero layout shift), and error states for every chart.
- Responsive degradation is a decision: full chart → mini chart (fewer labels) → sparkline + value → value + delta. On mobile, degrade instead of scrolling an axis chart horizontally.

## Chart accessibility floor

- Every chart has a text summary of its takeaway ("Revenue grew 12% over Q3, driven by…") — for screen readers and for scanners.
- The underlying data is reachable as a table (visible toggle or `<figure>` + accessible table).
- Live-updating charts announce meaningful changes via a polite live region, not per-tick.
