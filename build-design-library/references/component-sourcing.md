# Component Sourcing and Adaptation

Named libraries below are illustrations. Check each candidate's current version, code, license, and compatibility fresh in every run.

## Start from the product need

Define the component contract before you inspect libraries:

- user task
- data and state model
- interactions
- role and permission behavior
- responsive behavior
- keyboard and screen-reader behavior
- visual identity needs
- performance limits from project evidence
- supported frameworks and versions
- source and license policy

A polished demo cannot replace this contract.

## Compare the three source classes

### Headless primitives

Headless primitives provide interaction and accessibility behavior without a complete product style.

Use them when the project needs owned visual composition and the primitive matches the current framework.

Inspect:

- focus management
- keyboard behavior
- ARIA output
- controlled and uncontrolled state
- portal and overlay behavior
- server rendering
- form integration
- runtime and peer dependencies
- bundle and tree-shaking behavior
- maintenance and release compatibility

Adapt the visual layer around the primitive. Preserve proven interaction behavior unless a measured product requirement needs a change.

Illustrations: Base UI, Radix.

### Styled copy-in registries

Copy-in registries provide source files that the project owns after import.

Use them when the source is readable, the license path permits copying, and local ownership fits project policy.

Inspect the resolved source files, not only the registry preview. Record every copied path, dependency, notice duty, and local change.

Registry commands can fetch declared files. They do not universally port internal behavior between different primitive bases.

If a component uses Radix internally, replacing imports with Base UI is a manual adaptation. Compare event models, slots, portals, state attributes, focus behavior, and keyboard behavior.

Run the adapted component through interaction and accessibility checks.

Illustrations: shadcn, coss, ReUI, 7Ovr. Delivery models differ between them.

### Purpose-built domain widgets

Domain widgets include calendars, editors, charts, data grids, maps, media controls, and other specialized surfaces.

Use them when the widget's behavior is costly to rebuild and its extension model fits the product contract.

Inspect:

- actual rendering code
- data model and formatting assumptions
- accessibility tree and keyboard support
- responsive degradation
- localization and time-zone behavior
- virtualization and large-data behavior
- extension points and style isolation
- error and empty states
- export or image behavior
- maintenance and dependency cost

Charts require more than a library selection. Check axes, labels, data access, text summaries, table alternatives, responsive degradation, and non-color cues.

Illustrations: Recharts and other chart libraries.

## Inspect code, not demonstrations

A demonstration proves only its displayed case. Read the exact implementation and tests for the states that the product needs.

Check these differences:

- demonstration props versus exported props
- sample data versus required data extremes
- visual hover versus keyboard operation
- a static screenshot versus focus and portal behavior
- desktop layout versus supported device classes
- ideal network state versus loading, empty, stale, and error states
- claimed accessibility versus measured rendered output

## License path record

Record the exact subtree for each copied file:

- repository URL
- release, tag, or commit
- source directory and file path
- license file that governs that path
- carveout or mixed-license boundary
- attribution duty
- notice duty
- change-notice duty
- excluded sibling paths
- independent reviewer and date

A repository badge or root license does not prove a nested file's terms.

Installing a package and copying a source file are different decisions. Record dependency approval separately from license-path approval.

Every recorded duty quotes the governing text. Unclear terms go to qualified license review.

## Adaptation plan

For each adaptation, record:

| Area | Source behavior | Product requirement | Change | Proof |
|---|---|---|---|---|
| Primitive base |  |  |  |  |
| Styling and tokens |  |  |  |  |
| State model |  |  |  |  |
| Keyboard |  |  |  |  |
| Focus |  |  |  |  |
| ARIA |  |  |  |  |
| Portal or overlay |  |  |  |  |
| Responsive behavior |  |  |  |  |
| Data and formatting |  |  |  |  |
| Dependencies |  |  |  |  |

Measure inherited behavior before the adaptation. Measure it again after the adaptation.

## Selection decision

Compare valid paths with their real costs:

| Action | Use when | Main cost | Required proof |
|---|---|---|---|
| `reference-only` | The pattern helps, but code reuse adds risk | Owned implementation | Product behavior and source separation |
| `copy` | The exact source fits and local ownership is accepted | Updates and license records | File-level provenance and full checks |
| `adapt` | The source structure helps, but behavior or styling differs | Manual compatibility work | Before-and-after behavior checks |
| `install` | The package API and maintenance model fit | Runtime dependency and upgrades | Dependency approval and integration checks |
| `build` | No candidate fits the contract | Full implementation and maintenance | Complete product and accessibility checks |
| `exclude` | Cost, license, compatibility, or scope fails | Lost source option | Recorded reason and alternative |

Select the smallest source action that satisfies the component contract.

## Acceptance before fanout

A source becomes an accepted dependency only when:

- its action is approved
- exact code was inspected
- the governing subtree license was checked
- compatibility was measured
- inherited interaction and accessibility behavior was measured
- dependencies were accepted
- the integration owner recorded ownership
- targeted proof passed
- an independent source-acceptance receipt records reviewer, artifact path, and `pass`

Downstream family work starts on accepted sources or an approved stub only.
