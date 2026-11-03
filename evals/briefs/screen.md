# Build: the Shipments screen at #/shipments, with the narrow top bar

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Shipments screen at #/shipments: the title row, the count tabs, the shipments table with its door selects, and the narrow-width top bar of the shell.
- **Scope level:** screen. **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved Hi-vis direction). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the three approved font packages of the DESIGN.md Build notes; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces the existing UI on #/shipments and the shell at <= 720px.

## Scope

- **In:**
  - src/screens/shipments.tsx as the Shipments, Tabs, Door select, States and Copy lines of DESIGN.md define it: the title row with its sub line computed from the data; the underline count tabs All, To come, At the doors, Received, Delayed with counts from the rows; the table sorted by expected time with every column of the Shipments line, de-DE values, StatusBadge, and the door select (or the plain door for received and unloading rows); the two-line rows at <= 720px; the loading, empty-tab and error states.
  - The door change: optimistic, "Saving…" while pending, rollback with "Couldn't change the door. Try again." and Retry on failure, and the busy-door warning ("Door 1 is busy 08:45–09:26 (IN-20434).") that still saves.
  - The shell at <= 720px (src/App.tsx and src/components/app-sidebar.tsx): the 56px top bar with the mark, "Harbor" and the Overview | Shipments switch, as the Narrow line of DESIGN.md defines it.
- **Out:** the token layer (src/index.css), StatusBadge and the Day line, the Overview screen and its Docks board, the desktop sidebar, and the data in src/data/shipments.ts.

## Done

Done when every tab shows its rows and its count, the table shows all 8 trucks with the delayed row's new time over "booked 08:00", a door change saves, a forced failure rolls back with the inline error, a busy door shows its warning, the screen renders at 1440, 1024 and 375 width with the top bar at 375, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the screen level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
