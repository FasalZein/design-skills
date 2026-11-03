# DESIGN: Harbor inbound (app-screen)
Direction: Quiet and exact, like a dock board: cool slate surfaces, one harbor-blue action color, and every time, ID and count set in a tabular mono face. The memorable choice: arrival time is the leading column everywhere, so the screen reads as a timetable.
Tree: Product / users and scene -> warehouse dispatchers at desk terminals in a lit office, working an 8-hour shift; light mode only; no phone users (fixture, 2026-11-03)
Tree: Product / structural archetype -> app shell: sidebar + content (fixture, 2026-11-03)
Tree: Product / visual density -> dense (fixture, 2026-11-03)
Tree: Product / aesthetic direction -> quiet, exact (fixture, 2026-11-03)
Tree: Product / unforgettable choice -> time-first timetable rows in IBM Plex Mono (fixture, 2026-11-03)
Tree: Product / swap test -> passes: owned slate neutrals, 6px radius and Plex replace the stock shadcn layer (fixture, 2026-11-03)
Tree: Primitive / token grade -> stock today; replace with the Tokens below (fixture, 2026-11-03)
Tree: Primitive / palette strategy -> restrained: tinted neutrals, one action color, five status roles (fixture, 2026-11-03)
Tree: Primitive / typeface -> IBM Plex Sans Variable + IBM Plex Mono, both installed (fixture, 2026-11-03)
Tree: Primitive / motion -> two durations, one easing, no springs or gestures (fixture, 2026-11-03)
Tree: Component / ShipmentTable -> the columns, states and copy below (fixture, 2026-11-03)
Tree: Component / StatusBadge -> a dot + label on a tinted chip (fixture, 2026-11-03)
Tree: Screen / Overview -> one prominent metric with context, the next-arrivals timetable, delayed shipments and dock occupancy (fixture, 2026-11-03)
Tokens: Write all tokens in src/index.css as CSS variables on :root, mapped through the existing `@theme inline` block. Light mode only: remove the .dark block. Component code uses semantic tokens only.
Tokens: Neutrals (hue 250): --background oklch(0.985 0.004 250); --foreground oklch(0.22 0.02 250); --card oklch(0.995 0.002 250); --card-foreground = --foreground; --popover = --card; --popover-foreground = --foreground; --muted oklch(0.955 0.008 250); --muted-foreground oklch(0.50 0.02 250); --accent = --muted; --accent-foreground = --foreground; --secondary = --muted; --secondary-foreground = --foreground; --border oklch(0.90 0.01 250); --input = --border.
Tokens: Action: --primary oklch(0.42 0.11 245); --primary-foreground oklch(0.985 0.004 250); --ring = --primary; --destructive oklch(0.55 0.19 27).
Tokens: Sidebar: --sidebar oklch(0.955 0.008 250); --sidebar-foreground = --foreground; --sidebar-accent oklch(0.91 0.014 250); --sidebar-accent-foreground = --foreground; --sidebar-border oklch(0.89 0.01 250); --sidebar-primary = --primary; --sidebar-primary-foreground = --primary-foreground; --sidebar-ring = --primary.
Tokens: Status roles, each a text color and a tint, exposed as Tailwind colors status-<name> and status-<name>-tint: scheduled oklch(0.50 0.02 250) on oklch(0.95 0.008 250); at-gate oklch(0.48 0.09 200) on oklch(0.95 0.03 200); unloading oklch(0.45 0.12 250) on oklch(0.95 0.03 250); received oklch(0.47 0.11 150) on oklch(0.95 0.04 150); delayed oklch(0.50 0.16 40) on oklch(0.95 0.04 40). Each text color meets 4.5:1 on its tint.
Tokens: Charts: --chart-1 to --chart-5 take the status text colors in the order unloading, received, at-gate, delayed, scheduled.
Tokens: Radius --radius 0.375rem (6px): cards and tables rounded-lg; buttons rounded-md; badges rounded-sm.
Tokens: Spacing: the Tailwind 4px scale, steps 1, 2, 3, 4, 6, 8 only (4 to 32px). Page padding 24px; gap between page blocks 24px; card padding 16px; gap inside a card 12px.
Tokens: Elevation: cards and tables have a 1px --border hairline and no shadow. No overlays are in scope.
Tokens: Motion: --motion-fast 120ms (hover, press, color changes); --motion-base 200ms (content that enters); --motion-ease cubic-bezier(0.2, 0, 0, 1). Map them to Tailwind's default transition duration and timing function. Under prefers-reduced-motion, keep color fades and drop every transform. No springs, gestures, drag or sheets.
Type: Faces: --font-sans 'IBM Plex Sans Variable' (package @fontsource-variable/ibm-plex-sans, OFL-1.1); --font-mono 'IBM Plex Mono' 400 and 500 (package @fontsource/ibm-plex-mono, OFL-1.1); both are in package.json. Remove the Geist import. Fallbacks: system-ui for sans, ui-monospace for mono.
Type: Scale: 12/16 (micro-labels, notes), 13/20 (table cells), 14/20 (body, controls), 16/24 (card titles), 20/28 (page titles, weight 600), 32/40 (the one prominent metric, mono, weight 500). Weights 400, 500, 600 only.
Type: Tracking: page titles -0.01em; body 0; uppercase micro-labels 0.04em. Times, IDs, counts, money and dock numbers use the mono face with tabular-nums.
Layout: Shell: sidebar 240px fixed + content minmax(0, 1fr); the content region owns the scroll. Sidebar header 56px, the same height as each screen's header row. Nav items 36px tall with a 16px icon.
Layout: Screen header row: 56px tall, the page title on the left, its controls on the right, a bottom hairline.
Layout: Breakpoints: designed for 1280 to 1920px. At 1024px and below the sidebar becomes a 56px icon rail with aria-labels. At 375px nothing overflows the viewport: tables scroll horizontally inside their own container.
Layout: Overview grid: two columns, 2fr and 1fr, gap 24px. Left: the metric, then "Next arrivals". Right: "Delayed", then "Docks". At 1024px and below: one column in the order metric, Delayed, Next arrivals, Docks.
Components: Use the installed shadcn components (button, card, badge, table, separator) and lucide-react icons. Add no UI library.
Components: StatusBadge (src/components/status-badge.tsx): props { status: ShipmentStatus }. A 6px dot in the status text color, then the label, on the status tint; 12/16, weight 500, rounded-sm, 2px 6px padding; one line, never truncated.
Components: ShipmentTable (src/components/shipment-table.tsx): props { shipments: Shipment[]; state: 'loading' | 'error' | 'ready'; onRetry: () => void }. Rows sorted by ETA ascending. Columns in order: ETA (HH:MM, mono), ID (mono), Carrier, Origin, Dock, Pallets (right-aligned, mono), Value (right-aligned, mono, de-DE EUR with 2 decimals, for example "48.210,50 €"), Status (StatusBadge). Row height 40px; 13/20 cells; header row sticky at the top of the scroll container, 12/16 uppercase micro-labels in --muted-foreground.
Components: ShipmentTable cells: the Carrier column has a fixed 220px width and truncates with the full name in a title attribute. A shipment with a note shows the note under the carrier name, 12/16 in the delayed text color, wrapping. A null dock reads "Unassigned" in --muted-foreground. Value and ETA never wrap.
Components: Overview metric (Overview screen): "Pallets to receive" as a 32/40 mono number, with one context line under it: "<received> of <expected> received · <delayed> delayed".
States: ShipmentTable: loading = 5 skeleton rows at the 40px row height in --muted, no spinner; empty (state 'ready' with zero rows) = one row spanning all columns with the empty copy; error = the error copy and a Retry button that calls onRetry; ready = the rows.
States: StatusBadge: one look per status; no hover state.
States: Overview: populated only; it reads the shipments fixture.
Copy: Page titles "Overview", "Shipments". Nav labels "Overview", "Shipments". Sidebar footer "Duisburg warehouse".
Copy: Status labels: scheduled "Scheduled"; at-gate "At gate"; unloading "Unloading"; received "Received"; delayed "Delayed".
Copy: ShipmentTable headers "ETA", "ID", "Carrier", "Origin", "Dock", "Pallets", "Value", "Status". Empty: "No inbound shipments today." Error: "Shipments could not load." with the button "Retry".
Copy: Overview sections "Next arrivals" (the scheduled shipments as timetable rows: ETA, ID, carrier, pallets), "Delayed" (each delayed shipment: ID, carrier, its note; a tinted delayed surface, no left border stripe; with none, the section reads "No delays."), and "Docks" (the open part, see below).
Copy: Words the product does not use: dashboard, seamless, effortless, insights, welcome, streamline.
Open for the build: the Docks section of the Overview screen. Its form is open: one row per dock (dock number, shipment ID, StatusBadge, or "Free"), or a 2x2 grid of dock tiles with the same content. Its data (docks 1 to 4, the shipment on each dock, "Free") is decided. Build the Overview screen without it and leave its grid cell empty.
