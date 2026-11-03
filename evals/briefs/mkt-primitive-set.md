# Build: the Harbor landing page primitive set: color, type, spacing, radius, elevation, focus and motion tokens

Headless design-builder run on the Harbor marketing eval fixture. The brief and DESIGN.md are the owner's word.

- **Part:** the Harbor landing page primitive set: the light color roles, the type faces and scale, spacing, radius, elevation, focus, the one breakpoint and the motion rule.
- **Scope level:** primitive. **Surface:** public-page. **Mode:** headless.
- **DESIGN.md:** {RUN_DIR}/DESIGN.md (the owner-approved direction A "Board"). Every decision this part needs is closed there ("Open for the build: none").
- **Start:** {START}
- **Run directory:** {RUN_DIR}. Work only in this directory. It is a git repository; commit to its current branch. Start every shell command with `cd {RUN_DIR}`, run git as `git -C {RUN_DIR}`, and delete scratch files with `trash`.
- **Browser:** allowed. Start the dev server with `npm run dev -- --port {PORT} --strictPort` and use port {PORT} only. Dependencies are installed, including the approved font packages of the DESIGN.md Type lines; add no package.
- **Checks:** `npm run typecheck` and `npm run build`.
- **Before and after:** the part restyles the existing page at / through the tokens.

## Scope

- **In:** the token layer in src/index.css and its font imports, as the Tokens and Type lines of DESIGN.md define them:
  - every light color role (ground, surface, raised, line, rule, control, track, text, muted, shell and its text roles, signal and its hover, text and pale roles, the neg roles, done-ink), with the shadcn roles mapped onto them;
  - the faces Barlow, Barlow Condensed and Newsreader from the installed @fontsource packages and IBM Plex Mono, with the Geist and IBM Plex Sans imports removed;
  - the five-step type scale (meta 13, body 17, lead 24, heading 32–40, display) and tabular figures on every number;
  - `--radius: 0`, no shadow on any resting element, the 2px focus outline with its 2px offset;
  - the 4px spacing steps (tile gap 8, tile inset 20, page margin 32 and 20, section gap 120 and 88) and the one breakpoint at 720px;
  - the Motion line: a still page, with no transition on hover or focus, and prefers-reduced-motion stopping all motion.
- **Also in:** one shared number-format helper for the de-DE formats of the Copy lines, in src/lib/: whole euros as "290 €", euros with cents as "48.210,50 €", and 24 h HH:MM times.
- **Out:** section and component code under src/sections and src/components, the #demo illustration and its timings, new components, copy, and the data in src/data/.

## Done

Done when every Tokens and Type line of DESIGN.md is in src/index.css, no Geist or IBM Plex Sans import or font name is left, the helper formats 290 as "290 €" and 48210.5 as "48.210,50 €", the page renders with the new tokens at 1440 and 375 width, typecheck and build pass, and the report is written.

## Finish

1. Commit your work to the current branch of the run directory at the end.
2. Write the report at `$HOME/.pi/artifacts/design-builder/eval-{RUN_NAME}/report.md` in design-craft's Report format, from the draft you keep there. Name each PASSES entry by the skill of its pass, one line per pass of the primitive level: `<skill> -> applied: <change>` or `<skill> -> n/a: <fact>`. ARTIFACT holds the report path.
3. Stop the dev server and every process you started.
4. End with the report as your final message, RESULT line first.
