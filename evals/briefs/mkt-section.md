# Build: the product-demo section: an animated illustration of the Harbor timetable

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the product-demo section: an animated illustration of the Harbor timetable in the empty slot #demo.
- **Scope level:** component group (a section of a page). **Surface:** public-page, with the product-demo slot as an illustration. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part fills the empty slot #demo on the existing page.

## Scope

- **In:** src/sections/product-demo.tsx and the src/sections/demo/ folder, as the Product demo lines of DESIGN.md define them (Tree, Components with the eleven hand-off fields, the demo data, States). The approved primitive set is in src/index.css: the stage takes its look from these tokens.
- **Out:** the token layer (src/index.css), the hero and the other sections, the page layout around the slot (the slot stays where it is), and the page copy.

## Done

Done when the slot plays the story of DESIGN.md as a loop and shows the poster frame under reduced motion, the stage gate passes, the host page renders at 1440 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the Screen and the Component levels (a component group runs both): `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. Put the stage output and REHEARSAL.md in the stage/ folder beside the report. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
