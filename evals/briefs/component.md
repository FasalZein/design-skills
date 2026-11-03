# Build: ShipmentTable, the shipments table component, with the StatusBadge it renders

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** ShipmentTable, the shipments table component, with the StatusBadge it renders.
- **Scope level:** component. **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces existing UI on #/shipments.

## Scope

- **In:** src/components/shipment-table.tsx and src/components/status-badge.tsx as the Components, States and Copy lines of DESIGN.md define them; then replace the inline table in src/screens/shipments.tsx with ShipmentTable (state "ready", the shipments fixture). The approved primitive set is already in src/index.css: use its tokens.
- **Out:** the token layer (src/index.css), the Overview screen, the sidebar, and the shipments fixture data in src/data/shipments.ts.

## Done

Done when ShipmentTable renders its four states (loading, empty, error, ready) as DESIGN.md defines them, the Shipments screen at #/shipments uses it, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the component level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
