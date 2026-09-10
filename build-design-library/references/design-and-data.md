# Coverage, Design Decisions, and Shared Data

## Reconcile product coverage

Create one matrix row for each approved page and meaningful state.

Resolve every row to:

- exactly one family owner, or
- one authorized and dated drop reason

A page can use multiple families. Each component still has exactly one owner.

A family heading does not count as component coverage. A duplicate family claim is a conflict.

Before fanout, an independent reviewer compares the matrix, component ownership, field map, service contracts, and design record with binding policy. Record the reviewer, artifact, and `pass` or `block` receipt.

The gate fails if any policy break, dual owner, unowned approved row, or unresolved API contradiction remains.

## Build the design tree

Use this dependency order:

1. brand assets
2. tokens and type
3. semantic roles
4. primitive controls
5. shared product states
6. domain components
7. component families
8. page assemblies
9. application routes

A higher level uses behavior from its dependencies. It does not create a second owner for that behavior.

## Build the visual identity

In brownfield work, catalog and use shipped tokens. Derive only missing roles that match the existing system. Measure the real rendered result.

Create an owned visual identity through approved typography, information density, composition, state treatment, navigation, assets, and one recognizable product signature.

A source library supplies material. It does not supply the final identity unchanged.

An interaction rule conflict resolves through product authority and owner choice.

## Run owner decisions

Use runnable prototypes for visual or interaction forks that prose cannot prove.

Each prototype uses the same content and coherent scenario. Show required modes, device classes, meaningful states, and working interactions.

Record:

- authoritative constraints
- options and trade-offs
- recommendation and evidence
- owner choice
- rejected options
- change cost
- affected pages and checks

A temporary fallback or stub exists only when explicit owner approval evidence names its owner and deletion plan. Otherwise, the affected work stops.

A generated illustration can be a named temporary fixture. It cannot claim owner approval or prove the real product asset.

## Create shared scenarios

Create safe, deterministic scenarios before family fanout.

One entity keeps the same identity, time, status, permissions, and derived values across pages.

For each field, record:

- name and type
- unit and precision
- unavailable meaning
- authoritative source
- role and application visibility
- formatting rule
- invariant
- fixture derivation
- `implemented` or `proposed` status

Keep exact values in the project's authoritative representation.

Use fixed clocks, stable identifiers, and seeded generators when evidence must be reproducible.

Keep secrets, personal data, customer records, and restricted production values out of fixtures.

Map raw service or vendor errors through approved product copy before they reach the interface.

Render authoritative API limits and fees. Use owner-approved constants only when the decision record names them.

## Prove coherence

Write checks for each cross-page invariant. Examples include:

- totals agree with their rows
- state changes obey the allowed graph
- time zones agree across pages
- unavailable resources cannot be submitted
- role restrictions agree across surfaces
- operations-only fields remain in their authorized surfaces

A fixture-only check cannot prove a live route.

## Coverage completion

The phase is complete when:

- every matrix row has one family owner or one authorized drop
- every component has exactly one owner
- the independent coverage-review receipt is `pass`
- design-craft and laws-of-ux routing status is recorded
- every material owner choice is resolved, safely deferred, or stopped
- scenario data is deterministic, coherent, and safe
- unserved data is labelled `proposed`
- no threshold, fee, quota, or business rule lacks authority
- every invariant has a check that can fail
