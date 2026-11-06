# Skills and install

Every skill the Routing table and the surface files name, with its question, its source and its install command. Sources come from ~/.agents/.skill-lock.json, checked 2026-11-02 with:

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
| better-interface | A review across domains of a built screen | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s better-interface` |
| break-ui | Renders data: worst-case fixtures and fixes | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s break-ui` |
| ask-sonner | Toasts with sonner | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s ask-sonner` |
| pick-ui-library | A new UI library is needed | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s pick-ui-library` |
| animate | Motion: a new animation | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s animate` |
| apple-design | Motion: springs and gestures | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s apple-design` |
| emil-design-eng | Motion: a feel call | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s emil-design-eng` |
| mobile-native | Phone users | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s mobile-native` |
| review-animations | Changed motion code | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s review-animations` |
| interface-review | The part changed existing UI: regressions in its diff | jakubkrehel/skills | `npx skills add jakubkrehel/skills -g -s interface-review` |
| find-animation-opportunities | What here should move? | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s find-animation-opportunities` |
| improve-animations | The owner asks to improve existing motion | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s improve-animations` |
| emil-prototype | Motion or interaction feel is open | emilkowalski/skill (not in the lock file) | `npx skills add emilkowalski/skill -g -s prototype`, then rename the folder and its `name:` field to emil-prototype |
| remove-animations | The owner says motion is too much or the app feels slow | emilkowalski/skills | `npx skills add emilkowalski/skills -g -s remove-animations` |
| match | The brief names a screen or component to recreate exactly | raphaelsalaja/skills | `npx skills add raphaelsalaja/skills -g -s match` |
| keyboard | A custom control or dialog ships | raphaelsalaja/skills | `npx skills add raphaelsalaja/skills -g -s keyboard` |
| icons | The work draws icons missing from the current set | raphaelsalaja/skills | `npx skills add raphaelsalaja/skills -g -s icons` |
| frames | The owner reports jank, or the part adds a gesture | raphaelsalaja/skills | `npx skills add raphaelsalaja/skills -g -s frames` |
| agent-browser | Any browser step; load the CLI workflow with `agent-browser skills get core` | vercel-labs/agent-browser | `npx skills add vercel-labs/agent-browser -g -s agent-browser` |

emil-prototype is Emil Kowalski's prototype skill under a new name, because mattpocock/skills already has a skill named prototype. Its SKILL.md and PICKER.md confirm the author; the exact repository path is unverified.

The five D34 additions (keyboard, match, frames, icons and remove-animations) were checked against their author installs on 2026-11-06.

The browser: the agent-browser CLI on the Chrome engine. See [live-verification.md](../design-qa/reference/live-verification.md) for engine setup.

## Optional

Load these only when installed and their trigger fires. A missing optional skill is no failure.

| Skill | Trigger | Source | Install |
|---|---|---|---|
| shadcn | The project uses shadcn (components.json) | shadcn/ui | `npx skills add shadcn/ui -g -s shadcn` |
| coss | The project uses coss or Base UI | cosscom/ui | `npx skills add cosscom/ui -g -s coss` |
| prototype | Does this state model or logic feel right? (LOGIC branch) | mattpocock/skills | `npx skills add mattpocock/skills -g -s prototype` |
| copywriting | Marketing copy | coreyhaines31/marketingskills | `npx skills add coreyhaines31/marketingskills -g -s copywriting` |
| design-md | No DESIGN.md (create), or a weak direction (improve); design agent only | FasalZein/design-md, a private repo (skills/design-md; not in the lock file) | From a checkout of that repo: `npx skills@latest add ./skills/design-md`, then the dmd CLI with `bun install` and `bun link`. The style-vault folder of the checkout is the vault |

## Platform skills, not routed

The workflow verifies web UI only. These route when a native track with its own checks exists.

| Skill | Platform | Source | Install |
|---|---|---|---|
| animate-expo | React Native and Expo motion | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s animate-expo` |
| write-swift | Swift and SwiftUI | emilkowalski/skill | `npx skills add emilkowalski/skill -g -s write-swift` |

## Out of the router

These stay installed for manual use. The router never loads them.

| Skill | Why it is out |
|---|---|
| impeccable | Its refine and detect passes overlap design-qa and the better-* skills |
| grill-design | design-craft carries its own grilling loop |
| make-interfaces-feel-better | A near copy of better-ui |
| animation-vocabulary | Owner choice: a glossary of motion terms for people |
| hallmark | A second public-page system; it contradicts the taste skill's rules |
| coss-particles | An example index for coss |
| build-design-library | A library build; the owner starts it |

Kept out of the install set: the Playful-Design/router bundle (a dispatcher over copies, a prototype name clash, and ship pushes); Raphael’s always-on principles overlap the better-* passes.
