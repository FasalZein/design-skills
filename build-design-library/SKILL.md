---
name: build-design-library
description: Build a complete product design library from approved product scope through verified application integration.
disable-model-invocation: true
---

# Build a Product Design Library

Build the approved product library through seven gated phases. Scope enters only through product authority or an owner decision. Competitor features and generic aesthetics are evidence, never authority.

## Vocabulary

- **authority** — a source that binds the work: repository instructions, decision records, approved specifications, code, generated contracts, tests. Project authority outranks every generic design suggestion.
- **owner** — the one person, worker, or process that may change a component, exported symbol, file, process, worktree, hostname, or route. Every item has exactly one.
- **claim** — a worker report, walkthrough, scanner pass, screenshot set, or implementer full-suite run. A claim proves nothing on its own.
- **receipt** — an independent reviewer's recorded `pass` or `block` on a named artifact. Only a receipt accepts work.
- **seam** — the documented boundary where implemented data ends and `proposed` data begins. Live proof stops at the seam.
- **cell** — one route, mode, viewport, and state combination in the browser matrix. Only its own read-back screenshot and measured probes prove a cell.
- **stub** — a temporary fallback. It exists only with explicit owner approval evidence, one owner, and a deletion plan ([rule](references/design-and-data.md#run-owner-decisions)).

## Runtime skill routing

Resolve each capability by name from the current runtime skill registry. Load the skill (read its `SKILL.md` through the registry) before its first trigger in a phase; its commands and references then run as written. Record each loaded skill and its status in the contract's capability table.

| Trigger | Skill or tool | Required use |
|---|---|---|
| Before visual decisions or UI builds | `design-craft` | Run its brownfield scan. Shipped project tokens stay authoritative. Load each reference that its trigger requires. |
| Navigation, forms, decision flows, feedback, errors, onboarding, progress, or microcopy | `laws-of-ux` | Name its governing rule for each material interaction decision. |
| Any external research stream: reference products, source libraries, domain rules | `research` | Run each stream as a background agent against primary sources. One cited Markdown file per stream, at the artifact path the brief names. |
| Reference-product capture: competitor pages as HTML export or full-page screenshot, PDFs, site maps | `firecrawl` | `scrape <url> html` and `scrape <url> screenshot` on public pages only. Record URL, date, and access limits with each capture. |
| Before product acceptance | `design-qa` | Run its scanner, then its judgment gates, then its live-verification reference. Scanner exit `0` proves only its mechanical scope. |
| Rendered proof of this product: measurements, interaction evidence, browser cells | `agent-browser` | Measure the rendered surface through isolated sessions and fresh navigation. |

A missing capability keeps status `missing` in the contract's capability table. Apply the project's own checks by hand and report them as manual.

## Phase 1 — Contract

**Read:** [references/contract.md](references/contract.md).

**Act:** Fill [templates/project-contract.md](templates/project-contract.md). Discover policies, scope, shipped assets, data, routes, commands, roster, tools, and owner choices.

**Exit gate:** Every item in [Contract completion](references/contract.md#contract-completion) holds.

## Phase 2 — Research and sourcing

**Read:** [references/research.md](references/research.md). Read [references/component-sourcing.md](references/component-sourcing.md) before any library recommendation, copy, adaptation, or installation.

**Act:** Route nonoverlapping research for reference products, source libraries, owned code, and domain rules. Use [templates/helper-brief.md](templates/helper-brief.md) and [templates/research-capture-license.md](templates/research-capture-license.md).

**Exit gate:** Every item in [Research completion](references/research.md#research-completion) holds.

## Phase 3 — Coverage, data, and owner decisions

**Read:** [references/design-and-data.md](references/design-and-data.md).

**Act:** Complete these records:

- [templates/component-coverage-family-dag.md](templates/component-coverage-family-dag.md)
- [templates/owner-design-decisions.md](templates/owner-design-decisions.md)
- [templates/shared-scenario-data-contract.md](templates/shared-scenario-data-contract.md)
- [templates/acceptance-evidence-ledger.md](templates/acceptance-evidence-ledger.md)

**Exit gate:** Every item in [Coverage completion](references/design-and-data.md#coverage-completion) holds. An unresolved owner choice stops the affected work.

## Phase 4 — Foundations and vertical slice

**Read:** [references/build.md](references/build.md). Keep it loaded through Phase 5.

**Act:** Build foundations. Then prove one thin path from data through the gallery and a real application route.

**Exit gate:** The [Vertical slice gate](references/build.md#vertical-slice-gate) passes.

## Phase 5 — Component families

**Read:** Continue [references/build.md](references/build.md).

**Act:** Build only accepted dependency nodes. Assign one owner to each component, shared symbol, shared file, process, and worktree. Route integration through one serial owner.

**Exit gate:** Every in-scope family passes [Family completion](references/build.md#family-completion).

## Phase 6 — Gallery and application integration

**Read:** [references/verification.md](references/verification.md). Keep it loaded through Phase 7.

**Act:** Integrate navigable gallery sections and real application routes. Use coherent scenarios. Exercise style generation, assets, authentication, API paths, route ownership, and supported startup behavior.

**Exit gate:** Every item in [Integration completion](references/verification.md#integration-completion) holds.

## Phase 7 — Acceptance and handoff

**Read:** Continue [references/verification.md](references/verification.md).

**Act:** Run static checks, rendered checks, real journeys, independent review, project quality roles, and the full project gate. Work through [templates/integration-cleanup-handoff.md](templates/integration-cleanup-handoff.md).

**Exit gate:** Every item in [Acceptance completion](references/verification.md#acceptance-completion) holds.

## Final report

Fill the handoff record in [templates/integration-cleanup-handoff.md](templates/integration-cleanup-handoff.md). Name each proof type: a walkthrough is document evidence, a scanner is source evidence, a screenshot is visual evidence only after capture and read-back.
