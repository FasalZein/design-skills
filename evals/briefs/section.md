# Build: the Docks section of the Overview screen

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Docks section of the Overview screen: DocksSection with the StatusBadge it renders.
- **Scope level:** component group (a section of a screen). **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part adds a section to existing UI on #/overview.

## Scope

- **In:** src/components/docks-section.tsx as the Docks lines of DESIGN.md define it (Tree, Components, States, Copy), fed with the shipments fixture; then render it on #/overview under "Next arrivals" (one import and one element in src/screens/overview.tsx). The approved primitive set is in src/index.css and the approved StatusBadge in src/components/status-badge.tsx: use both.
- **Out:** the token layer (src/index.css), StatusBadge, the rest of the Overview screen and its grid, the Shipments screen, the sidebar, and the shipments fixture data in src/data/shipments.ts.

## Done

Done when the Docks section shows docks 1 to 4 with their shipment ID and StatusBadge or "Free", as DESIGN.md defines them, on #/overview at 1440 and 375 width, the every-dock-free state renders, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the Screen and the Component levels (a component group runs both): `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
