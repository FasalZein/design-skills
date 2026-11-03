# Build: the Overview screen at #/overview

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Overview screen at #/overview.
- **Scope level:** screen. **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces existing UI on #/overview.

## Scope

- **In:** src/screens/overview.tsx, rebuilt as the Overview lines of DESIGN.md define it (Tree, Layout, Components, Copy): the metric, "Next arrivals", "Delayed" and "Docks". Use the approved primitive set in src/index.css, the installed shadcn components and the existing StatusBadge in src/components/status-badge.tsx.
- **Out:** the token layer (src/index.css), the Shipments screen, the sidebar, StatusBadge, and the shipments fixture data in src/data/shipments.ts.

## Done

Done when the Overview screen shows the metric, "Next arrivals", "Delayed" and "Docks" with the fixture data in the DESIGN.md grid at 1440 width and in one column at 1024 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the screen level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
