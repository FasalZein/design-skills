# Design workflow v2

Status: approved by the owner, 2026-11-03.
Evidence: `~/.pi/artifacts/design-retro/` (plan.md, owner-corrections.md, skill-overlap.md, grill-flow.md, builder-runs.md, sessions.tsv).

## Problem

design-craft is a phase router with a 34-skill map. It leaves skill loading to the model, so behaviour depends on the model:

- Opus builders loaded no skill text in 6 of 8 runs since 2026-10-23.
- Sonnet builders load only the skills the brief names.
- GPT builders load every mapped skill in batches. The tool-result cap cut about 45% of that text, and the runs then hit the 3600 s limit.

The rules that every build needs left the injected file on 2026-10-23 (commit 1f2fff7). Since then, 3 of 14 builders opened `reference/app-ui.md`. The 34 mapped skills contradict each other in 18 places. 25 of them were not read in 19 sessions.

## Goal

Each design job loads the skills that its triggers name, one at a time, and no others, on every model. Every run verifies its result and leaves a report.

## Decisions

- **D1 Router.** design-craft becomes a workflow router. It is injected into the design and design-builder agents. Rewrite it from the writing-for-agents guide; do not edit the current text in place.
- **D2 No brief template.** The intake step lists what the agent must find before its first edit. Remove `~/.pi/agent/templates/design-brief-template.md` from both agent descriptions.
- **D3 Plain names.** Name skills as plain words with their SKILL.md path. Never use backticked slash tokens; pi-better-skills would inject those bodies. The pi-better-skills index mode is deferred.
- **D4 build-design-library** leaves the design router and both agents. The owner starts it for a library project.
- **D5 laws-of-ux** stays a separate skill. It loads only on its triggers. Rewrite it from the writing-for-agents guide.
- **D6 design-qa owns Verify.** It has a static block that runs on every job and a live block that runs when a browser is allowed. Add render probes for overflow, wrapping, overlap and sibling alignment. Change Gate 8: wrap titles, money and metric labels; truncate only in cells whose width the design fixes.
- **D7 Stageshow is a leaf job type with its own gate.**
  - Inside the stage, stageshow's rules win: window chrome, placeholder bars, literal colors, illustrative data.
  - Its `film.mjs` gate checks the stage. design-qa and agent-browser-chrome check the host page.
  - `kit/` and the demo folder go on the scanner allowlist.
  - AGENTS.md gets one exception line for film.mjs.
- **D8 No owner-defaults file.** Project preferences go into that project's DESIGN.md when the owner approves them.
- **D9 One owner per duplicated concern** (table below). Skills that lose their concern stay installed for manual use; the router does not name them.
- **D10 Time.** The 3600 s limit stays.
  - The agent writes a report draft at the end of intake and updates it after each step.
  - When time runs short, it cuts scope, not steps.
  - PARTIAL carries a reason: time, gate-open, decision or scope.
- **D11 Headless runs** skip any skill's "Initial Response" or reply-and-wait step.
- **D12 One skill per read call**, read whole, unless the trigger row names sections. A batch read can lose text to the tool-result cap.

## Owners for duplicated concerns (D9)

| Concern | Owner | Not routed |
|---|---|---|
| Surface polish (radius, shadow, border, icon) | better-ui | make-interfaces-feel-better |
| Prototype picker and loop | grill-design (with grilling, prototype) | variant, emil-prototype |
| Worst-case data | break-ui | break |
| Public-page direction and house rules | design-taste-frontend | hallmark |
| Browser rules | browser-checks | agent-browser (stub skill) |
| DESIGN.md format | design-craft direction.md template | design-md (only when the owner asks for DMD) |
| Refine pass | impeccable, one sub-command | better-interface, interface-review |
| Motion vocabulary | none | animation-vocabulary |
| Motion audit (a job of its own) | improve-animations | find-animation-opportunities |

## Architecture

### design-craft files

- `SKILL.md`, injected:
  1. Sort the job: app-screen, public-page, illustration, from-file. Library jobs go to the owner. Set the mode: attended or headless.
  2. The craft floor: binary rules every UI job needs. Taken from app-ui.md Hard Guardrails, Spacing Kernel limits, Symptom table, "let the UI explain itself", and Gate 8 wrap-first.
  3. Steps with checkable done-conditions: Intake, Direction, Build, Refine, Verify, Report.
  4. The cross-job trigger table.
  5. The report format.
- `jobs/<type>.md`: the must-load set and the job-specific triggers and rules. The agent reads it once after sorting.
- `direction.md`: the attended direction loop, the one picker spec and the DESIGN.md template. The agent reads it when Direction is open and the owner is present.
- `reference/*.md`: keep only branch material that no owner skill carries. Remove text that the floor or an owner skill now holds.

### Cross-job trigger table (initial; S2 finalizes)

| Trigger (observable) | Skill | Step |
|---|---|---|
| Every job | design-qa | Verify |
| Any browser step | browser-checks | first browser step |
| Attended, and the look or flow is open | grill-design | Direction |
| Form, multi-step flow, destructive action, navigation structure | laws-of-ux | Build |
| New or changed UI strings: labels, errors, empty states, confirmations | better-writing | Build |
| Custom control, dialog, focus order, keyboard handling | better-accessibility | Build |
| New palette, semantic tokens or dark mode | better-colors | Build |
| Type scale or font loading | better-typography | Build |
| RTL, translated text, or responsive structure change | better-layout | Build |
| New animation | animate (springs, gestures, sheets: apple-design) | Build |
| Changed motion code | review-animations | Verify |
| sonner in package.json and the task touches toasts | ask-sonner | Build |
| The task names phone users | mobile-native | Build |
| components.json exists and the task adds or changes components | shadcn | Build |
| coss or Base UI in package.json | coss | Build |
| A changed component renders data | break-ui (fix mode when headless) | Verify |
| Attended, and a component has 3 or more states | state-machine | Verify |
| The owner names a reference site | explain-interface | Direction |
| Whole-screen pass before Verify | impeccable, one sub-command | Refine |
| The build needs a new UI library | pick-ui-library; owner decision | Build |

### Job files

- **app-screen:** reference/app-ui.md (Project Context Scan, Design Decision Gate). Direction source: DESIGN.md, the attended loop, or the app-ui gate.
- **public-page:** design-taste-frontend, named sections only. Triggers: copywriting (marketing copy), stageshow (the page shows a product in a window or a demo).
- **illustration:** stageshow, its own workflow. Fields to hand it: host page and ground, slot width and compact need, medium, product and its token source, fidelity, beats and poster, nearest gold example, kit import path, artifact folder, allowlist rows, reviewer availability. Run film.mjs from the stageshow skill folder against the host URL.
- **from-file:** build-design (Figma file or image); pencil-design (.pen file).

### Report format

```
RESULT: DONE | PARTIAL (time | gate-open | decision | scope) | BLOCKED
JOB: <type>, <attended | headless>
DIRECTION: <DESIGN.md path | owner verdict | self-picked id>
LOADED: <trigger> -> <skill>, one per line, or "none fired"
VERIFY: static <scanner exit, typecheck>; live <gates, screenshot folder> | not allowed: <brief line>
FILES: <changed paths>
OPEN: <items> | none
ARTIFACT: <absolute path>
```

### Agents

- **Both:** frontmatter settings, the role, the gears, the implementation rules (keep the styling method, commit to the current branch), spawning, and the report. No brief path. No workflow text: the injected router holds it.
- **design:** attended. Allowlist: design-craft and the skills the owner types by hand (default: design-qa, laws-of-ux, grill-design, stageshow).
- **design-builder:** headless. Allowlist: design-craft only. Rule: report draft first; cut scope, not steps.

## Acceptance

1. `bash scripts/verify.sh` is green with these new checks:
   - every trigger-table and job-file path exists;
   - the floor rules are in SKILL.md;
   - SKILL.md and the job files contain no backticked slash tokens;
   - the router names no skill outside the trigger table, the job files and the owner table.
2. The design-qa contract tests are green with new fixtures for each render probe and for Gate 8 wrap-first.
3. Both agent descriptions contain no brief path. The design allowlist has the default set; design-builder has design-craft only.
4. Eval: 3 job briefs (app-screen, public-page, illustration) x 3 models (Opus, Sonnet, GPT). In every run:
   - every fired trigger's skill text appears in a tool result;
   - no unfired routed skill appears;
   - the static verify block ran;
   - a report exists, including runs that hit the time limit;
   - result screenshots were taken with agent-browser-chrome.

   Report cost and peak context against the sessions.tsv baseline.
5. The installed copies in `~/.agents/skills` (design-craft, design-qa, laws-of-ux) match the repo after install.

## Slices

1. This spec.
2. design-craft rewrite: SKILL.md, jobs/, direction.md, reference pruning, verify.sh checks.
3. design-qa: static and live split, render probes, Gate 8, before-and-after screenshots captured at intake when a browser is allowed, contract tests.
4. laws-of-ux rewrite.
5. Agent files, plus the AGENTS.md stageshow exception line.
6. Eval harness and runs, on a scratch fixture app committed at `evals/fixture` (Vite, React, Tailwind, shadcn). Decided 2026-11-03.
7. README and install.

## Out of scope

- pi-better-skills index mode.
- The pi-subagents time-contract wording.
- The env-wrap `.envrc` approval in the Travelicious runbook main checkout (an owner action).
- build-design-library and hallmark content.

## Open questions

- Design pane allowlist: confirm the default set.
