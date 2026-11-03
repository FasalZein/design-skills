# DESIGN: Harbor (inbound shipments, Duisburg dock)
Direction: Hi-vis, loud and legible: concrete grey, a black shell and safety orange only where a person must act or a door is working; the memorable choice is the Docks section, with doors 01 to 04 in large condensed numerals, a Now time and a No door group (its form is open for the build).

Tree:
- Product / evidence -> dmd create (style vault, 6 refs: Orderful, Dock, Dollar Shave Club, Sleeve, Aboard, Prismic; low relevance, kept in .design-md/style-context.json); design-taste-frontend app draw (achromatic-ledger, framed-sheet, data-terminal, true-black-flat, accent-ladder); researcher brief on dock tools, /Users/tothemoon/.pi/artifacts/researcher/dock-tools-research-2026-11-03.md (round 1, 2026-11-03)
- Product / overall look -> C Hi-vis, chosen over A Ladeliste, B Nachtschicht, D Kontor, E Magnettafel (round 1, 2026-11-03)
- Product / parts taken -> IBM Plex Mono for shipment IDs and clock times only (from A); a dark wall-screen mode as a later remap (from B); Newsreader serif for page and section titles (from D) (round 1, 2026-11-03)
- Product / initial mode -> light first; dark is a semantic-token remap for the dock-office wall screen (round 1, 2026-11-03)
- Product / archetype -> app shell: labelled sidebar + content (round 1, 2026-11-03)
- Product / unforgettable choice -> the Docks section (form open for the build) (round 1, 2026-11-03)
- Product / palette strategy -> committed: black shell + safety orange on action and active marks; tinted concrete neutrals (round 1, 2026-11-03)
- Domain / dock doors -> 4 doors, numbered 1 to 4 (round 1, 2026-11-03)
- Domain / bar length -> estimated unloading: 20 min + pallets x 60 / 34.8 min, rounded (Yardo estimator via the researcher brief) (round 1, 2026-11-03)
- Domain / board window -> 06:00 to 16:00 (round 1, 2026-11-03)
- Screen / Overview -> O2 Board + rail (round 2, 2026-11-03)
- Screen / Shipments -> S1 Tabs + table (round 2, 2026-11-03)
- Screen / narrow shell -> N3 Switch (round 2, 2026-11-03)
- Interaction / door assignment -> a door select on the row; no drag in this scope (round 2, 2026-11-03)
- Copy / numbers -> German format through Intl de-DE (48.210,50 €); words stay English (round 2, 2026-11-03)
- Component / StatusBadge -> B3 Action first (round 3, 2026-11-03)
- Component / stat-metric -> M2 Day line (round 3, 2026-11-03)
- Primitive / density -> Dock floor at every width (round 3, 2026-11-03)
- Primitive / motion -> Feedback: only the bar move on a door change (round 3, 2026-11-03)
- Primitive / dark remap -> as shown in round 3 (round 3, 2026-11-03)
- Primitive / color roles and type scale -> approved as shown on the round 3 Primitives screen (round 3, 2026-11-03)
- Screen pass / laws-of-ux -> 4 rules added below: one primary per view, Undo for Send, optimistic door change with rollback, busy-door warning (design agent, approved with this file, 2026-11-03)
- Approval -> DESIGN.md approved as written; font packages approved; all round prototypes kept (2026-11-03)

Tokens:
- Color, light (src/index.css :root; map the shadcn roles onto these): ground #e6e5e1 (page); surface #ffffff (panels, board, table); raised #f2f1ee (hover, group rows); line #d3d1cb (panel edges, dividers); rule #e6e5e1 (row and lane rules); control #8d8a82 (input and button borders, 3.4:1); track #e6e5e1 (ratio tracks, received bars); text #141414 (18.4:1); muted #55534e (7.7:1); shell #141414, shell-text #f3f2ef, shell-muted #b9b6ae, shell-hover #242424; signal #f05a00 (3.4:1 mark: unloading bar, at-gate badge fill, primary button, active nav, Now line, selected tab); on-signal #141414 (text on signal fills); signal-text #b84300 (5.5:1, orange words such as the Now label); signal-pale #ffe3d1 (selected row); signal-ink #6e2600; neg #c8281e (5.6:1, delay marks); neg-text #a3201a (7.6:1); neg-pale #fde4e1, neg-ink #8a1b15 (delayed badge); done-ink #3a3935 (received mark). Focus: 2px solid text color, 2px offset.
- Color, dark (`.dark` or [data-mode="dark"], same role names): ground #121211; surface #1b1b19; raised #252522; line #33322e; rule #282724; control #6b6862; track #33322e; text #f3f2ef; muted #b3b0a8; shell #0b0b0a, shell-text #f3f2ef, shell-muted #b3b0a8, shell-hover #1f1f1d; signal #f26a1b; on-signal #141414; signal-text #ff8f52; signal-pale #3a2214; signal-ink #ffb48a; neg #ef5b4f; neg-text #ff8a80; neg-pale #3a1a17; neg-ink #ffb3ab; done-ink #d6d3cc.
- Radius: 0 on every surface, control, badge and bar (`--radius: 0`).
- Elevation: 1px line on panels; no shadow at rest; selects use the native menu.
- Spacing (4px grid): tight 4 (inside a badge); item 8 (icon to label, rail rows); group 16 (panel inset, narrow gutter); section 20 (between blocks, grid gap); page 32 (desktop side gutter), 24 top.
- Density (Dock floor, every width): controls 44px (buttons, door selects, tabs 48px); table rows 56px; board lanes 56px; bars 32px; No door sub-lane pitch 40px; nav rows 40px; body 15/22.
- Motion: one animation. When a truck's door changes (select or Send), its board bar moves from its old position to the new one in 200 ms, cubic-bezier(0.2, 0, 0, 1), as a transform (FLIP). Under prefers-reduced-motion the bar jumps. Nothing else moves; hover and focus change color without transition; no entrance animations.

Type:
- Faces: Barlow 400/500/600 (text, OFL); Barlow Condensed 700 (figures and door numbers, OFL); Newsreader 500 (page and section titles, OFL); IBM Plex Mono 400/500 (shipment IDs and clock times only, OFL, already a dependency). Remove the Geist import.
- Scale: h1 30/1.15 Newsreader 500, tracking -0.01em (26px at <= 720px); h2 20/24 Newsreader 500; figures 32/1.05 Barlow Condensed 700; door numbers 30/1 Barlow Condensed 700; body 15/22 Barlow 400; labels and meta 13/16 Barlow 400 muted; badge 12/16 Barlow 500 (600 when filled); ID and time 13 Plex Mono; axis ticks 12 Plex Mono muted.
- Tabular figures on every number. Sentence case. No tracked capitals.

Layout:
- Shell: grid 240px sidebar + minmax(0, 1fr), height 100dvh; the content region scrolls. Sidebar on the shell color: header 64px (Harbor mark: a door with three slats and an orange sill, plus "Harbor" in Barlow Condensed 700 20px and "Duisburg · inbound" 12px), nav Overview and Shipments (16px outline icons, 40px rows, active = signal fill with on-signal text 600), footer "Early shift · 06:00–14:00".
- Narrow (<= 720px), N3: no sidebar; a 56px top bar on the shell color with the mark, "Harbor" and an Overview | Shipments switch (two 44px targets, active = signal fill); 16px gutters; the title-row primary button goes full width (44px).
- Overview: title row (h1 "Overview", sub "Tuesday 3 November · updated 07:55", primary action at the right, bottom-aligned); the finding line under it (max 72ch); then grid minmax(0, 1fr) 340px, gap 20. Left column: the Day line, then the Docks section. Right column: the "Needs a door" rail. At <= 720px the rail moves under the Docks section.
- Shipments: title row (h1 "Shipments", sub "8 inbound today · 164 pallets · 320.307,85 €"); underline count tabs All, To come, At the doors, Received, Delayed (2px signal indicator, counts computed from the rows); one table sorted by expected time: Expected (Plex Mono; a delayed row shows the new time over "booked 08:00"), Shipment (Plex Mono), Carrier (delay note under it in neg-text), Origin, Pallets (right), Value (right, de-DE EUR), Status (badge), Door (select, or the plain door for received and unloading). At <= 720px each row becomes two lines: carrier + badge, then "time · ID · pallets · value", then the door select.

Components:
- StatusBadge (B3 Action first): a fill only where a person must act. At gate: signal fill, on-signal text 600, dark dot. Delayed: neg-pale fill, neg-ink text 600, neg diamond. Unloading: signal dot + ink word, no fill. Scheduled: 1px muted ring + muted word. Received: done-ink dot + muted word. Height 22px, padding 0 (8px when filled), nowrap, never squeezed (flex: none). Words: Scheduled, At gate, Unloading, Received, Delayed.
- Day line (M2 stat): one unboxed row of 4 figures: "<n> trucks today", "<n> of <total> pallets received", "<n> of 4 doors free", "<n> delayed" (figure in neg-text when above 0). Figures Barlow Condensed 700 32px, words muted; items split by 1px line with 20px padding. At <= 720px a 2x2 grid. Every value is computed from the rows.
- Needs a door rail: panel with group heads "At the gate" (count) and "No door yet" (count). Rows: "<time> · <carrier>" over "<ID> · <n> pallets" (delayed: "· delayed, booked <time>" in neg-text), door select at the right. The at-gate row carries "Send to door <n>" as an outlined secondary button.
- Door select: native select with an accessible name "Door for <ID>"; options "No door", "Door 1" to "Door 4"; a door whose slots overlap the truck's span reads "Door n (busy)".
- Buttons: primary = signal fill, on-signal text 600, 44px; secondary = surface fill, 1px control border, 44px; no other variants in scope.
- Tabs: text buttons, 48px, muted label + ink count; selected = ink label, 2px signal underline on a full-width 1px line.

States:
- Docks section: loading = doors 1–4 with their numbers and flat bars at real size, no shimmer; empty = "No trucks are booked for today. Doors 1–4 are free."; error = "Couldn't load today's bookings. Last updated <time>." + Retry; populated as above.
- Needs a door rail: loading = 3 rows of flat bars; empty = "Every truck has a door."; error = "Couldn't load arrivals." + Retry.
- Day line: loading = flat bars at figure size; error follows the board's error (same request).
- Shipments table: loading = 5 rows of flat bars at 56px pitch, header shown; empty tab = one sentence per tab ("No delayed trucks today.", "Nothing received yet today.", "No truck is at a door.", "No more trucks to come today.", All: "No trucks are booked for today."); error = "Couldn't load shipments. Last updated <time>." + Retry.
- Door change: optimistic; the bar moves at once (motion rule), the select is disabled with "Saving…" while pending; on failure the row and bar roll back, and an inline error under the select reads "Couldn't change the door. Try again." with Retry; the user's choice stays in the select.
- Busy door: choosing a busy door shows an inline warning under the select, "Door 1 is busy 08:45–09:26 (IN-20434).", and still saves.
- Send to door: when a truck is at the gate, the title-row primary reads "Send <ID> to door <n>"; after it runs, the button reads "Undo: <ID> back to the gate" until the next action. With no truck at the gate the title row has no primary button.

Copy:
- Exact strings: "Overview", "Shipments", "Docks", "Needs a door", "At the gate", "No door yet", "No door", "<n> to place", "Free until <time>", "Unloading · <n> min left", "Unloading · over estimate", "Free", "Free all day", "No bookings", "Now <time>", "<ID> booked <time>", "Bar length: 20 min + 1.7 min per pallet", "Send <ID> to door <n>", "Undo: <ID> back to the gate", "Early shift · 06:00–14:00", "Duisburg · inbound".
- Finding line template: "<ID> (<carrier>, <n> pallets) is at the gate, <m> min before its <time> slot. Door <n> is free. <k> trucks have no door yet; the first arrives at <time>." Each figure comes from the data.
- A door is "Door 1" in text and "01" on the board. Missing values print as an em dash (—). Times are 24 h HH:MM. Relative figures name their baseline ("+2 h 40 min" next to "booked 08:00").
- Words the product does not use: "Dashboard", "Ramp", "Records", "Items", "Welcome", "Seamlessly", "Streamline".

Build notes:
- Data: add `newEta?: string` to Shipment and set it to "10:40" for IN-20433; the board, the Day line and the table read it instead of parsing the note. The clock is the device time; the prototype used 07:55.
- Fonts: add @fontsource/barlow 5.3.0, @fontsource/barlow-condensed 5.3.0 and @fontsource-variable/newsreader 5.3.0 (OFL-1.1); the owner approved these packages (2026-11-03).
- Prototype for reference: /Users/tothemoon/.pi/artifacts/design/harbor-grill/rounds/round-3/index.html (it carries the tokens, the board layout code and the FLIP move).

Open for the build: the Docks section of the Overview screen. Its data is decided: doors 1 to 4 and a No door group, every truck with its time span (bar length 20 min + 1.7 min per pallet), the Now time, the delayed truck at its newEta and its booked time, and the Docks lines of States, Motion and Copy. Its form is open: a board with a 06:00 to 16:00 time axis and one lane per door, or a door list (each door with its number, its state and its slots). Build the Overview screen without it and leave its place in the left column under the Day line empty.
