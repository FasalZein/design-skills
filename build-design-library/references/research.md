# Research and Source Verification

## Divide the work

Create nonoverlapping questions. Give each question one owner and one artifact path.

### Reference products

Study public products for information architecture, content hierarchy, interactions, responsive behavior, states, and accessibility cues.

Capture each public page as HTML export and screenshot through `firecrawl`. Record:

- exact public URL and date
- page, state, and viewport
- visible interaction evidence
- mobile redirect or application limits
- signed-in content that public access cannot reach
- blocked automation or incomplete HTML
- facts inferred from documentation instead of rendered output

Use public pages and published documents; account access, secrets, paid requests, and external writes each need explicit owner authorization.

List gated pages as gated. A public help article can explain a hidden surface, but it cannot prove the hidden render.

### Source libraries

Inspect actual source code and tests, not only demonstrations. Use the source classes and adaptation process in [component-sourcing.md](component-sourcing.md).

For each candidate, record:

- exact repository, release, commit, directory, and file
- governing license file and subtree carveout
- delivery model and source action
- framework, primitive base, and style system
- runtime and peer dependency compatibility
- registry or installation behavior
- maintenance evidence
- interaction and accessibility evidence
- copied-file, attribution, notice, and change duties
- excluded sibling paths

Installing a package needs dependency approval. Copying a file needs path-level license approval. These approvals are separate.

Run a dry resolution when project tools support one. Read the complete file and dependency plan before a write.

An independent reviewer checks every material license, compatibility, maintenance, accessibility, and data claim.

### Owned code and data

Find reusable internal assets, components, helpers, fixtures, API shapes, routes, and tests.

Classify each item as:

- reusable without change
- reusable with adaptation
- superseded
- limited to one role or application
- restricted from fixtures or publication

Prefer owned foundations when they satisfy the contract.

### Domain and safety

Find authoritative rules for:

- units and precision
- thresholds and limits
- role permissions
- destructive actions
- stale or disconnected data
- empty and unavailable values
- time zones and date boundaries
- legal or compliance labels
- data origin and visibility

Every business rule, field, and route traces to the current service contract or current public API documentation.

## Evidence record

For each material claim, record:

- source
- observation date
- direct observation or inference
- confidence
- independent check
- consequence if wrong

Conflicting claims stay open as separate rows.

## Research completion

Research is complete when:

- each approved need has source options or a build decision
- each candidate has one source action
- each source action has exact code evidence
- each copied path has a checked subtree license
- each installed package has dependency approval
- each adaptation has measured inherited behavior
- each capture limit stays visible
- each material claim has an independent check
- each question that changes scope, identity, cost, or risk reaches the owner
