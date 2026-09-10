# Gallery, Live Verification, Acceptance, and Handoff

## Build a real gallery

The gallery is a working product surface. It provides:

- navigation by foundation, family, page, or another clear structure
- coherent shared scenarios
- meaningful states
- real controls and transitions
- required visual modes and device classes
- source and license traceability
- visible labels for proposed data and temporary assets

Each component entry states its props, data source, states, responsive behavior, accessibility behavior, and source action.

A gallery simulation cannot prove authentication, live APIs, application style generation, or real assets.

A fixture illustration proves layout behavior only. It does not prove the approved product asset.

## Prove application integration

Check the real application chain:

- package exports
- style generation and content scanning
- theme and font loading
- public asset paths
- route ownership
- authentication and authorization
- API client and service route
- loading and error behavior
- responsive layout
- startup and shutdown lifecycle

Exercise one real journey per affected application. Use live local services when project policy requires them.

If a service shape is proposed, live proof stops at the documented seam.

## Prove the supported lifecycle

Run the project-supported startup command. Record every process, process identifier, route-registry entry, public hostname or port, and URL that the command owns.

Obey the [occupied-route rule](build.md#worktrees-and-processes).

A temporary preview or standalone gallery is a workaround when the supported lifecycle does not own it. Startup succeeds only after the supported lifecycle starts and stops the surface correctly.

## Integration completion

Integration is complete when:

- the supported lifecycle owns each recorded process, hostname or port, and route
- the gallery loads through the supported lifecycle
- each affected application loads its real route with package exports, style generation, theme, fonts, and public assets
- authentication and authorization paths were exercised
- each real API path was exercised, or its proposed seam is labelled
- every temporary preview or standalone gallery is recorded as a workaround, never as startup

## Run live browser proof

Use an isolated `agent-browser` session for each concurrent verifier.

Derive the viewport, mode, and state matrix from project policy and owner decisions.

For every required cell:

1. set the viewport before navigation
2. navigate fresh
3. create the state through the application or an approved fixture
4. exercise the interaction
5. capture console and page errors
6. inspect failed requests
7. measure overflow
8. inspect landmarks and heading order
9. inspect keyboard and focus behavior
10. measure target size and contrast
11. check reduced motion when applicable
12. save the screenshot
13. read the screenshot back

A screenshot counts only when the file contains the intended rendered state and a reviewer reads it back.

Blank, loading-only, failed, stale, wrong-section, wrong-mode, or unrelated images do not prove the cell.

After a visual repair, repeat and read back the failed cell. A sibling image cannot replace a missing cell.

Mount real application chrome when overlays, toasts, drawers, or fixed navigation can collide with the component.

## Keep test evidence reliable

A valid check can fail for the defect that it guards.

Keep these results open:

- unrun committed tests
- skipped required tests
- focused-only test runs
- weakened or deleted assertions
- timeouts under resource contention
- mock-only checks for a required live path

If contention causes a timeout, run the same unchanged code on an idle host. The gate stays red until a reliable result exists.

For a bug correction, add the check that detects the bug.

## Run independent receipts

Use the project review and landing process. Preserve these functions:

- targeted family checks
- type and lint checks
- complexity and code-shape review
- tests that can fail
- full-suite proof on unchanged code
- independent code review
- independent product acceptance

If the project defines cleaner then hardener, require both receipts in that order.

A worker report, gallery test, scanner pass, screenshot set, or implementer full-suite run does not replace the required independent receipt.

Close external work items only when every acceptance line has evidence and the owner authorized the update. Read each update back.

## Clean exact owned state

Before cleanup, inspect each task-owned item:

- exact process identifier, route owner, and route-registry entry
- worktree path and owner
- dirty files
- branch and ancestry
- unpushed commits
- generated files
- temporary assets
- issue status

Stop, remove, or update only the exact item that this task owns and policy permits.

Keep uncertain state. Report it instead of using broad process termination, forced worktree removal, or blind generated-file restoration.

Record any known uncommitted loss as loss.

## Acceptance completion

Acceptance is complete when:

- every approved matrix row has direct evidence
- every required browser cell has a valid read-back screenshot
- every required browser probe has a measured result
- every real journey reaches its authoritative boundary
- design-qa status is honest and complete
- targeted checks pass
- independent review receipts pass
- the full authoritative project gate passes on unchanged code
- every check reports its real state: green, red, or unrun
- cleanup accounts for every task-owned process, route-registry entry, hostname or port, worktree, branch, and file
