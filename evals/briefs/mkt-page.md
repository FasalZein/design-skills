# Build: the Harbor landing page

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Harbor landing page: the hero sheet, features, the FAQ, the call to action and the footer, composed with #demo and pricing in the DESIGN.md order.
- **Scope level:** page (screen level). **Surface:** public-page. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved direction A "Board"). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the approved font packages of the DESIGN.md Type lines; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces the existing page at /.

## Scope

- **In:** src/App.tsx and the sections in src/sections/ (hero.tsx, features.tsx, faq.tsx, footer-cta.tsx), rebuilt as the Layout, Components, States and Copy lines of DESIGN.md define them:
  - No top bar: the hero sheet (#top) with its frames, caption strips and the black text panel carrying the wordmark, h1, sentence, "Book a demo" and the four page links;
  - the features mosaic with its figure tiles and photo tiles;
  - the FAQ: the question index with the answer pane, the first question selected on load;
  - the call-to-action row of three tiles and the footer of tiles, with the live Europe/Berlin time and the photo credits line;
  - the five photographs from src/assets/photos/, credited from src/assets/photos/credits.json;
  - the page order: hero, #demo, features, pricing, FAQ, call to action, footer.
- **Reference:** the approved prototype (Copy, "Prototype for reference").
- **Out:** the token layer (src/index.css), the page buttons and the pricing table, the #demo section (src/sections/product-demo.tsx and src/components/demo/), and the data in src/data/.

## Done

Done when the page shows every section in the DESIGN.md order and composition at 1440, 1024 and 375 width with no horizontal scroll, the four hero links reach their sections, the FAQ answer follows click, hover and focus, the footer shows the Duisburg time, the credits line names the five photographs, every action is a mailto link or an in-page anchor, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the screen level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
