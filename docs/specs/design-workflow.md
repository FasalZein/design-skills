# Design workflow v2

Status: approved by the owner, 2026-11-03; revision 3 the same day (design grilling, install set, bottom-up build).
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
  - `design-craft/skills.md` lists each routed skill with its question, source and install command (from `~/.agents/.skill-lock.json`), split into core and optional (D13).
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
  - Out of the router (stay installed for manual use): impeccable, grill-design (design-craft carries its own loop), design-md, the agent-browser skill stub, make-interfaces-feel-better, animation-vocabulary, hallmark, coss-particles, interface-review.
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

## Routing by question (D9)

| Level | Question | Skill |
|---|---|---|
| Product | Which overall look and house rules? | design-taste-frontend |
| Product | Which reference products, competitors, domain data? | researcher (child agent) |
| Product | How was a site the owner names built? | explain-interface |
| Screen, flow | Navigation, form, multi-step flow, destructive action | laws-of-ux |
| Screen, flow | A product illustration or demo on a page | stageshow |
| Screen, flow | Does this state model or logic feel right? | prototype, LOGIC branch (optional) |
| Screen, flow | Build from a Figma file or image | build-design |
| Component | Structure, density, emphasis, type or voice is open | variant |
| Component | Motion or interaction feel is open | emil-prototype |
| Component | States, one at a time | state-machine |
| Component | Every scenario on one page, for one look | break |
| Component | Renders data: worst-case fixtures and fixes | break-ui |
| Component | Custom control, dialog, focus, keyboard | better-accessibility |
| Component | Labels, errors, empty states, confirmations | better-writing |
| Component | Toasts with sonner | ask-sonner |
| Component | The project uses shadcn or coss | shadcn, coss (optional) |
| Component | A new UI library is needed | pick-ui-library, then the owner |
| Primitive | Palette, semantic tokens, contrast, dark mode | better-colors |
| Primitive | Type scale, font loading, wrapping | better-typography |
| Primitive | Spacing, grouping, responsive, RTL | better-layout |
| Primitive | Radius, shadow, border, icons | better-ui |
| Primitive | Motion: new animation | animate; springs and gestures: apple-design; a feel call: emil-design-eng |
| Any | Phone users | mobile-native |
| Any | Marketing copy | copywriting (optional) |
| Verify | Every part | design-qa |
| Verify | Changed motion code | review-animations |
| Verify | Any browser step | browser-checks (pi) |
| Verify | The owner asks for a review across domains | better-interface |

## Architecture

- `SKILL.md`, injected: sort the work (surface: app-screen, public-page, illustration, from-file; scope level; attended or headless); the craft floor; the design grilling steps; the build steps; Verify; the report; the routing table; D3, D10, D11, D12 and D16. Every step ends on a checkable done-condition.
- `jobs/<surface>.md`: surface rules. app-screen carries the Project Context Scan, the Design Decision Gate and the unique recipes from the old reference files (app shells, lockups, settings, loading tiers, charts), each behind its own trigger. public-page names the design-taste-frontend sections. illustration carries the stageshow hand-off fields. from-file covers build-design and pencil-design.
- `direction.md`: round mechanics (prototype file, picker, screenshots, open, ask_user pattern with "take parts from others") and the DESIGN.md template.
- `skills.md`: the install table, core and optional.
- `reference/` is deleted after its unique parts move.

### Report format

```
RESULT: DONE | PARTIAL (time | gate-open | decision | scope) | BLOCKED
WORK: <surface>, <scope level>, <attended | headless>
DIRECTION: <DESIGN.md path> | <open parts sent to the owner>
LOADED: <question or trigger> -> <skill>, one per line, or "none fired"
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

1. `bash scripts/verify.sh` is green with new checks: every routed skill resolves under a D3 root on this machine or is marked optional; the floor rules are in SKILL.md; no backticked slash tokens in design-craft; the router names no skill outside the routing table, the job files and skills.md; `design-craft/reference/` is gone.
2. The design-qa contract tests and the live probe tests are green.
3. Both agent descriptions contain no brief path; both allowlists are design-craft only; the design agent can spawn researcher.
4. Eval on the fixture app: 3 headless part briefs (a primitive set, a component, a screen) with a fixture DESIGN.md, x 3 models (Opus, Sonnet, GPT). In every run: every fired route's skill text appears in a tool result; no unfired routed skill appears; the static checks ran; a report exists, including runs that hit the time limit; screenshots came from agent-browser-chrome. Report cost and peak context against the sessions.tsv baseline. Plus one attended design-grilling session with the owner on the fixture.
5. The installed copies in `~/.agents/skills` (design-craft, design-qa, laws-of-ux) match the repo after install.

## Slices

1. This spec.
2. design-craft: SKILL.md, jobs/, direction.md, skills.md, fold and delete reference/, verify.sh checks.
3. design-qa: static and live split, render probes, Gate 8, before-and-after screenshots, tests.
4. laws-of-ux rewrite.
5. Agent files, the AGENTS.md stageshow exception line, researcher as a design child.
6. Eval harness and runs on `evals/fixture` (Vite, React, Tailwind, shadcn).
7. README and install.

## Out of scope

- pi-better-skills index mode; the pi-subagents time-contract wording; the env-wrap `.envrc` approval in the Travelicious runbook (an owner action); build-design-library and hallmark content.
