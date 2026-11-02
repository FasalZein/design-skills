# Skills and install

Every skill the routing table and the job files name, with its question, its source and its install command. Sources come from ~/.agents/.skill-lock.json, checked 2026-11-02 with:

```
jq -r --arg s <name> '.skills[$s].source' ~/.agents/.skill-lock.json
```

The commands use the skills CLI: `npx skills add <source> -g -s <name>` installs one skill for the user (`-g`).

## Core

Install all of these. design-craft itself comes from FasalZein/design-skills: `npx skills add FasalZein/design-skills -g -s design-craft`.

| Skill | Question | Source | Install |
|---|---|---|---|
| design-qa | Did the part pass the static and live checks? | FasalZein/design-skills | `npx skills add FasalZein/design-skills -g -s design-qa` |
| laws-of-ux | Navigation, form, multi-step flow, destructive action | FasalZein/design-skills | `npx skills add FasalZein/design-skills -g -s laws-of-ux` |
| design-taste-frontend | Which overall look and house rules? | Leonxlnx/taste-skill | `npx skills add Leonxlnx/taste-skill -g -s design-taste-frontend` |
| stageshow | A product illustration or demo on a page | benjitaylor/skills | `npx skills add benjitaylor/skills -g -s stageshow` |
| explain-interface | How was a site the owner names built? | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s explain-interface` |
| build-design | Build from a Figma file or image | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s build-design` |
| variant | Structure, density, emphasis, type or voice is open | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s variant` |
| state-machine | States, one at a time | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s state-machine` |
| break | Every scenario on one page, for one look | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s break` |
| better-accessibility | Custom control, dialog, focus, keyboard | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-accessibility` |
| better-writing | Labels, errors, empty states, confirmations | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-writing` |
| better-colors | Palette, semantic tokens, contrast, dark mode | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-colors` |
| better-typography | Type scale, font loading, wrapping | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-typography` |
| better-layout | Spacing, grouping, responsive, RTL | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-layout` |
| better-ui | Radius, shadow, border, icons | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-ui` |
| better-interface | A review across domains | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-interface` |
| break-ui | Renders data: worst-case fixtures and fixes | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s break-ui` |
| ask-sonner | Toasts with sonner | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s ask-sonner` |
| pick-ui-library | A new UI library is needed | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s pick-ui-library` |
| animate | Motion: a new animation | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s animate` |
| apple-design | Motion: springs and gestures | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s apple-design` |
| emil-design-eng | Motion: a feel call | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s emil-design-eng` |
| mobile-native | Phone users | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s mobile-native` |
| review-animations | Changed motion code | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s review-animations` |
| emil-prototype | Motion or interaction feel is open | emilkowalski/skill (not in the lock file) | `npx skills add emilkowalski/skill -g -s prototype`, then rename the folder and its `name:` field to emil-prototype |
| browser-checks | Any browser step (pi) | local pi skill, not in the lock file | Copy ~/.pi/agent/skills/browser-checks |

emil-prototype is Emil Kowalski's prototype skill under a new name, because mattpocock/skills already has a skill named prototype. Its SKILL.md and PICKER.md confirm the author; the exact repository path is unverified.

The browser: the agent-browser CLI on the Chrome engine. In pi, the agent-browser-chrome wrapper sets `AGENT_BROWSER_ENGINE=chrome` and the Chrome executable path; every command of a session uses it.

## Optional

Load these only when installed and their trigger fires. A missing optional skill is no failure.

| Skill | Trigger | Source | Install |
|---|---|---|---|
| shadcn | The project uses shadcn (components.json) | shadcn/ui | `npx skills add shadcn/ui -g -s shadcn` |
| coss | The project uses coss or Base UI | cosscom/ui | `npx skills add cosscom/ui -g -s coss` |
| prototype | Does this state model or logic feel right? (LOGIC branch) | mattpocock/skills | `npx skills add mattpocock/skills -g -s prototype` |
| copywriting | Marketing copy | coreyhaines31/marketingskills | `npx skills add coreyhaines31/marketingskills -g -s copywriting` |
| pencil-design | A .pen file is the source | edxeth/pencil-design | `npx skills add edxeth/pencil-design -g -s pencil-design` |

## Out of the router

These stay installed for manual use. The router never loads them.

| Skill | Why it is out |
|---|---|
| impeccable | Its refine and detect passes overlap design-qa and the better-* skills |
| grill-design | design-craft carries its own grilling loop |
| design-md | A CLI manual; direction.md carries the DESIGN.md template |
| agent-browser | A stub that points to the CLI; browser-checks carries the rules |
| make-interfaces-feel-better | A near copy of better-ui |
| animation-vocabulary | A glossary of motion terms for people |
| hallmark | A second public-page system; it contradicts the taste skill's rules |
| coss-particles | An example index for coss |
| interface-review | A review across domains; better-interface holds that route |
| build-design-library | A library build; the owner starts it |
