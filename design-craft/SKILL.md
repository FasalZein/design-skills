---
name: design-craft
description: Phase router for UI design work (intake, direction, build, refine, verify, report); app-UI craft rules live in reference/app-ui.md.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html", "**/*.css", "**/*.scss"]
disable-model-invocation: true
---

# Design workflow

Work the phases in order. Load a phase's skills when the phase starts: read the skill's SKILL.md at its path in the Skill map below. A skill from an earlier phase stays done; reload it only for a new question.

The app-UI craft rules (Hard Guardrails, Project Context Scan, Design Decision Gate, References, Type, Color Kernel, Spacing Kernel, Symptom → Correction, Conflict Priority) live in [reference/app-ui.md](reference/app-ui.md).

## Skill map
Read each SKILL.md whole (no offset or limit) with the read tool at the path below. A skill appears at its first phase; later phases name it only. Paths inside a skill (reference/, scripts/) are relative to its SKILL.md folder; use them as absolute paths. A skill that is not in the map: use the skill registry (in pi, the path that <available_skills> lists), or record it as missing.

| Phase | Skill | SKILL.md |
|---|---|---|
| 0 Intake | design-md | ~/.agents/skills/design-md/SKILL.md |
| | shadcn | ~/.agents/skills/shadcn/SKILL.md |
| | coss | ~/.agents/skills/coss/SKILL.md |
| | coss-particles | ~/.agents/skills/coss-particles/SKILL.md |
| | agent-browser | ~/.agents/skills/agent-browser/SKILL.md |
| 1 Direction | design-taste-frontend | ~/.agents/skills/design-taste-frontend/SKILL.md |
| | grill-design | ~/.agents/skills/grill-design/SKILL.md |
| | prototype | ~/.agents/skills/prototype/SKILL.md |
| | variant | ~/.agents/skills/variant/SKILL.md |
| | state-machine | ~/.agents/skills/state-machine/SKILL.md |
| | laws-of-ux | ~/.agents/skills/laws-of-ux/SKILL.md |
| | impeccable | ~/.pi/agent/skills/impeccable/SKILL.md |
| | explain-interface | ~/.agents/skills/explain-interface/SKILL.md |
| 2 Build | better-layout | ~/.agents/skills/better-layout/SKILL.md |
| | better-typography | ~/.agents/skills/better-typography/SKILL.md |
| | better-colors | ~/.agents/skills/better-colors/SKILL.md |
| | better-ui | ~/.agents/skills/better-ui/SKILL.md |
| | better-accessibility | ~/.agents/skills/better-accessibility/SKILL.md |
| | better-writing | ~/.agents/skills/better-writing/SKILL.md |
| | copywriting | ~/.agents/skills/copywriting/SKILL.md |
| | animate | ~/.agents/skills/animate/SKILL.md |
| | apple-design | ~/.agents/skills/apple-design/SKILL.md |
| | emil-design-eng | ~/.agents/skills/emil-design-eng/SKILL.md |
| | make-interfaces-feel-better | ~/.agents/skills/make-interfaces-feel-better/SKILL.md |
| | animation-vocabulary | ~/.agents/skills/animation-vocabulary/SKILL.md |
| | ask-sonner | ~/.agents/skills/ask-sonner/SKILL.md |
| | mobile-native | ~/.agents/skills/mobile-native/SKILL.md |
| | also: laws-of-ux, variant | |
| 3 Refine | find-animation-opportunities | ~/.agents/skills/find-animation-opportunities/SKILL.md |
| | improve-animations | ~/.agents/skills/improve-animations/SKILL.md |
| | better-interface | ~/.agents/skills/better-interface/SKILL.md |
| | also: impeccable | |
| 4 Verify | design-qa | ~/.agents/skills/design-qa/SKILL.md |
| | break-ui | ~/.agents/skills/break-ui/SKILL.md |
| | break | ~/.agents/skills/break/SKILL.md |
| | review-animations | ~/.agents/skills/review-animations/SKILL.md |
| | also: impeccable, design-taste-frontend, state-machine, agent-browser | |

## Rules for every phase
- **Direction before the first edit.** Phase 1 ends with a DIRECTION line. No file changes before it.
- **Let the UI explain itself:** never add text that says what a screen, section or control is (subtitles that restate the heading, "This shows..." intros, filler CardDescription); add text only for information the UI cannot show.
- **Tokens are material, not a direction.** Existing tokens and components are what you build with. The direction comes from DESIGN.md, the brief or phase 1; the Project Context Scan in reference/app-ui.md grades tokens as owned or stock, and stock tokens never count as a direction.
- **One rule set per surface.** Precedence: DESIGN.md, the brief, then design-taste-frontend's house rules (public pages) or reference/app-ui.md (app UI), then the domain skills.

## 0 Intake (read only)
1. Every path under "Read first" in the brief.
2. DESIGN.md anywhere in the repo (`rg --files -g DESIGN.md`), docs/design/, UX or UI specs. When DESIGN.md exists or phase 1 must write one, load design-md.
3. Tokens: Tailwind theme or `@theme`, global CSS custom properties, token files. Grade them owned, stock, or none with the Project Context Scan in [reference/app-ui.md](reference/app-ui.md).
4. Component layer: components.json -> shadcn. coss or Base UI in package.json -> coss (coss-particles is its example index).
5. The two nearest sibling screens and the gallery route, if the repo has one. When the app runs, screenshots of the current UI with a browser that renders pixels (agent-browser-chrome in pi).

Done when you can name the direction source, the token grade, the tokens and components you reuse, and the screens you mirror.

## 1 Direction
Take the first branch that fits:
- **Approved direction exists** (DESIGN.md, the brief, or the brief scopes a slice of an approved system): adopt it. DIRECTION: its source. When the user is present and the brief leaves one piece's look open, run grill-design for that piece only, starting at its level of the design tree.
- **User present** (an attended session, such as the design agent in its pi pane): run grill-design before any file edit; it is the entry point for every open look or flow. It drives grilling with prototype rounds (the prototype skill's UI branch). Seed and extend it:
  1. Overall look: deal directions with design-taste-frontend's draw (its section "3. Draw the direction"). Page: `--options 5`. App screen: `--app --kind <kind>`, plus `--keep palette,type` when the brand fixes colors or fonts. Build each dealt direction as one prototype behind one picker: inside the app when it runs, otherwise one standalone HTML file under your artifact directory, opened with `open <file>`.
  2. Zoom in, one level per verdict: component groups -> variant (one axis per round). One component's states -> state-machine. Flow questions -> laws-of-ux. A critique of the leading option -> impeccable critique. A site the user names as a reference -> explain-interface.
  3. Every verdict is the user's: ask it as a structured question (ask_user in pi). The step is done when the user approves the overall look and each group they raised.
  4. Write the approved direction into DESIGN.md with design-md: the dealt sheet, the verdicts, the tokens. Remove the prototype harness on the user's word.
- **No user, new or restyled surface**: deal with design-taste-frontend's draw as above and choose per its step 3. An unattended builder (design-builder in pi) builds the choice and reports `DIRECTION: self-picked <id>`. An attended designer (the design agent in pi) renders the options as prototypes, reports them with screenshots and stops with a DECISION NEEDED block.

Done when the DIRECTION line is written.

## 2 Build
1. Rules: app UI -> [reference/app-ui.md](reference/app-ui.md) (its Project Context Scan, its Design Decision Gate within DIRECTION, and each reference file whose trigger fires in its References section). Public page -> the dealt sheet plus design-taste-frontend's "6. Build it, still" and "House rules".
2. Before the first edit, load the skill for each signal in the brief or in the files you change:

| Signal | Skill |
|---|---|
| navigation, forms, multi-step flows, CTAs, feedback, error recovery | laws-of-ux |
| grouping, responsive structure, breakpoints, safe areas, RTL, translated text | better-layout |
| type scale, font loading, wrapping, truncation | better-typography |
| palette, semantic tokens, contrast, dark mode | better-colors |
| radius, shadows, borders, icons, enter and exit | better-ui |
| custom controls, dialogs, focus, keyboard, screen reader, reduced motion | better-accessibility |
| labels, errors, empty states, confirmations | better-writing |
| marketing page copy | copywriting |
| a new animation | animate; springs, gestures, sheets -> apple-design; feel and polish calls -> emil-design-eng, make-interfaces-feel-better; naming an effect -> animation-vocabulary |
| toasts | ask-sonner |
| web UI used on phones | mobile-native |
| one piece whose form is still open | variant: build its variants on the real page, take the one that fits DIRECTION, promote it, delete the rest |

3. Implement. Run the typecheck (project script or `tsc --noEmit`). Before renaming a component or prop, find every use with `rg -n -w`.

Done when the typecheck passes and the skill of every fired signal is read.

## 3 Refine
One whole-screen pass against DIRECTION with an impeccable sub-command. Read impeccable's SKILL.md and run its Setup with the playbook for one sub-command: polish (details), distill (too busy), quieter or bolder (wrong volume for DIRECTION), harden (edge cases, errors, i18n), clarify (copy), delight (one authored moment), typeset, colorize or layout (one domain is off). The direction is set, so skip impeccable's new-work playbook. Missing motion -> find-animation-opportunities. Existing motion code -> improve-animations. A review across the better-* domains -> better-interface.

Done when the pass is applied, or you record "no pass needed" with the reason.

## 4 Verify
1. Mechanical checks. Load design-qa and run its scanner; exit 2 means QA is incomplete. Run impeccable detect: `<impeccable skill dir>/scripts/impeccable detect --json <changed files>`, and on the running URL with `--viewport 390x844` and `--viewport 1440x900`. Public pages: also design-taste-frontend's lint and inspect scripts (its section "7. Gate").
2. States. A component with data, account or feature states -> state-machine page; every state becomes a `?__state=` URL.
3. Worst-case data. Every component you built or changed that renders data (names, emails, counts, lists, tables, cards, badges, timestamps) gets a break-ui pass: its worst-case, empty, one and huge fixtures behind its toggle, checked at the real container width, 320px and 200% zoom. An unattended builder (design-builder in pi) runs it in its `<component> + fix` form: apply every fix outside "Decisions for you", then list those decisions in the report. An attended designer reports the breaks and waits for the user. All scenarios on one page for a single look -> break.
4. Gate 12 per design-qa's live-verification runbook, in a browser that renders pixels for every command. In pi, set `AB="agent-browser-chrome --session <app>-qa"`; plain agent-browser renders no pixels. Shoot every state at every viewport. Motion code -> review-animations.
5. Read every screenshot against DIRECTION: the alignment of each lockup (icon and text, label and value, date blocks), spacing rhythm, hierarchy, and every visible sentence. Delete each sentence that restates what the UI shows. Fix, then re-shoot.
6. Harnesses (state-machine, break, variant): an unattended builder (design-builder in pi) removes them before it reports, unless the brief keeps them; the break-ui worst-case fixture stays as the component's regression data. An attended designer (the design agent in pi) removes them on the user's word.

Done when the scanner exits 0, each detect finding is fixed or justified in the report, every data component had its break-ui pass, and every state-by-viewport screenshot was read after the last fix. The repair-attempt limit in your inherited rules is the ceiling.

## 5 Report lines
```
DIRECTION: <DESIGN.md path | brief | self-picked <id>> - one line
SKILLS: loaded <names>; skipped <names, one reason each>
REFS: reference files read and the trigger that fired, or "none triggered"
QA: scanner score, detect findings, gates run, screenshot folder
```
