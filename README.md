# design-skills

AI agents build UI from the median of their training data: purple gradients, glass on every card, a centered hero over three identical cards, fake "Trusted by 10,000+" proof, `h-screen` that breaks on iOS Safari. These skills replace that with a design workflow: the owner decides the direction from prototypes, agents build the decided parts, and every part passes checks on its source and its rendered page.

## What is in the repository

| Path | What it is |
|---|---|
| `design-craft/` | The design workflow. Injected into the design and design-builder agents. |
| `design-qa/` | Verify: static checks (a scanner and Gates 1–11) and live checks (Gate 12 and render probes). |
| `laws-of-ux/` | User-psychology rules per decision area, with an audit. |
| `build-design-library/` | A workflow to build a full product design library. The owner starts it for a library project. |
| `evals/retro/` | Scripts that measure how design sessions used the skills. |
| `docs/specs/design-workflow.md` | The specification of the workflow (decisions D1–D22). |
| `scripts/verify.sh` | The repository verify command. |

All four skills are explicit-only (`disable-model-invocation: true`). The model does not load them by itself.

## design-craft

design-craft is a workflow, not a reference book. Every run follows these steps. Each step ends on a done-condition the agent can check.

1. **Sort the work.** The agent names three things:
   - the **surface**: app-screen, public-page or illustration (see below). A library build is not a surface: the agent stops and reports it, and the owner starts build-design-library.
   - the **scope level**: product, screen or flow, component group, component, or primitive (color, type, spacing, radius and motion tokens).
   - the **mode**: attended (the owner answers through ask_user) or headless (the brief is the owner's word).

   The agent then writes a report draft and updates it after each step.
2. **Craft floor.** Rules every part meets: let the UI explain itself, wrap before truncating, one card system per screen, height from content, tracking floor -0.03em, and a table of reflexes (slop patterns) with what to build instead. DESIGN.md, the brief and the surface file take precedence over the floor.
3. **Design grilling** (attended). The design agent interviews the owner over a **design tree**. The tree starts at the scope level and goes down only through levels with open decisions. DESIGN.md, approved tokens and existing components close decisions. Each round asks the whole frontier (every open decision whose parents are closed) at once. Each question shows prototypes and a recommended answer: one standalone HTML file per round, with a picker and real product data, screenshot at 1440 and 375 width, then opened for the owner. The agent records each verdict in DESIGN.md as the owner makes it. Grilling is done when the frontier is empty and the owner approves DESIGN.md. Children find the facts: scout reads the existing code, researcher finds reference products, competitors and domain data. Round mechanics and the DESIGN.md template are in `design-craft/direction.md`.
4. **Bottom-up build.** Primitives first, then components, then screens. A part is decided when every decision it needs is closed. The design agent sends decided parts to design-builders with the DESIGN.md path; independent parts go in parallel. A builder never decides an open part. A headless run stops on an open part with a `DECISION NEEDED` block, and the parent asks the owner.
5. **Craft passes.** Each level has a fixed list of passes. A pass is one skill used as a lens on the part. Each pass records `applied: <change>` or `n/a: <observable fact>` in the PASSES line of the report. A pass that does not apply loads nothing.
6. **Verify.** The design-qa static checks run on every part. The live checks run when the brief allows a browser. A part passes Verify before a higher level uses it.
7. **Report.** A fixed format: RESULT, WORK, DIRECTION, LOADED, PASSES, VERIFY, FILES, OPEN, ARTIFACT. A PARTIAL result names one reason: time, gate-open, decision or scope.

### Routing table

The routing table at the end of `design-craft/SKILL.md` is the only place where the workflow names other skills. Each skill has one row with these columns:

- **Level**: Product; Screen, flow; Component; Primitive; Any; or Verify.
- **Pass or trigger**: a pass runs on every part of its level; a trigger fires when its condition is observable in the brief, the repo or the part.
- **Skill**: the skill name, as a plain word. The agent finds it in the harness skill list, then under `~/.pi/agent/skills`, `~/.agents/skills`, `~/.claude/skills` and `~/.codex/skills`. A missing skill is recorded as `(missing)` and the step continues.
- **Agent**: `design`, `builder` or `both`. Both agents see the whole table and act only on their rows.
- **Notes**: the sections to read; an empty cell means the whole SKILL.md.

### Surfaces

Each surface has one file in `design-craft/surfaces/`:

- `app-screen.md`: a screen people work in (dashboard, admin, settings, form, inbox, editor). It holds the Project Context Scan (it grades the token layer as owned, stock or none), the Design Decision Gate, and recipes that load only on their trigger: app shell and sidebar, lockups and section header rows, detail and settings surfaces, loading and async states, charts, the color kernel, font fallback metrics, sizing and surfaces, density and elevation, the spacing pass, CJK text, and symptoms.
- `public-page.md`: a page people read and scroll (landing, marketing, pricing, docs home). It names the design-taste-frontend sections to read and when.
- `illustration.md`: faux product UI for a page slot, still or animated. stageshow runs the stage; the file lists the hand-off fields and the rules inside the stage.

A Figma file, a design image or a .pen file is a source, not a surface. Its routing table row applies.

### The two agents

The agent files live outside this repository, in `~/.pi/agent/agents/`. Both inject design-craft (`inject-skills: design-craft`), so the workflow is in context from the first turn.

- **design**: interactive, in a visible pane. It runs design grilling and the bottom-up build. Its children are scout, researcher and design-builder.
- **design-builder**: headless, in the background. It builds decided parts and stops on open parts with `DECISION NEEDED`.

## design-qa

design-qa owns Verify. Gates 1–11 read source; Gate 12 checks the rendered page. The skill has two blocks:

- **Static checks** run on every job and need no browser: the scanner, then Gates 1–11 in order.
- **Live checks** run when a browser is allowed: before-and-after screenshots (untouched sibling screens are diffed at threshold 0) and Gate 12 at 375×812 and 1440×900 with `agent-browser-chrome`. Gate 12 runs machine probes for errors, overflow, headings, contrast, focus, target size, dead-air bands and reduced motion. The commands and probe code are in `design-qa/reference/live-verification.md`.

The probes are in `design-qa/scripts/probes/`. The render probes (`align.js`, `clip.js`, `overlap.js`, `wrap.js`) report FAIL and JUDGE rows for clipped or spilled text, wrapped control labels, overlapping boxes and misaligned lockups. The machine probes are `contrast.js`, `headings.js`, `landing.js` and `targets.js`.

**Stageshow boundary.** A stageshow stage (its `kit/` folder and its demo folder) follows stageshow's rules. Stageshow's `film.mjs` checks the stage. design-qa checks the host page: allowlist rows remove scanner findings inside the stage, and every probe skips the descendants of `.ss-stage`. The overlap probe still checks the stage box against its host siblings.

### The scanner

```bash
bash design-qa/scripts/design-scan.sh ./src                   # human output
bash design-qa/scripts/design-scan.sh ./src --json            # pure JSON on stdout
bash design-qa/scripts/design-scan.sh ./src --critical-only   # gate only Critical findings
bash design-qa/scripts/design-scan.sh ./src --allowlist FILE  # CATEGORY<TAB>PATH_REGEX<TAB>REASON
bash design-qa/scripts/design-scan.sh ./src --allow-empty     # zero supported files is not an error
```

In an installed skill, use `"$PI_SKILL_DIR/scripts/design-scan.sh"`. It needs [ripgrep](https://github.com/BurntSushi/ripgrep) and [jq](https://jqlang.github.io/jq/); [ast-grep](https://ast-grep.github.io/) is optional and adds structural TSX checks. Lexical checks cover `tsx jsx ts js css scss html vue svelte astro mdx`.

Exit codes: `0` scanned and passed, `1` findings broke the gate, `2` no reliable evidence (bad arguments, missing dependency, no supported files, tool failure). The score is advisory; the exit code is the gate.

## laws-of-ux

Rules from [Laws of UX](https://lawsofux.com), one section per decision area: navigation and information architecture, forms and data input, multi-step flows and progress, actions and calls to action, feedback and response time, grouping and layout, content and copy, errors and recovery. Each rule states what to do; the law in parentheses is the reason. The agent picks the sections the change touches, applies every rule, and writes the audit. The skill stands alone. In design-craft it is a Screen-level pass.

## build-design-library

A workflow for a complete product design library, in seven gated phases: contract, research and sourcing, coverage and owner decisions, foundations and a vertical slice, component families, gallery and application integration, acceptance and handoff. Each phase reads one reference file and fills templates. design-craft does not route to it; the owner starts it for a library project. In pi: `pi --skill ./build-design-library/SKILL.md`, then `/skill:build-design-library`. Its companion skills and tools (research, firecrawl, design-qa, agent-browser-chrome and others) are in its "Runtime skill routing" table.

## evals/retro

`evals/retro/index.sh` indexes design and design-builder sessions into `~/.pi/artifacts/retro/sessions.tsv`. `evals/retro/compliance.sh` reports per batch: skills loaded, passes run, results, cost, peak context and owner corrections. A skill counts as loaded only when its text came back in a tool result. Run them after each batch of design runs; see `evals/retro/README.md`.

## Install

The commands use the [skills CLI](https://www.npmjs.com/package/skills). `-g` installs for the user, `-s` names one skill, `-y` skips prompts.

From GitHub:

```bash
npx skills add FasalZein/design-skills -g -s design-craft
npx skills add FasalZein/design-skills -g -s design-qa
npx skills add FasalZein/design-skills -g -s laws-of-ux
```

From a local checkout:

```bash
npx skills add <path-to-checkout> -g -s design-craft -y
```

`npx skills update` does not update a skill installed from a local path. With skills 1.7.6 (observed 2026-11-03) it reports that the skill "cannot be checked automatically ... (Local path)". Run `npx skills add` again after each change.

**Routed skills.** The workflow routes to skills from other packs: jakubkrehel/skills, emilkowalski/skill, benjitaylor/skills (stageshow), Leonxlnx/taste-skill (design-taste-frontend), and optional packs. `design-craft/skills.md` lists every routed skill with its question, source and install command, split into core and optional, plus the platform skills and the skills kept out of the router. The live checks also need the agent-browser CLI on the Chrome engine.

## Verify

```bash
bash scripts/verify.sh
```

It runs the scanner contract tests, the retro fixture tests and consistency checks: links resolve, numeric rules live in one file, the craft floor is in `design-craft/SKILL.md`, every routing row has a kind and an agent, every routed skill is installed or optional, and every SKILL.md loads with pi's skill loader. The render probe tests need a browser: `bash design-qa/tests/run-live-tests.sh`.

## Credits

- laws-of-ux is based on [Laws of UX](https://lawsofux.com) by Jon Yablonski.

## License

MIT
