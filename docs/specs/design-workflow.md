# Design workflow v2

Status: approved by the owner, 2026-11-03; revision 3 the same day (design grilling, install set, bottom-up build); revision 4 the same day (surfaces, one routing table with an agent column, craft passes, outcome loop).
Evidence: `~/.pi/artifacts/design-retro/` (plan.md, owner-corrections.md, skill-overlap.md, grill-flow.md, builder-runs.md, sessions.tsv).

## Problem

design-craft is a phase router with a 34-skill map. It leaves skill loading to the model, so behaviour depends on the model:

- Opus builders loaded no skill text in 6 of 8 runs since 2026-10-23.
- Sonnet builders load only the skills the brief names.
- GPT builders load every mapped skill in batches. The tool-result cap cut about 45% of that text, and the runs then hit the 3600 s limit.

The rules that every build needs left the injected file on 2026-10-23 (commit 1f2fff7). Since then, 3 of 14 builders opened `reference/app-ui.md`. The 34 mapped skills contradict each other in 18 places. 25 of them were not read in 19 sessions.

Direction works when the owner sees prototypes. The 3 recent sessions that showed prototype rounds reached approval in 4 rounds, 20 to 35 min, $4.60 to $6.17. The owner rejected options offered only as words in 4 sessions.

## Goal

The design agent works a design tree with the owner in rounds of prototypes, then builds the decided parts from the bottom up with design-builders. Each part loads only the skills its question needs, on every model. Every run verifies its result and leaves a report.

## Decisions

- **D1 Workflow.** design-craft is a workflow: design grilling (D14), then a bottom-up build (D15). It is injected into the design and design-builder agents. Write it new from the writing-for-agents guide.
- **D2 No brief template.** Intake lists what the agent must find before its first edit. Remove `~/.pi/agent/templates/design-brief-template.md` from both agent descriptions.
- **D3 Names, not paths.** The router names skills as plain words. Never use backticked slash tokens; pi-better-skills would inject those bodies.
  - Lookup order: the harness skill list; then `<root>/<name>/SKILL.md` under ~/.pi/agent/skills, ~/.agents/skills, ~/.claude/skills, ~/.codex/skills; else record the skill as missing and continue the step.
  - `design-craft/skills.md` lists each routed skill with its question, source and install command (from `~/.agents/.skill-lock.json`), split into core and optional (D13), plus the platform skills and the skills out of the router.
  - emil-prototype is Emil Kowalski's prototype skill under a new name; mattpocock/skills already has a prototype skill.
- **D3a Loading.** Routed skills load by file reads when their trigger fires. If the eval shows missed or extra loads, add a small trigger extension: the agent writes a `TRIGGERS:` line, and the extension loads the mapped skills through the deliver API on the owner's pi-better-skills fork (branch feat/skill-delivery-api). The pi-better-skills index mode is deferred.
- **D4 build-design-library** leaves the design router and both agents. The owner starts it for a library project.
- **D5 laws-of-ux** stays a separate skill, loaded on its triggers, rewritten from the writing guide.
- **D6 design-qa owns Verify.** "## Static checks" run on every job; "## Live checks" run when a browser is allowed. New render probes for overflow, wrapping, overlap and sibling alignment. Gate 8: wrap titles, money and metric labels; truncate only in cells whose width the design fixes.
- **D7 Stageshow is a leaf with its own gate.** Inside the stage, stageshow's rules win (window chrome, placeholder bars, literal colors, illustrative data). film.mjs checks the stage; design-qa and agent-browser-chrome check the host page. kit/ and the demo folder go on the scanner allowlist. AGENTS.md gets one exception line for film.mjs.
- **D8 No owner-defaults file.** Project preferences go into that project's DESIGN.md through the owner's verdicts.
- **D9 Route by question** (table below). Skills that answer distinct questions keep a route.
- **D10 Time.** The 3600 s limit stays. Report draft at the end of intake, updated after each step. When time runs short, cut scope, not steps. PARTIAL carries a reason: time, gate-open, decision or scope.
- **D11 Headless runs** skip any skill's "Initial Response" or reply-and-wait step.
- **D12 One skill per read call**, whole, unless the route names sections.
- **D13 Install set.**
  - Core: FasalZein/design-skills (design-craft, design-qa, laws-of-ux), jakubkrehel/skills, emilkowalski/skill, benjitaylor/skills (stageshow), Leonxlnx/taste-skill (design-taste-frontend), and the agent-browser CLI on the Chrome engine.
  - Optional, used only when installed and their trigger fires: shadcn and coss (the project uses them), mattpocock prototype (a logic question), copywriting (marketing copy), pencil-design (a .pen file).
  - Out of the router (stay installed for manual use): impeccable, grill-design (design-craft carries its own loop), design-md, the agent-browser skill stub, make-interfaces-feel-better, animation-vocabulary (owner choice), hallmark, coss-particles.
  - Platform skills, not routed: animate-expo and write-swift. The workflow verifies web UI only; they route when a native track with its own checks exists.
- **D14 Design grilling (attended).** The design agent interviews the owner like grilling, with prototypes as the questions.
  - Tree levels: product, then screens and flows, then component groups, then components, then primitives (color, type, spacing, radius, motion tokens).
  - The root is the level of the requested scope: a section starts at the section, a page at the page, a product at the product. Rounds go down only through levels that still have open decisions; DESIGN.md, approved tokens and existing components close decisions. A small section can finish in one round; a whole page usually needs the page, its sections, open components, and a primitives sheet when it adds tokens.
  - A round asks the whole frontier at once. Each question shows prototypes and a recommended answer. Prototypes: one standalone HTML file per round with a picker and real product data, screenshot at desktop and phone width, then opened for the owner. The owner decides through ask_user.
  - Facts come from children, never from the owner: researcher for reference products, competitors and domain data; scout for the existing code.
  - design-taste-frontend deals the top-level options and supplies the house rules.
  - Each verdict goes into DESIGN.md when it is made. Done when the frontier is empty and the owner approves DESIGN.md as written.
- **D15 Bottom-up build.** Primitives, then components, then screens. The design agent sends decided, independent parts to design-builders with the DESIGN.md path. Each part passes design-qa before a higher level uses it.
- **D16 Open parts stop headless runs.** A builder never decides an open part. It stops on that part with a DECISION NEEDED block, and the parent asks the owner. There is no self-picked direction.
- **D17 Children of the design agent:** scout, researcher, design-builder.
- **D18 Surfaces.** The router sorts work by surface, so `design-craft/surfaces/` holds one file per surface: app-screen, public-page, illustration. A Figma file, a design image or a .pen file is a source, not a surface: build-design and pencil-design are trigger rows. The headings "Craft floor" (SKILL.md) and "Project Context Scan" (surfaces/app-screen.md) keep these names; design-qa scanner hints point to them.
- **D19 One routing table with an agent column** (design | builder | both). Both agents see the whole table and act only on their rows. Each skill has one row; its meaning lives there.
- **D20 Craft passes per level.** Each level has a fixed pass list; each pass is one skill used as a lens, run by the agent its row names. A part is done when every pass of its level has a result: applied (skill loaded; what changed) or n/a (an observable fact). A pass that does not apply loads nothing. The report carries a PASSES line. No verify.sh coverage lint.
- **D21 New routes:** interface-review (builder; the part changed existing UI: review its own diff for regressions before reporting); find-animation-opportunities (design; after a screen is built, a motion round: the owner picks proposals, builders apply them with animate); improve-animations (design; the owner asks to improve existing motion: an audit plus plans that builders run).
- **D22 Outcome loop.** `evals/retro/index.sh` and `compliance.sh` index design and design-builder sessions. A skill counts as loaded when its text came back in a tool result (its frontmatter `name:` line), never by a path in call arguments. After each batch they report passes run, skills that changed results, cost, peak context and owner corrections.

## Routing by question (D9, D19, D20)

Pass rows run on every part of their level; trigger rows fire on their condition. design-craft/SKILL.md holds the live table with a Notes column; this is its decided content.

| Level | Pass or trigger | Skill | Agent |
|---|---|---|---|
| Product | Pass: which overall look and house rules? | design-taste-frontend | both |
| Product | Pass: reference products, competitors, domain data | researcher (child agent) | design |
| Product | Pass: how was a site the owner names built? | explain-interface | design |
| Screen, flow | Pass: navigation, forms, multi-step flows, destructive actions | laws-of-ux | both |
| Screen, flow | Pass: what here should move? | find-animation-opportunities | design |
| Screen, flow | Pass: a review across domains | better-interface | builder |
| Screen, flow | Trigger: a product illustration or demo on a page | stageshow | both |
| Screen, flow | Trigger: a state model or logic question is open | prototype (optional) | design |
| Screen, flow | Trigger: a Figma file or a design image is the source | build-design | builder |
| Screen, flow | Trigger: a .pen or .lib.pen file is the source | pencil-design (optional) | builder |
| Screen, flow | Trigger: the owner asks to improve existing motion | improve-animations | design |
| Component | Pass: structure, density, emphasis, type or voice, while the form is open | variant | design |
| Component | Pass: motion or interaction feel, while it is open | emil-prototype | design |
| Component | Pass: custom controls, dialogs, focus, keyboard | better-accessibility | builder |
| Component | Pass: labels, errors, empty states, confirmations | better-writing | builder |
| Component | Pass: states, one at a time | state-machine | both |
| Component | Pass: renders data: worst-case fixtures and fixes | break-ui | builder |
| Component | Pass: changed motion code | review-animations | builder |
| Component | Pass: the part changed existing UI | interface-review | builder |
| Component | Trigger: every scenario on one page, for one look | break | design |
| Component | Trigger: toasts with sonner | ask-sonner | builder |
| Component | Trigger: the project uses shadcn (components.json) | shadcn (optional) | builder |
| Component | Trigger: the project uses coss or Base UI | coss (optional) | builder |
| Component | Trigger: a new UI library is needed | pick-ui-library | design |
| Primitive | Pass: palette, semantic tokens, contrast, dark mode | better-colors | builder |
| Primitive | Pass: type scale, font loading, wrapping | better-typography | builder |
| Primitive | Pass: spacing, grouping, responsive, RTL | better-layout | builder |
| Primitive | Pass: radius, shadow, border, icons | better-ui | builder |
| Primitive | Pass: motion tokens and new animations | animate | builder |
| Primitive | Trigger: springs, gestures, drag, sheets | apple-design | builder |
| Primitive | Trigger: a motion feel call | emil-design-eng | builder |
| Any | Trigger: phone users | mobile-native | both |
| Any | Trigger: marketing copy | copywriting (optional) | both |
| Verify | Pass: every part | design-qa | both |
| Verify | Trigger: any browser step | browser-checks | both |

## Architecture

- `SKILL.md`, injected: sort the work (surface: app-screen, public-page, illustration; scope level; attended or headless); the craft floor; the design grilling steps; the build steps with craft passes; Verify; the report; the routing table with its agent column; D3, D10, D11, D12 and D16. Every step ends on a checkable done-condition.
- `surfaces/<surface>.md`: surface rules. app-screen carries the Project Context Scan, the Design Decision Gate and the unique recipes from the old reference files (app shells, lockups, settings, loading tiers, charts), each behind its own trigger. public-page names the design-taste-frontend sections. illustration carries the stageshow hand-off fields.
- `direction.md`: round mechanics (prototype file, picker, screenshots, open, ask_user pattern with "take parts from others") and the DESIGN.md template.
- `skills.md`: the install table, core and optional; platform skills; skills out of the router.
- `evals/retro/`: index.sh, compliance.sh and a README on running them after a batch (D22).
- `reference/` is deleted after its unique parts move.

### Report format

```
RESULT: DONE | PARTIAL (time | gate-open | decision | scope) | BLOCKED
WORK: <surface>, <scope level>, <attended | headless>
DIRECTION: <DESIGN.md path> | <open parts sent to the owner>
LOADED: <trigger> -> <skill>, one per line, or "none fired"
PASSES: <pass> -> applied: <change> | n/a: <fact>, one per line
VERIFY: static <scanner exit, typecheck>; live <gates, screenshot folder> | not allowed: <brief line>
FILES: <changed paths>
OPEN: <items> | none
ARTIFACT: <absolute path>
```

### Agents

- **Both:** frontmatter settings, role, implementation rules (keep the styling method, commit to the current branch), spawning and report. No brief path. No workflow text: the injected router holds it.
- **design:** attended; runs D14 and D15. Allowlist: design-craft only. Children: scout, researcher, design-builder.
- **design-builder:** headless; builds decided parts; D16. Allowlist: design-craft only.

## Acceptance

1. `bash scripts/verify.sh` is green with new checks: every routed skill resolves under a D3 root on this machine or is marked optional; the floor rules are in SKILL.md; no backticked slash tokens in design-craft; the router names no skill outside the routing table, the surface files and skills.md; every routing row has a Pass or Trigger kind and an agent (design | builder | both), one row per skill; `design-craft/surfaces/` holds app-screen, public-page and illustration with the two named headings; `design-craft/reference/` and `jobs/` are gone.
2. The design-qa contract tests and the live probe tests are green.
3. Both agent descriptions contain no brief path; both allowlists are design-craft only; the design agent can spawn researcher.
4. Eval on the fixture app: 3 headless part briefs (a primitive set, a component, a screen) with a fixture DESIGN.md, x 3 models (Opus, Sonnet, GPT). In every run: every fired trigger's and applied pass's skill text appears in a tool result; no unfired, n/a or other agent's skill appears; PASSES has a result for every pass of the part's level; the static checks ran; a report exists, including runs that hit the time limit; screenshots came from agent-browser-chrome. Report cost and peak context against the sessions.tsv baseline. Plus one attended design-grilling session with the owner on the fixture.
5. The installed copies in `~/.agents/skills` (design-craft, design-qa, laws-of-ux) match the repo after install.

## Slices

1. This spec.
2. design-craft: SKILL.md, surfaces/, direction.md, skills.md, fold and delete reference/, verify.sh checks, evals/retro/.
3. design-qa: static and live split, render probes, Gate 8, before-and-after screenshots, tests.
4. laws-of-ux rewrite.
5. Agent files, the AGENTS.md stageshow exception line, researcher as a design child.
6. Eval harness and runs on `evals/fixture` (Vite, React, Tailwind, shadcn).
7. README and install.

## Out of scope

- pi-better-skills index mode; the pi-subagents time-contract wording; the env-wrap `.envrc` approval in the Travelicious runbook (an owner action); build-design-library and hallmark content.
