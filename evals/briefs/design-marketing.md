# Build: every decided part of the Harbor landing page

Headless design run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word; no one answers questions in this run.

- **Work:** build every decided part of DESIGN.md bottom-up through design-builders, and report the one open part to the owner.
- **Scope level:** product. **Surface:** public-page, with the product-demo slot as an illustration. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Its "Open for the build" line names the one open part; every other decision is closed.
- **Parts:** the primitive set; PricingCard; the sections hero, product demo, features, pricing and footer call to action; the whole page.
- **Run directory:** {RUN_DIR}. You and every design-builder work only in this directory. It is a git repository on branch main.
- **Browser:** allowed. Your own dev server: `npm run dev -- --port {PORT} --strictPort`. Give each design-builder its own port from {PORT}+1 to {PORT}+4 and the same command with that port. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Builders:** up to 4 design-builders at once. A part goes to a builder only after the lower-level parts it uses passed Verify.

## Scope

- **In:** every decided part, primitives first, then components, then sections, then the page.
- **Out:** the FAQ section: report it with a DECISION NEEDED block and build none of it.

## Builder briefs

Give each design-builder a brief in this shape: the part, its scope level and surface, mode headless, the DESIGN.md path, the run directory, browser allowed with its port, the checks, In and Out scope, a Done condition (the part at 1440 and 375 width; the page also at 1024), and these finish steps: commit only its own files to main (when git reports index.lock, wait and retry); write its report in design-craft's Report format at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}-<part>/report.md`, with each PASSES entry named by the skill of its pass; stop every process it started; end with the report as its final message.

## Done

Done when every decided part is built and passed its builder's Verify, the FAQ section is in a DECISION NEEDED block and nowhere in the code, typecheck and build pass on main, and the report is written.

## Finish

1. Commit any work of your own to main at the end.
2. Write the report at `$HOME/.pi/artifacts/design/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Put the DECISION NEEDED block for the FAQ section above the RESULT line. Name each PASSES entry by the skill of its pass: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. List each builder's report path under FILES or OPEN. ARTIFACT holds the report path.
3. Stop the dev server, every process you started and every builder still running.
4. End with the report as your final message: the DECISION NEEDED block, then the report, RESULT line first.
