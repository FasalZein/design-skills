---
name: build-design-library
description: Build a complete product design library from approved product scope through verified application integration.
disable-model-invocation: true
---

# Build a Product Design Library

Build the approved product library through seven gated phases. Scope enters only through product authority or a decision owner's choice. Competitor features and generic aesthetics are evidence, never authority.

## Vocabulary

- **authority** — a source that binds the work: repository instructions, decision records, approved specifications, code, generated contracts, tests. Project authority outranks every generic design suggestion.
- **decision owner** — the human who approves scope, identity, fallbacks, and policy changes. Silence keeps a decision open.
- **work owner** — the one worker or process that may change a component, exported symbol, file, process, worktree, hostname, or route. Every item has exactly one. A work owner never approves a decision.
- **claim** — a worker report, walkthrough, scanner pass, screenshot set, or implementer full-suite run. A claim proves nothing on its own.
- **receipt** — an independent reviewer's recorded `pass` or `block` on a named artifact. Only a receipt accepts work. When no independent reviewer capability exists, the receipt is `unreviewed`: the gate stays closed, and the run reports it to the decision owner. Work never self-certifies.
- **seam** — the documented boundary where implemented data ends and `proposed` data begins. Live proof stops at the seam.
- **cell** — one route, mode, viewport, and state combination in the browser matrix. Only a [valid capture](references/verification.md#valid-capture) proves a cell.
- **stub** — a temporary fallback. It exists only with the decision owner's explicit approval evidence, one work owner, and a deletion plan ([rule](references/design-and-data.md#run-owner-decisions)).

## Runtime skill routing

Resolve each capability by name from the current runtime skill registry. Before its first trigger in a phase, load a skill by reading its `SKILL.md` through the registry; load the `agent-browser` tool with `agent-browser skills get core`. Record each capability, its loaded status, and any limit in the contract's capability table.

| Trigger | Skill or tool | Required use |
|---|---|---|
| Before visual decisions or UI builds | `design-craft` | Run its brownfield scan. Shipped project tokens stay authoritative. Load each reference that its trigger requires. |
| Navigation, forms, decision flows, feedback, errors, onboarding, progress, or microcopy | `laws-of-ux` | Name its governing rule for each material interaction decision. |
| Any external research stream: reference products, source libraries, domain rules (Phase 2) | `research` | Run each stream as a background agent against primary sources. One cited Markdown file per stream, at the artifact path the brief names. |
| Reference-product capture: competitor pages as HTML export or full-page screenshot, PDFs, site maps (Phase 2) | `firecrawl` | `scrape <url> html` and `scrape <url> screenshot` on public pages only. Record URL, date, and access limits with each capture. Competitor interaction behavior is inferred from capture or documentation, never measured. |
| Before product acceptance (Phase 7) | `design-qa` | Run its scanner, then its judgment gates, then its live-verification reference. Scanner exit `0` proves only its mechanical scope. |
| Rendered proof of this product, from the vertical slice onward (Phases 4–7) | `agent-browser` | Measure this product's rendered surface through isolated sessions and fresh navigation. |

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

**Read:** [references/build.md](references/build.md); keep it loaded through Phase 5. Read [Run live browser proof](references/verification.md#run-live-browser-proof) before the slice's browser check.

**Act:** Build foundations. Then prove one thin path from data through the gallery and a real application route.

**Exit gate:** The [Foundation gate](references/build.md#foundation-gate) and the [Vertical slice gate](references/build.md#vertical-slice-gate) both pass.

## Phase 5 — Component families

**Read:** Continue [references/build.md](references/build.md).

**Act:** Build only accepted dependency nodes. Brief each family worker with [templates/helper-brief.md](templates/helper-brief.md). Assign one work owner to each component, shared symbol, shared file, process, and worktree. Route integration through one serial integration owner.

**Exit gate:** Every in-scope family passes [Family completion](references/build.md#family-completion).

## Phase 6 — Gallery and application integration

**Read:** [references/verification.md](references/verification.md); keep it loaded through Phase 7.

**Act:** Integrate navigable gallery sections and real application routes. Use coherent scenarios. Exercise style generation, assets, authentication, API paths, route ownership, and supported startup behavior.

**Exit gate:** Every item in [Integration completion](references/verification.md#integration-completion) holds.

## Phase 7 — Acceptance and handoff

**Read:** Continue [references/verification.md](references/verification.md).

**Act:** Run static checks, rendered checks, real journeys, independent review, project quality roles, and the full project gate. Work through [templates/integration-cleanup-handoff.md](templates/integration-cleanup-handoff.md).

**Exit gate:** Every item in [Acceptance completion](references/verification.md#acceptance-completion) holds.

## Final report

Fill the handoff record in [templates/integration-cleanup-handoff.md](templates/integration-cleanup-handoff.md). Label every proof item as a claim or a receipt. A claim names its kind: walkthrough, scanner run, screenshot, or worker report.
