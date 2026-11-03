# Build: the Harbor primitive set: color, type, spacing, radius and motion tokens

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Harbor primitive set: color, type, spacing, radius and motion tokens.
- **Scope level:** primitive. **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md. Every decision this part needs is closed there ("Open for the build: none").
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.

## Scope

- **In:** the token layer in src/index.css and its font imports, as the Tokens and Type lines of DESIGN.md define them. The two existing screens (#/overview and #/shipments) change only through the tokens.
- **Out:** component and screen code under src/components and src/screens, new components, and copy.

## Done

Done when every token and type line of DESIGN.md is in src/index.css, the Geist import and the .dark block are gone, both screens render with the new tokens at 1440 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the primitive level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
