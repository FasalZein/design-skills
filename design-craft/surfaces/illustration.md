# Surface: illustration

Faux product UI for a page slot: a still, or a short cursor animation. Read this file once, whole.

## Stageshow runs the stage

Load stageshow, whole, then the references its Workflow names at each of its steps, one per read. Stageshow's workflow (medium, look, story, example, screen, choreograph, rehearse) runs inside this workflow's build of the slot. This workflow keeps the facts, Verify of the host page, and the Report.

## Hand-off fields

Find these while you gather facts and write them into the report draft before the first edit. A field the brief and DESIGN.md leave open is a design decision: attended, it joins the frontier; headless, it is an open part.

1. Host page and its ground color.
2. Slot width, and whether a phone column needs `compact` (358 wide).
3. Medium: still, loop, once in view, or hover.
4. Product, and the source of its tokens (DESIGN.md path or site URL).
5. Fidelity: minimal, standard or realistic.
6. Story beats and the poster frame.
7. Nearest gold example.
8. Kit import path in the host.
9. Artifact folder (absolute) for film output and REHEARSAL.md.
10. design-qa allowlist rows for the kit/ folder and the demo folder.
11. Reviewer: who gives the fresh-eye review, or "none".

## Rules inside the stage

- Stageshow's rules win inside the stage: window chrome, placeholder bars, literal colors and illustrative data. The floor's rows on fake chrome, proof and color stop at the stage edge.
- The host page's DESIGN.md sets the page; the stage's look comes from the product's tokens.
- Allowlist the kit/ folder and the demo folder for the design-qa scanner, in its format `CATEGORY<TAB>PATH_REGEX<TAB>REASON`, one row per category.
- Run `npm install` once in the stageshow skill folder. Run film.mjs from that folder against the host URL, with every output path inside the artifact folder.
- Write REHEARSAL.md into the artifact folder, outside the project.
- No reviewer: write "fresh-eye review: not done, no reviewer" in REHEARSAL.md and in OPEN.

## Verify

- The stage: `film.mjs --gate` ends with "rehearsal passed".
- The host page: the Verify rows and agent-browser-chrome screenshots, with the allowlist rows applied.

Done when the gate line, the host checks and REHEARSAL.md are in the report.
