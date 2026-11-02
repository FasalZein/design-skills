---
name: design-craft
description: Design workflow for UI work: sort the work, grill the design with prototype rounds, build the decided parts bottom-up, verify each part, report.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html", "**/*.css", "**/*.scss"]
disable-model-invocation: true
---

# Design workflow

**Design grilling** turns the open decisions into an approved DESIGN.md, with the owner, in rounds of prototypes. The **bottom-up build** then builds the decided parts, primitives first; each part passes Verify before a higher level uses it. Every run starts with Sort and ends with the Report.

## Sort the work

1. **Surface.** Read the job file of each surface in the work, once; a job file names the parts that wait for a trigger. A public page with a product demo slot has two surfaces.

| Surface | When | Job file |
|---|---|---|
| app-screen | A screen people work in: dashboard, admin, settings, form, inbox, editor | [jobs/app-screen.md](jobs/app-screen.md) |
| public-page | A page people read and scroll: landing, marketing, pricing, docs home | [jobs/public-page.md](jobs/public-page.md) |
| illustration | Faux product UI for a page slot, still or animated | [jobs/illustration.md](jobs/illustration.md) |
| from-file | A Figma file, a design image or a .pen file is the source | [jobs/from-file.md](jobs/from-file.md) |
| library | A design system or component library build | None: stop and report it; the owner starts build-design-library |

2. **Scope level.** The level of the largest unit the work asks for: product, screen or flow, component group, component, or primitive (color, type, spacing, radius, motion tokens). A section of a page is a component group.
3. **Mode.** **Attended**: the owner answers in this session through ask_user. **Headless**: no one answers; the brief is the owner's word.
4. **Report draft.** Write it under your artifact directory in the Report format.

Done when the draft holds the WORK line, the job files are read, and LOADED lists every fired route as `(pending)`.

## Loading a skill

- **Fire.** A route in the Routing table fires when its question is open or its trigger is observable in the brief, the repo or the part you build. Load a fired route when the step that needs it starts, and only then.
- **Lookup by name.** Take the first hit: the harness skill list (in pi, the location in available_skills); then `<root>/<name>/SKILL.md` for the roots ~/.pi/agent/skills, ~/.agents/skills, ~/.claude/skills, ~/.codex/skills, in that order. No hit: write `<name> (missing)` in LOADED and continue the step.
- **One skill per read call**, whole, unless the route's Notes name sections. A batch read loses text to the tool-result cap.
- **Paths inside a skill** (references/, scripts/) resolve against the folder of its SKILL.md.
- **Headless runs skip** every skill's "Initial Response" and every reply-and-wait step. The brief is the question; continue.

## Time

The report draft exists from the end of Sort and is updated after each step. When time runs short, cut scope (fewer parts, states or viewports), never steps: the static checks and the Report run in every run. A PARTIAL result carries one reason: time, gate-open, decision or scope.

## Craft floor

Every part meets this floor. Precedence, highest first: DESIGN.md, the brief, the job file, this floor, then a routed skill's values where the floor is silent. Inside an illustration stage, its job file decides window chrome, placeholders, colors and data.

- **Let the UI explain itself.** Add text only for information the UI cannot show. A subtitle that restates its heading, a "This page shows..." intro and a filler description slot each fail. A heading carries a description only when the description adds such information.
- **Wrap before truncating.** Titles, money, metric labels and button labels wrap or stay whole. Truncate only in a cell whose width the design fixes (a table cell, a list row), and keep the full text reachable.
- **One card system per screen**: one radius, border, padding and shadow set for every card.
- **Height from content.** A block is as tall as its content plus its padding; `min-height` with vertical centering is for a full-viewport hero only. Empty bands between blocks within one surface: ≤64px app/data, ≤128px marketing. Stacked section paddings may total ~192px on marketing pages; >256px is dead air anywhere. Pull the next block up or give the band content.
- **Tracking floor -0.03em** on every surface; `tracking-tighter` fails. Body text keeps 0.

| Reflex | Build instead |
|---|---|
| Purple, violet or indigo to pink gradients, gradient text, blurred gradient orbs | One flat committed surface, real media, or a tonal step from your own scale |
| Glass, glow or blur on static surfaces | Named elevation (tint + shadow); glass only on overlays with a readable fallback |
| Centered hero + identical card grid; 3-4 equal big-number cards; colored boxes or icon grids as the hero visual | A content-driven composition: an asymmetric anchor with supporting cells, or one prominent metric with context |
| Fake proof: "Trusted by 10,000+", logo marquees, "John Doe", "Acme Corp", round metrics (99.99%), fake terminal, browser or mac-window chrome | Real customers, real numbers, the real product surface, or no section |
| Colored left-border stripes on cards, callouts, schedule items, alerts | One cue: a tinted surface, or a leading dot, chip or time column (prose blockquotes pass) |
| Stock stack: chroma-0 library neutrals, `--radius` 0.5-0.625rem, Inter or Geist as the only face | Owned tokens: change neutral hue, radius and type in the token layer before composing |
| Dead controls: `href="#"`, empty onClick, toggles that do not persist | The real behavior, or no control |
| Pulse or ping on CTAs; one fade-in-up on every section | Motion that shows feedback, state or a spatial relation, bounded to its role |
| Template copy: "Seamlessly", "Effortlessly", "Streamline", "Unlock", "It's not just X, it's Y", "Welcome to our platform" | The concrete claim: what the product does, for whom, in specific verbs |

A context-sensitive treatment (warm neutrals, texture, large radii, uppercase micro-labels, dark sections) passes when it carries state, hierarchy, information or brand meaning and stays bounded to a named role. Two or more of these together are a tell: eyebrows on several sections, numbered markers outside a real sequence, radius 24px or more outside a declared soft direction, cards nested in cards, identical icon-heading-line cells, a new background color per section.

## Design grilling (attended)

The owner decides; you find the facts and build the prototypes. Headless runs take step 1 alone, reading the facts themselves, then go to the build; an open decision there follows "Open parts".

1. **Gather facts.** Read the brief and every file it names; DESIGN.md anywhere in the repo (`rg --files -g DESIGN.md`), docs/design/ and UX or UI specs; the token layer and the component layer; the two nearest sibling screens and the gallery route, if one exists. Send each fact you cannot read to a child: scout for the existing code, researcher for reference products, competitors and domain data. Done when the draft lists the sources read and each child's question, and no project file has changed.
2. **Map the design tree.** The root is the scope level; below it come the lower levels of Sort step 2. A decision is closed when DESIGN.md, an approved token or an existing component settles it; note that source. Go down only through levels that hold an open decision. Your job file adds the decisions its surface needs. Done when every decision in the draft's tree reads `open` or `closed: <source>`.
3. **Ask a round.** The **frontier** is every open decision whose parent decisions are closed. Fire the routes of the frontier's levels; for an open overall look, the Product look route deals the options and supplies the house rules. Build, check and ask the round with [direction.md](direction.md). A question that waits on a running child waits; ask the rest now. Done when the owner has answered every question of the round.
4. **Record each verdict** in DESIGN.md as the owner makes it, with the template in direction.md, then recompute the frontier. Repeat from step 3 until the frontier is empty. A small section can finish in one round; a whole page usually takes the page, its sections, its open components, and a primitives sheet when it adds tokens. Done when every decision in the tree is closed.
5. **Approve.** Ask the owner to approve DESIGN.md as written. Done when the owner approved it and DIRECTION in the draft names its path.

## Bottom-up build

1. **Order the parts.** List the parts DESIGN.md (or the brief) names, by level: primitives, then components, then screens. A part is **decided** when every decision it needs is closed, else **open**. Done when the draft lists each part with its level, decided or open, and the parts it uses.
2. **Send or take.** The design agent sends each decided part whose lower-level parts passed Verify to a design-builder, with the DESIGN.md path and the part's name; independent parts go in parallel. A design-builder builds the parts in its brief. Done when every decided part is sent or built, and every open part is in OPEN or a DECISION NEEDED block.
3. **Build a part.** Load the fired routes of the part's level and the Any rows. Implement within DESIGN.md, the job file and the floor, with the project's tokens and components. Before renaming a component or prop, find every use with `rg -n -w`. Run the typecheck (the project script, or `tsc --noEmit`). Done when the typecheck passes and every fired route in LOADED is read or `(missing)`.
4. **Verify the part** (next section). Done when the part passed Verify; only then does a higher level use it.

**Open parts.** A builder never decides an open part, and there is no self-picked direction. Build the decided parts, then stop on the open part with this block in the report; the parent asks the owner.

```
DECISION NEEDED
Q1: <question>
- <label> | value: <machine-value> | <one-line consequence>
- <label> | value: <machine-value> | <one-line consequence>
RECOMMEND: <machine-value> - <reason>
```

## Verify

Run each Verify route for the part. The static checks need no browser and run on every part. The live checks run when the brief allows a browser; take every screenshot with agent-browser-chrome. Read each screenshot against DESIGN.md and the floor: lockup alignment (icon and text, label and value), spacing rhythm, hierarchy, every visible sentence. Delete each sentence that restates what the UI shows; fix, then re-shoot.

Harness pages (pickers, state switchers, scenario pages): attended, remove them on the owner's word; headless, remove them before the report. A worst-case data fixture stays as the component's regression data.

Done when the static checks' exit codes are in the draft, the live checks ran or the draft quotes the brief line that rules out a browser, and every screenshot was read after the last fix. The repair-attempt limit in your inherited rules is the ceiling.

## Report

Fill the draft in this format. Stop every process you started.

```
RESULT: DONE | PARTIAL (time | gate-open | decision | scope) | BLOCKED
WORK: <surface>, <scope level>, <attended | headless>
DIRECTION: <DESIGN.md path> | <open parts sent to the owner>
LOADED: <question or trigger> -> <skill>, one per line, or "none fired"
VERIFY: static <scanner exit, typecheck>; live <gates, screenshot folder> | not allowed: <brief line>
FILES: <changed paths>
OPEN: <items> | none
ARTIFACT: <absolute path>
```

Done when every field holds a value and no process you started is still running.

## Routing table

Notes name the sections to read; an empty cell means the whole SKILL.md. An optional route loads only when its skill is installed. Install commands: [skills.md](skills.md).

| Level | Question or trigger | Skill | Notes |
|---|---|---|---|
| Product | Which overall look and house rules? | design-taste-frontend | "3. Draw the direction" and "House rules"; public pages: the sections in the job file |
| Product | Which reference products, competitors, domain data? | researcher (child agent) | Spawn it; it returns facts, never decisions |
| Product | How was a site the owner names built? | explain-interface | |
| Screen, flow | Navigation, form, multi-step flow, destructive action | laws-of-ux | |
| Screen, flow | A product illustration or demo on a page | stageshow | Through jobs/illustration.md |
| Screen, flow | Does this state model or logic feel right? | prototype (optional) | LOGIC branch only |
| Screen, flow | Build from a Figma file or image | build-design | Through jobs/from-file.md |
| Component | Structure, density, emphasis, type or voice is open | variant | In a round, the variants go into the round's prototype file |
| Component | Motion or interaction feel is open | emil-prototype | |
| Component | States, one at a time | state-machine | |
| Component | Every scenario on one page, for one look | break | |
| Component | Renders data: worst-case fixtures and fixes | break-ui | Headless: its "<component> + fix" form |
| Component | Custom control, dialog, focus, keyboard | better-accessibility | |
| Component | Labels, errors, empty states, confirmations | better-writing | |
| Component | Toasts with sonner | ask-sonner | A coss project uses the coss toast instead |
| Component | The project uses shadcn (components.json) | shadcn (optional) | |
| Component | The project uses coss or Base UI | coss (optional) | |
| Component | A new UI library is needed | pick-ui-library | The pick goes to the owner |
| Primitive | Palette, semantic tokens, contrast, dark mode | better-colors | |
| Primitive | Type scale, font loading, wrapping | better-typography | |
| Primitive | Spacing, grouping, responsive, RTL | better-layout | |
| Primitive | Radius, shadow, border, icons | better-ui | |
| Primitive | Motion: a new animation | animate | |
| Primitive | Motion: springs and gestures | apple-design | |
| Primitive | Motion: a feel call | emil-design-eng | |
| Any | Phone users | mobile-native | |
| Any | Marketing copy | copywriting (optional) | |
| Verify | Every part | design-qa | "## Static checks"; "## Live checks" when a browser is allowed |
| Verify | Changed motion code | review-animations | |
| Verify | Any browser step | browser-checks | Before the first browser command (pi) |
| Verify | The owner asks for a review across domains | better-interface | |
