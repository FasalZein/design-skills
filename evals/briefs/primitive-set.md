# Build: the Harbor primitive set: color, type, spacing, density, radius and motion tokens

Headless design-builder run on the Harbor eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Harbor primitive set: the light and the dark color roles, the type faces and scale, spacing, density, radius, elevation, focus and the one motion token set.
- **Scope level:** primitive. **Surface:** app-screen. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved Hi-vis direction). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the three approved font packages of the DESIGN.md Build notes; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part restyles the existing UI on #/overview and #/shipments through the tokens.

## Scope

- **In:** the token layer in src/index.css and its font imports, as the Tokens and Type lines of DESIGN.md define them:
  - every light color role in `:root` and every dark role under `.dark` and `[data-mode="dark"]` (the dark wall-screen remap, same role names), with the shadcn roles mapped onto them;
  - the faces Barlow, Barlow Condensed, Newsreader and IBM Plex Mono from the installed @fontsource packages, and the Geist import removed;
  - the type scale, tabular figures on every number;
  - `--radius: 0`, the 1px line elevation with no shadow, the 2px focus ring;
  - the spacing steps and the Dock floor density: 44px controls, 48px tabs, 56px table rows and board lanes;
  - the motion tokens for the one bar move (200 ms, cubic-bezier(0.2, 0, 0, 1)) and its prefers-reduced-motion jump.
- **Also in:** one shared number-format helper for the de-DE formats of DESIGN.md (EUR as 48.210,50 €, pallet counts, 24 h HH:MM times through Intl de-DE), in src/lib/.
- **Out:** component and screen code under src/components and src/screens, new components, copy, and the data in src/data/shipments.ts.

## Done

Done when every Tokens and Type line of DESIGN.md is in src/index.css for light and dark, no Geist import or Geist font name is left, the de-DE helper formats 48210.5 as "48.210,50 €", both screens render with the new tokens at 1440 and 375 width in light and with `.dark` on the root, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the primitive level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
