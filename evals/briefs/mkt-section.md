# Build: the #demo section: the animated stageshow illustration of the Docks board

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the product-demo section #demo: the heading row, the stageshow illustration of the Docks board (story A "Send to door") in the empty slot, and the Bar length row with the Stop/Replay button.
- **Scope level:** component group (a section of a page). **Surface:** public-page, with the product-demo slot as an illustration. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved direction A "Board"). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the approved font packages of the DESIGN.md Type lines; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part fills the empty slot #demo on the existing page.

## Scope

- **In:** src/sections/product-demo.tsx and src/components/demo/, as the #demo lines of DESIGN.md define them (Tree, Layout, Components, States, Copy):
  - the stageshow kit copied from ~/.agents/skills/stageshow/kit into src/components/demo/kit/, imported from its index.ts; the scene's styles in one plain CSS file beside the scene, nested under the stage class;
  - the heading row: h2 "One Tuesday, four doors" and its one sentence;
  - two Stage components: the wide design (1376 x 480) at a slot of 1170px and wider, the compact design (350 x 452) centred below; the host picks the design by the slot width, mounts it after `document.fonts.ready` and keeps the last non-zero slot width;
  - the scene: the Docks board and the "Needs a door" rail of the Harbor app, with times, IDs, carriers and pallets from src/data/shipments.ts;
  - the script, played once when the stage is in view: the cursor (wide) or the touch dot (compact) sends IN-20434 to door 1 and the board answers;
  - the states: opening, playing, ended, stopped, the poster, reduced motion (the poster as a still, no cursor, no button) and the switch of design at a slot width of 1170px;
  - the role="img" wrapper with the aria-label of the Components line, the stage aria-hidden;
  - the row under the stage: "Bar length: 20 min + 1.7 min per pallet." and the Stop/Replay button (the page's secondary button).
- **Reference:** the approved, filmed prototype and its scene source (Copy, "#demo prototype for reference").
- **Out:** the token layer (src/index.css), the page buttons and the pricing table, the hero and the other sections, the page layout around the slot (the slot stays where it is), and the data in src/data/.

## Done

Done when the slot plays the "Send to door" script once and rests on the poster, Stop shows the poster at once and Replay plays the script again, reduced motion shows the poster as a still with no button, the stageshow gate (film.mjs --gate) ends "rehearsal passed" at 1440 and 390 on the real page, the wide design renders at 1440 width and the compact design at 1024 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the Screen and the Component levels (a component group runs both): `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. Put the gate output and REHEARSAL.md in the stage/ folder beside the report. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
