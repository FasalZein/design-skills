# Build: StatusBadge and the metric figure of the Day line

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** StatusBadge (B3 Action first) and the metric figure of the Day line (M2 stat), as two components.
- **Scope level:** component. **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved Hi-vis direction). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the three approved font packages of the DESIGN.md Build notes; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the parts replace existing UI: the badges on #/shipments and the four stat cards on #/overview.

## Scope

- **In:**
  - src/components/status-badge.tsx: the five states (Scheduled, At gate, Unloading, Received, Delayed) as the StatusBadge line of DESIGN.md defines them: fills only for At gate and Delayed, the dot, ring and diamond marks, 22px height, nowrap, never squeezed.
  - src/components/day-line.tsx: the Day line of four figures ("<n> trucks today", "<n> of <total> pallets received", "<n> of 4 doors free", "<n> delayed"), each value computed from the rows of src/data/shipments.ts, the delayed figure in neg-text when above 0, a 2x2 grid at <= 720px, and its loading and error states from the States lines.
  - Wire both in: StatusBadge for the status cell on #/shipments, the Day line in place of the stat cards on #/overview.
- **Out:** the token layer (src/index.css), the rest of both screens, the sidebar, and the data in src/data/shipments.ts.

## Done

Done when StatusBadge renders all five states and the Day line its populated, loading and error states as DESIGN.md defines them, the figures match the data (8 trucks today, 26 of 164 pallets received, 1 delayed; the free doors follow the device clock), both show on their screens at 1440 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the component level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
