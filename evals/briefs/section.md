# Build: the Docks board, the section of the Overview screen

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Docks board: the Docks section of the Overview screen, with its board bars and the StatusBadge it uses.
- **Scope level:** component group (a section of a screen). **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved Hi-vis direction). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the three approved font packages of the DESIGN.md Build notes; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part adds a section to the existing UI on #/overview.

## Scope

- **In:** src/components/docks-board.tsx as the Docks board, Board bar, States, Motion and Copy lines of DESIGN.md define it, fed with src/data/shipments.ts:
  - the 224px label column with the door number ("01" to "04") and its state text ("Free until 08:45", "Unloading · 11 min left", "Free all day");
  - the 06:00 to 16:00 time axis with ticks every 2 h, a tick hidden within 40 min of Now;
  - the Now line at the device time with its "Now <time>" label;
  - the lanes for doors 1 to 4, then the "No door" lane whose bars pack into sub-lanes so none overlap;
  - bar length from the estimate (20 min + 1.7 min per pallet), each bar state, the ID inside or beside the bar, the title attribute;
  - the delayed truck at its newEta with a dashed tick and "<ID> booked <time>" at its booked time;
  - the loading, empty and error states, and the door list it becomes at <= 720px;
  - the one animation: a bar moves to its new place in 200 ms when its truck's door changes (FLIP), and jumps under prefers-reduced-motion.
- **Also in:** render the board on #/overview in the left column under the Day line (or where the Day line goes when it is not built yet), with the section meta "Bar length: 20 min + 1.7 min per pallet".
- **Out:** the token layer (src/index.css), StatusBadge and the Day line, the "Needs a door" rail and the title row, the Shipments screen, the sidebar, and the data in src/data/shipments.ts.

## Done

Done when the board shows doors 01 to 04 and the "No door" lane with every truck of the data at its time, the Now line and the delayed truck's booked tick, the loading, empty and error states render, a door change on a bar (a prop change is enough) moves the bar as the Motion line defines, the board renders on #/overview at 1440 and 1024 width and as the door list at 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the Screen and the Component levels (a component group runs both): `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
