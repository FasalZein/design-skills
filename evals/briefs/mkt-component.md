# Build: the pricing table and the page buttons

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the pricing table of the pricing section, with the three page buttons it uses (primary, secondary, ink).
- **Scope level:** component. **Surface:** public-page. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved direction A "Board"). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the approved font packages of the DESIGN.md Type lines; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces the plan cards in the pricing section (#pricing) and restyles the existing buttons.

## Scope

- **In:**
  - the three buttons of the Buttons line in src/components/ui/button.tsx: primary (signal fill, on-signal text 600), secondary (surface fill, 1px control border) and ink (shell fill, shell-text), each 48px and square; hover changes colour only, inside `@media (hover: hover)`; the 2px focus outline with its 2px offset.
  - src/components/pricing-table.tsx as the Pricing line of Layout, the "Pricing table" line of Components and the pricing strings of Copy define it, fed with the plans in src/data/landing.ts: a real table element with scope attributes; the heading "Pricing per site" in the top-left cell; one column per plan with name, price ("290 €", "790 €", "By contract") and unit; the ten rows from "For" to "Trial" with the cell words of Copy ("Included", "Not included", "5", "25", "Unlimited", "30 days, no card", "Not offered"); zebra rows on raised; the Network column on signal-pale from header to buttons; the plan buttons in the last row (primary for the featured Network plan, secondary for Site and Enterprise) with their mailto links; at <= 720px one block per plan with item / answer pairs, Network on signal-pale.
  - wire it in: src/sections/pricing.tsx renders the pricing table in place of the plan cards.
- **Reference:** the approved prototype (Copy, "Prototype for reference"); its parts/4-js.html holds the row-by-plan answers.
- **Out:** the token layer (src/index.css), the other sections, the #demo slot, and the data in src/data/.

## Done

Done when the pricing section shows one table with the three plans and the ten rows, the prices "290 €", "790 €" and "By contract", Network on signal-pale with the primary button, mailto links on the three buttons, at 1440 width and as one block per plan at 375 width, the page's other buttons render in the new variants, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the component level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
