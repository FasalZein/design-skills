# design-skills

Your AI agent writes UI like it learned frontend from a 2021 Tailwind tutorial on YouTube. Purple gradients. Glassmorphism on everything. Three identical cards with icons above headings. A dark mode that looks like a nightclub. `h-screen` because who needs iOS Safari to work anyway.

These skills fix that.

---

## What's in the box

Three skills that layer together — craft, psychology, and quality gates.

### design-craft

The implementation rulebook. Anti-slop detection, semantic color tokens, typography scale, spacing system, animation architecture (with a frequency gate that asks "should this even animate?"), layout, interaction states, component patterns, data-dense UI, and UX writing.

Loaded as a lean router with 7 on-demand reference files — your agent only pulls the depth it needs:

| Reference | What it covers |
|-----------|---------------|
| `typography.md` | Type scale, font choices, tabular-nums, sentence case, text-balance |
| `color.md` | OKLCH, semantic tokens, dark mode, 60-30-10, inline oklch ban |
| `spacing.md` | 4px grid, border radius, concentric radius, shadows |
| `motion.md` | Frequency gate, duration scale, springs, easing, reduced motion |
| `layout.md` | Grid/flex, sidebar hierarchy, responsive, progressive disclosure |
| `components.md` | Interaction states, empty states, error messages, symptom-to-fix table |
| `data-dense.md` | Tables, dashboards, financial UI, performance |

### laws-of-ux

30 laws from [lawsofux.com](https://lawsofux.com) turned into actionable constraints. Grouped by task: reducing decision cost, building on familiarity, directing attention, shaping experience, motor cost, Gestalt perception, and robustness. Includes a decision matrix and a self-check that actually catches violations instead of vibing about "intuitive design."

### design-qa

11-gate pre-ship checklist and a sub-second scanner built on ripgrep + ast-grep. Catches accessibility violations, hardcoded colors, arbitrary spacing, AI slop patterns, missing interaction states, and more. Binary pass/fail — no ambiguity, no "looks good to me."

---

## Installation

### Any agent that supports skills

```bash
npx skills@latest add FasalZein/design-skills
```

Install a specific skill:

```bash
npx skills@latest add FasalZein/design-skills --skill design-craft
npx skills@latest add FasalZein/design-skills --skill design-qa
npx skills@latest add FasalZein/design-skills --skill laws-of-ux
```

### Manual install

Copy the skill folder(s) into your agent's instruction directory:

| Agent | Location |
|-------|----------|
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Codex | `.codex/instructions/` |
| OpenCode | `.opencode/instructions/` |
| Pi | Project instructions directory |
| Droid | Agent instructions directory |

Each skill is a self-contained `SKILL.md` (+ optional `reference/` folder). Drop it in, point your agent at it, done.

---

## The scanner

design-qa includes a standalone scanner that runs in ~0.2 seconds on a full React/Tailwind project. Zero config.

```bash
# Full scan with fix suggestions
bash design-qa/scripts/design-scan.sh ./src --fix

# JSON output for CI pipelines
bash design-qa/scripts/design-scan.sh ./src --json

# Skip upstream UI primitives (shadcn, etc.)
bash design-qa/scripts/design-scan.sh ./src --fix --no-ui

# Critical issues only
bash design-qa/scripts/design-scan.sh ./src --critical-only
```

**Requires:** [ripgrep](https://github.com/BurntSushi/ripgrep). Optional: [ast-grep](https://ast-grep.github.io/) for structural checks.

**What it catches:** AI slop patterns, hardcoded colors (hex, rgb, hsl, oklch inline), `h-screen`, `transition-all`, `div onClick`, `tabindex > 0`, zoom disabled, paste blocked, bare focus removal, arbitrary spacing/sizing, animation anti-patterns, nested cards, missing aria-labels.

---

## What these skills actually prevent

**Without skills:**
```jsx
<div className="min-h-screen bg-gradient-to-br from-purple-900 to-blue-900">
  <div className="grid grid-cols-3 gap-6">
    <div className="bg-white/10 backdrop-blur-xl rounded-2xl p-6">
      <div className="text-5xl font-bold bg-clip-text text-transparent
        bg-gradient-to-r from-cyan-400 to-blue-500">
        99.99%
      </div>
      <p className="text-gray-400">Uptime</p>
    </div>
    {/* copy paste two more times, change the icon, ship it */}
  </div>
</div>
```

This is what every AI agent produces when you say "build me a dashboard." It's the statistical median of every Tailwind tutorial and Bootstrap template in the training data. It screams "AI made this" from across the room.

**With skills:** The anti-slop rules fire on the gradient. The color rules fire on `bg-purple-900`. The layout rules fire on `min-h-screen`. The component rules fire on the identical card grid. The content rules fire on `99.99%`. The scanner catches whatever the rules missed. Your agent is forced to actually think about design instead of reaching for the nearest template.

---

## Architecture

```
design-craft/
  SKILL.md                  <- Anti-slop + conflict priority + self-check (auto-loaded)
  reference/
    typography.md            <- On-demand
    color.md                 <- On-demand
    spacing.md               <- On-demand
    motion.md                <- On-demand
    layout.md                <- On-demand
    components.md            <- On-demand
    data-dense.md            <- On-demand

design-qa/
  SKILL.md                  <- 11 quality gates
  scripts/design-scan.sh    <- Automated scanner (ripgrep + ast-grep)
  rules/                    <- ast-grep structural rules

laws-of-ux/
  SKILL.md                  <- 30 UX laws + decision matrix
```

The skills layer by concern:
- **design-craft** = how to build it (tokens, spacing, animation, components)
- **laws-of-ux** = why users will hate it if you don't (cognitive load, attention, memory)
- **design-qa** = did you actually follow the rules (11 gates, automated scanner)

Use all three together for maximum effect. Or pick the ones you need — they work independently.

---

## Validation

Skills are validated using autoresearch — autonomous eval loops inspired by [Karpathy's methodology](https://x.com/karpathy). Binary pass/fail evals, one mutation at a time, keep what improves the score, discard the rest. No vibes. No "looks good." Pass or fail.

| Skill | Baseline | Final | Method |
|-------|----------|-------|--------|
| design-craft | 72.2% | 100% | 6 binary evals, 3 runs per experiment |
| laws-of-ux | 94.4% | 100% | 6 binary evals, 3 runs per experiment |

Additionally cross-referenced against 19 design skills from [ui-skills.com](https://ui-skills.com) to identify enforcement gaps, missing anti-patterns, and accessibility coverage.

---

## Credits

- laws-of-ux is based on [Laws of UX](https://lawsofux.com) by Jon Yablonski
- Validation methodology adapted from [Karpathy's autoresearch](https://x.com/karpathy)

## License

MIT
