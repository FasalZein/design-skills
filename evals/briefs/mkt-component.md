# Build: PricingCard, the plan card of the pricing section

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** PricingCard, the plan card of the pricing section.
- **Scope level:** component. **Surface:** public-page. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part replaces existing UI in the pricing section (#pricing).

## Scope

- **In:** src/components/pricing-card.tsx as the PricingCard lines of DESIGN.md define it (Components, States), fed with the plans in src/data/landing.ts; then replace the inline cards in src/sections/pricing.tsx with PricingCard, one per plan. The approved primitive set is already in src/index.css: use its tokens.
- **Out:** the token layer (src/index.css), the other sections, the product-demo slot, the pricing section heading and grid, and the plan data in src/data/landing.ts.

## Done

Done when the three plans render as PricingCards (the featured look for Network, "Custom" for Enterprise) as DESIGN.md defines them, at 1440 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the component level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
