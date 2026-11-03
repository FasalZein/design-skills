# Design workflow eval (spec Acceptance 4)

Two products, four part briefs each, run by three models, plus one headless design-agent run per product. Every run gets its own copy of its fixture as a fresh git repository.

- `fixture/`: Harbor, an inbound-shipments app (surface app-screen). Vite, React, TypeScript, Tailwind v4 and shadcn (radix-nova), a sidebar shell and two screens in the stock look (the "before" state). `fixture/DESIGN.md` is the owner-approved Hi-vis direction (attended grilling, 2026-11-03; `.design-md/` holds its DMD style context) and closes every decision. The approved font packages and the `newEta` field are in.
- `fixture-marketing/`: the Harbor landing page (surface public-page, with a product-demo slot for the illustration surface). Same stack, stock look: header, hero, an empty demo slot, features, pricing, FAQ, footer call to action. `fixture-marketing/DESIGN.md` closes every decision.
- `briefs/<part>.md`: one brief per part, with the placeholders {RUN_DIR}, {PORT} and {RUN_NAME}. `briefs/<part>.expected`: the skill loads the Routing table in design-craft/SKILL.md expects; each line names its row.

| Level | App part | Marketing part |
|---|---|---|
| primitive | primitive-set | mkt-primitive-set |
| component | component (StatusBadge, the Day line) | mkt-component (PricingCard) |
| component group | section (the Docks board) | mkt-section (product demo, an illustration) |
| screen or page | screen (Shipments, the narrow top bar) | mkt-page (the landing page) |
| design agent | design-app (open part: Docks) | design-marketing (open part: FAQ) |

- **Harbor chains:** each model builds Harbor bottom-up on its own output: primitive-set from the fixture, then component, section and screen, each started with `--from <previous run>`. Chain mode copies the previous run's committed HEAD (uncommitted work stays behind), clones its node_modules, and makes one new initial commit.
- `overlays/`: what `new-run.sh` adds before the initial commit. Higher marketing parts get the approved lower-level parts (`mkt-primitives`, `mkt-components`). The design parts get the product's DESIGN.md variant with one open part (`design-app`: the Docks section; `design-marketing`: FAQ).

## Run

1. Install each fixture once: `npm ci --prefix evals/fixture` and `npm ci --prefix evals/fixture-marketing`.
2. Set up one run; stdout is the rendered brief: `bash evals/new-run.sh <part> <run-name> <port> [--from <previous-run-name>] > <brief file>`. `--from` works on the four Harbor builder parts only. Clean a chain's runs only after the whole chain is built. Runs go to `<repo root>/.eval-runs/` (git ignores it; `EVAL_RUNS_ROOT` overrides). Use one port per run; a design run also uses the next four ports for its builders.
3. Launch a design-builder per part brief and model, or the design agent with a design-* brief. Run one at a time.
4. Index the sessions: `bash evals/retro/index.sh <sessions.tsv>`.
5. Write a run map, one tab-separated line per run: run name, part, model, absolute session file.
6. Score: `bash evals/score.sh <sessions.tsv> <runs.tsv>`. Each run line reports text, unexpected, passes, static, report and shots as ok or FAIL, plus cost, peak context and the ambiguous skills that came back. A design run adds decision, children and open_built, then one line per child design-builder session, scored against the part of its level.
7. Save and delete the run: `bash evals/clean-run.sh <run-name> <artifact dir>` writes git-log.txt and run.diff (plus uncommitted.diff and status.txt when the run left changes) and deletes the run directory. It works only inside `<repo root>/.eval-runs`.

Tests: `bash evals/tests/run-tests.sh` (scripts/verify.sh runs them).
