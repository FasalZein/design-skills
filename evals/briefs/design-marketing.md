# Build: every decided part of the Harbor landing page

Headless design run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word; no one answers questions in this run.

- **Work:** build every decided part of DESIGN.md bottom-up through design-builders, and report the one open part to the owner.
- **Scope level:** product. **Surface:** public-page, with the product-demo slot as an illustration. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved direction A "Board"). Its "Open for the build" line names the one open part; every other decision is closed, including #demo as a stageshow illustration.
- **Parts:** the primitive set; the page buttons and the pricing table; the sections hero, #demo (the stageshow illustration of the Docks board), features, pricing, call to action and footer; the whole page.
- **Run directory:** {RUN_DIR}. You and every design-builder work only in this directory. It is a git repository on branch main. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Your own dev server: `npm run dev -- --port {PORT} --strictPort`. Give each design-builder its own port from {PORT}+1 to {PORT}+4 and the same command with that port. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Builders:** up to 4 design-builders at once. A part goes to a builder only after the lower-level parts it uses passed Verify.

## Scope

- **In:** every decided part, primitives first, then components, then sections, then the page.
- **Out:** the FAQ section: report it with a DECISION NEEDED block and build none of it.

## Builder briefs

Give each design-builder a brief in this shape: the part, its scope level and surface, mode headless, the DESIGN.md path, the run directory with the shell rules above, browser allowed with its port, the checks, In and Out scope, a Done condition (the part at 1440 and 375 width; the page also at 1024), and these finish steps: commit only its own files to main (when git reports index.lock, wait and retry); write its report in design-craft's Report format at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}-<part>/report.md`, with each PASSES entry named by the skill of its pass; stop every process it started; end with the report as its final message.

## Stage hand-off

These values close the illustration surface's hand-off fields for #demo; DESIGN.md decides the rest of #demo. Put them word for word into the #demo builder's brief, with field 9 for that builder's part name.

1. Host page and its ground color: this landing page at /; ground #e6e5e1 (DESIGN.md Tokens). The stage has no plate: its panels sit on the ground.
2. Slot width: the content width, max 1376px. The wide design (1376 x 480) at a slot of 1170px and wider; the compact design (350 x 452) below 1170px, centred, also on phones (DESIGN.md Layout, #demo).
3. Medium: once in view, resting on its result, with Stop/Replay; the poster as a still under reduced motion.
4. Product: Harbor. The stage's tokens: the app colors in DESIGN.md Tokens and the Harbor app DESIGN.md that the Tree's Brand line names.
5. Fidelity: realistic: the app's real components, data and copy (DESIGN.md Components, "#demo illustration").
6. Story beats and the poster frame: the "#demo script, played once" line of Components; the poster is the Poster of the #demo States line.
7. Nearest gold example: table-edit (stageshow examples/table-edit), the gold the approved rehearsal copied: play="once", Replay as the reset, the dependent change a beat after the cause, Roll and States for the changed labels.
8. Kit import path in the host: src/components/demo/kit/ (import from its index.ts).
9. Artifact folder (absolute) for film output and REHEARSAL.md: $HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}-<part>/stage/ (expand $HOME to an absolute path).
10. design-qa allowlist rows for the kit/ folder and the demo folder: the two rows of design-qa "Stageshow stages" for `(^|/)kit/` and `(^|/)demo/`, in design-qa.allowlist at the run directory root.
11. Reviewer: none. Write "fresh-eye review: not done, no reviewer" in REHEARSAL.md and in OPEN, as the approved rehearsal did.

## Done

Done when every decided part is built and passed its builder's Verify, the FAQ section is in a DECISION NEEDED block, the existing FAQ section stays as it is (no form of the open decision is built), typecheck and build pass on main, and the report is written.

## Finish

1. Commit any work of your own to main at the end.
2. Write the report at `$HOME/.pi/artifacts/design/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Put the DECISION NEEDED block for the FAQ section above the RESULT line. Name each PASSES entry by the skill of its pass: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. List each builder's report path under FILES or OPEN. ARTIFACT holds the report path.
3. Stop the dev server, every process you started and every builder still running.
4. End with the report as your final message: the DECISION NEEDED block, then the report, RESULT line first.
