# Build: the Harbor landing page

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Harbor landing page: header, hero, features, pricing, FAQ and footer call to action.
- **Scope level:** page (screen level). **Surface:** public-page. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces the existing page at /.

## Scope

- **In:** src/App.tsx and the sections in src/sections/ (hero.tsx, features.tsx, pricing.tsx, faq.tsx, footer-cta.tsx), rebuilt as the Page, Section, Layout and Copy lines of DESIGN.md define them. Use the approved primitive set in src/index.css, the installed shadcn components and the approved PricingCard in src/components/pricing-card.tsx.
- **Out:** the token layer (src/index.css), PricingCard, the content of the product-demo slot (src/sections/product-demo.tsx stays empty; place the slot where the Hero line puts it), and the copy in src/data/landing.ts.

## Done

Done when the page shows every section in the DESIGN.md order and composition, with the empty demo slot in the hero, at 1440, 1024 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the screen level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
