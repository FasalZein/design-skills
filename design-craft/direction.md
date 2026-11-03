# Prototype rounds

Read this at the first round of design grilling. A round puts the whole frontier to the owner as prototypes and ends on the owner's answers. Every question about a look carries a prototype; worded options alone are never a round.

## Build the round

1. **One file per round.** One standalone HTML file under your artifact directory: `<artifact dir>/rounds/round-<n>/index.html`, with its CSS and script inline and no dev server or login. Prototypes stay in the artifact directory; they never enter the project or a branch.
2. **One picker.** A fixed bar at the bottom center of the page, with one group per frontier question. Each group lists its options by short names (A "Ledger", B "Split"), switches with a click or the number keys, and keeps the choice in the URL hash. Use these names in every question. A skill that brings its own picker (variants, states, worst-case data) puts its options into this bar.
3. **Real product data.** Names, numbers, dates and copy from the repo, its fixtures or researcher facts. A state toggle in the bar shows loading, empty, error and populated where the part has them.
4. **Options.** 5 for the overall look, 2 to 4 at lower levels. Options differ on the question's axis and stay equal on the rest: when the brand and components are fixed, vary the structure, not the look. Each option meets the craft floor; mark no favourite in the file.

Done when the file opens from disk and every option renders with real data.

## Check, open, ask

1. **Screenshot first.** Shoot every option at 1440 and 375 width with agent-browser-chrome. Read each shot; fix clipping, overflow, cut-off images, odd gaps and dead controls; re-shoot.
2. **Open it** for the owner: `open <file>`. The owner sees the file, not a list of screenshot paths.
3. **One ask_user per round.** One question per frontier decision, each with a recommended answer, worded so "yes" takes the recommendation. Q1 is the pick, with a "take parts from others" multi-select of the named parts of the other options. Add the 1 to 4 rules the prototype exposes (an order, a threshold, a label). Check every option's `value` and `preview` fields before the call.

Done when the owner answered every question; a cancelled ask is asked again once, shorter.

## Next round

Go one level deeper per verdict: the answers close decisions, and their children join the frontier. Keep the same base file and add a new round folder. When the frontier is empty, keep only the last round's prototype on the owner's word.

Hand the result off by path: the builder brief names the DESIGN.md path. A decision record written against the prototype's own tokens is no hand-off.

## DESIGN.md template

Write it at the repo root, or where the existing DESIGN.md lives. Add each verdict when the owner makes it. A DMD-generated file becomes this template first (next section).

```
# DESIGN: <product or surface>
Direction: <one line: the adjective pair and the one memorable choice>
Tree: <level> / <decision> -> <verdict> (round <n>, <date>), one per line
Tokens: <color roles, radius, spacing, elevation, motion>
Type: <faces, scale, tracking>
Layout: <shell, grid, breakpoints>
Components: <primitives and variants per role>
States: <per component: loading, empty, error, populated, and the extras>
Copy: <exact strings; words the product does not use>
Open for the build: <decisions the verdicts left open>
References: <style name> (<dmd query>), one per line, for each style a DMD run cited
```

## From a DMD-generated DESIGN.md

The DMD CLI writes evidence, not decisions: a project context, its query, generic design checks and reference styles. Rewrite it into the template before the first round: after a create run, DESIGN.md itself; after an improve run, merge improve.md into the existing DESIGN.md.

| DMD section | Template field |
|---|---|
| Context Query, Brand check | Direction |
| Color check; each style's Core Colors | Tokens (color roles) |
| Typography check; each style's Type | Type |
| Layout check; each style's Spacing & Shape | Layout, Tokens (spacing, radius) |
| Components check; each style's Components | Components |
| Content check | Copy |
| Motion check | Tokens (motion) |
| Accessibility check | States |
| Existing Design Context (improve) | The field it describes, as the owner wrote it |
| Reference Styles (names) | References |
| Project Context, Implementation Direction, Guidance | None: facts for the draft, not decisions |

1. **Keep the references.** Copy every style name the run cited into References, with the query. The full matches stay in dmd's style-context.json.
2. **Mark candidates open.** A value from a reference style is a candidate: write `open: <value> (<style>)`. A generic check text is no value; its field reads `open`. Only a line the owner wrote before the run, or a verdict, is closed.
3. **Ask from the references.** The first round's options for the overall look come from the cited styles; each option names its style.
4. **Close by verdict.** Each verdict replaces its `open:` entry with the decided value and adds its Tree line.

Done when DESIGN.md holds the template fields only, References names every cited style, and every value reads a verdict, a line the owner wrote, or `open`.
