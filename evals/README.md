# Design workflow eval (spec Acceptance 4)

Three headless part briefs on one fixture app, each run by three models. Every run gets its own copy of the fixture as a fresh git repository outside this repository.

- `fixture/`: Harbor, a Vite, React, TypeScript, Tailwind v4 and shadcn (radix-nova) app with a sidebar shell and two screens, plus `fixture/DESIGN.md` with every decision of the three parts closed.
- `briefs/<part>.md`: the design-builder brief for primitive-set, component and screen, with the placeholders {RUN_DIR}, {PORT} and {RUN_NAME}.
- `briefs/<part>.expected`: the skill loads the Routing table in design-craft/SKILL.md expects for that part; each line names its row.
- `overlays/`: the approved lower-level parts that `new-run.sh` adds to the component run (primitives) and the screen run (primitives, StatusBadge).

## Run

1. Install the fixture once: `npm ci --prefix evals/fixture`.
2. Set up each run; stdout is the rendered brief: `bash evals/new-run.sh <part> <run-name> <port> > <brief file>`. Runs go to ~/Dev/AI/Skills/design-skills-eval-runs/ (`EVAL_RUNS_ROOT` overrides). Use one port per run.
3. Launch a design-builder per brief and model.
4. Index the sessions: `bash evals/retro/index.sh <sessions.tsv>`.
5. Write a run map, one tab-separated line per run: run name, part, model, absolute session file.
6. Score: `bash evals/score.sh <sessions.tsv> <runs.tsv>`. Each run line reports text, unexpected, passes, static, report and shots as ok or FAIL, plus cost, peak context and the ambiguous skills that came back.

Tests: `bash evals/tests/run-tests.sh` (scripts/verify.sh runs them).
