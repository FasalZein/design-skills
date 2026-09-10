# Foundations, Family Graph, and Integration Control

## Foundation gate

Build and verify these shared foundations first:

- shipped or approved token and asset loading
- typography and number formatting
- semantic status rules
- loading, empty, error, confirmation, and notice patterns
- shared fixture exports
- gallery shell and navigation
- source and license records
- base responsive behavior

One work owner controls each shared foundation. Families consume accepted foundations instead of creating local replacements.

The foundation gate passes when every foundation above has its targeted checks green and its own independent receipt.

## Vertical slice gate

Choose one representative journey that crosses:

`authoritative or proposed data → component → gallery → application route → browser`

The slice proves:

- one real interaction
- one meaningful non-ready state
- responsive behavior
- keyboard and screen-reader behavior
- style and asset loading
- route and service behavior at the documented seam
- one browser cell with a [valid capture](verification.md#valid-capture)

Correct shared faults before fanout.

The slice is accepted only after its named targeted checks and its own independent receipt pass.

## Dependency graph

Represent family dependencies as a directed acyclic graph.

For every node, record:

- prerequisites and accepted receipts
- dependents
- component and shared-symbol ownership
- owned files
- shared files read
- shared files changed
- process and worktree ownership
- integration point
- acceptance owner

A downstream family starts only when each upstream dependency has an accepted receipt.

A temporary stub satisfies the [owner-approval rule](design-and-data.md#run-owner-decisions). Record its acceptance limit with that evidence.

A late sibling stays the sibling owner's work; the downstream family waits or uses an approved stub.

## Family brief

Write each brief on [helper-brief.md](../templates/helper-brief.md). It defines:

- scope and exclusions
- pages and journeys
- component list
- props and data shapes
- states and interactions
- responsive behavior
- accessibility behavior
- source action and license duties
- accepted dependencies
- shared scenario use
- targeted checks
- gallery proof
- application proof
- result and artifact paths

Workers report blockers and early artifacts when they appear.

## Ownership and integration

Assign one work owner to every component, exported symbol, shared file, generated file decision, process, and worktree.

Family workers edit their owned files. The serial integration owner applies shared registrations and cross-family changes.

Integrate by intent: compare both sides with the accepted contract. Generated API files, lockfiles, route trees, barrels, and shared registries require source-aware reconciliation.

Run a duplicate-symbol and ownership check after each integration.

Prefer family or section tests over repeated full-gallery renders.

## Resource-aware concurrency

Choose concurrency from measured evidence:

- dependency readiness
- processor and memory load
- active browser and development processes
- test worker behavior
- database or service isolation
- worktree availability
- shared-file ownership
- integration capacity

A test that times out under contention keeps the gate red. Re-run it on an idle unchanged tree before you blame the code.

Worker counts and timeouts change only from measured evidence and project authority.

## Worktrees and processes

Follow project policy. Record each worktree path, branch, owner, base commit, current commit, dirty state, and acceptance receipt.

Start processes through supported commands. Record each exact process identifier, public hostname or port, route-registry entry, and owner.

Before you bind a public hostname, port, or route, inspect its owner. If another session owns it, use a unique session or preview port, or attach read-only.

Stop only a process that this task started. Remove only a worktree that this task owns after you inspect dirty state and ancestry.

Inspect generated-file diffs before restore or deletion. A generated change can contain real route or schema work.

## Family completion

A family is complete when:

- all upstream receipts exist
- owned scope matches the coverage matrix
- no sibling component was duplicated
- targeted checks pass on a reliable host
- gallery and application evidence exist
- shared registrations passed serial integration
- source and license duties are complete
- the family report names all open work
- the family's own independent receipt passes
