# design-skills

Your AI agent writes UI like it learned frontend from a 2021 Tailwind tutorial on YouTube. Purple gradients. Glassmorphism on everything. Three identical cards with icons above headings. A dark mode that looks like a nightclub. `h-screen` because who needs iOS Safari to work anyway.

These skills fix that.

---

## What's in the box

Four skills: a user-invoked library workflow, plus craft, psychology, and quality gates.

### build-design-library

A user-invoked workflow for creating a complete product design library. It covers reference research, source and license checks, owner decisions, shared scenario data, dependency-ordered builds, real application integration, and independent proof.

The entry file routes through seven gated phases: contract, research and sourcing, coverage and owner decisions, foundations and a vertical slice, component families, gallery and application integration, acceptance and handoff. Each phase points to one reference file and the templates it fills. It uses `design-craft`, `laws-of-ux`, and `design-qa` where their checks apply. It supports new and existing products without prescribing a framework or domain.

Load it in Pi with `pi --skill ./build-design-library/SKILL.md`, then run `/skill:build-design-library`. Other skill runners must support the user-invocation flag or receive the file explicitly.

**Companion skills and tools.** The workflow resolves these by name from the runtime skill registry and loads each one before its first use: a skill by reading its `SKILL.md`, the `agent-browser` tool with `agent-browser skills get core`. A missing capability is recorded as `missing` and its checks run by hand; a missing independent reviewer records every gate as `unreviewed`, and the run stops for the decision owner.

| Skill name | Used for | Install |
|---|---|---|
| `research` | Phase 2 research streams: reference products, source libraries, domain rules. Background agents, primary sources, one cited report per stream. | [FasalZein/deep-research-skill](https://github.com/FasalZein/deep-research-skill) — `npx skills add FasalZein/deep-research-skill` |
| `firecrawl` | Phase 2 reference-product capture: competitor pages as HTML export or full-page screenshot, PDFs, site maps. Also a dependency of `research`. | [edxeth/superlight-firecrawl-skill](https://github.com/edxeth/superlight-firecrawl-skill) — `npx skills add edxeth/superlight-firecrawl-skill` |
| `exa`, `tinyfish` | Dependencies of `research` (semantic search, page fetch). | `npx skills add edxeth/superlight-exa-skill` and `npx skills add edxeth/superlight-tinyfish-skill` |
| `agent-browser` | Phases 4–7: rendered proof of this product from the vertical slice onward — measurements, interaction evidence, browser cells. Competitor pages go through `firecrawl`, never this tool. | `npm i -g agent-browser && agent-browser install` |

`research`, `firecrawl`, `exa`, and `tinyfish` need API keys: `EXA_API_KEY`, `TINYFISH_API_KEY`, `FIRECRAWL_API_KEY`. `design-craft`, `laws-of-ux`, and `design-qa` ship in this repository.

### design-craft

The implementation rulebook. Executable kernels for type, color, spacing, and interaction states live in the always-loaded SKILL.md — the decisions a strong designer would make, pre-made (exact tracking values, a deterministic name→hue palette derivation, the 4px ladder, the five interaction states). Nine hard anti-slop guardrails, each paired with what to build instead, plus an intent-and-repetition lens for context-sensitive treatments.

Branch depth loads on demand:

| Reference | What it covers |
|-----------|---------------|
| `color.md` | Gamut mapping, P3, chroma strategy, warm neutrals, contrast method, dark mode |
| `typography.md` | Font sourcing/loading, fallback metrics, variable fonts, wrapping, CJK |
| `spacing.md` | Inset/stack, density modes, block rhythm, radius, elevation, safe areas, optical alignment |
| `composition.md` | App shells, sidebars, gutters, metadata/date lockups, settings, features, pricing, proof, footers |
| `product-states.md` | Loading tiers, empty/error copy, validation timing, destructive actions, optimistic updates |
| `motion.md` | Frequency gate, duration ladder, easing, springs, gestures, reduced motion |
| `data-dense.md` | Tables, KPIs, chart selection, chart accessibility, dashboards |
| `visual-assets.md` | Icon systems, imagery pipeline, illustration roles, emoji |

### laws-of-ux

30 laws from [lawsofux.com](https://lawsofux.com) turned into actionable constraints — the rule leads, the law name follows as the generalization hook. Grouped by engineering decision: navigation, forms, flows, CTAs, feedback, grouping, copy, error recovery. Includes a decision matrix and a decision audit. Fully standalone — load it alone or with the others.

### design-qa

12-gate pre-ship checklist plus a fail-closed scanner. Gates 1–11 check source; Gate 12 verifies the **rendered page** live via agent-browser (screenshots at 375/1440px, console errors, focus cycle, measured contrast, target sizes) with a command-level runbook in `reference/live-verification.md`. Binary pass/fail — no ambiguity, no "looks good to me."

---

## Installation

```bash
npx skills@latest add FasalZein/design-skills
```

Install a specific skill:

```bash
npx skills@latest add FasalZein/design-skills --skill design-craft
```

Each skill is a self-contained `SKILL.md` (+ optional `reference/` folder). Drop it in, point your agent at it, done.

---

## The scanner

Mechanical checks only — the things regex can prove. Contextual judgment (eyebrow repetition, radius intent, warm-neutral coherence, copy quality) stays in the manual gates where it belongs.

```bash
bash "$PI_SKILL_DIR/scripts/design-scan.sh" ./src             # installed skill (repo checkout: design-qa/scripts/design-scan.sh)
bash design-qa/scripts/design-scan.sh ./src                   # human output
bash design-qa/scripts/design-scan.sh ./src --json            # pure JSON on stdout for CI
bash design-qa/scripts/design-scan.sh ./src --critical-only   # gate only Critical findings
bash design-qa/scripts/design-scan.sh ./src --allowlist FILE  # structured exceptions (CATEGORY⇥PATH_REGEX⇥REASON)
bash design-qa/scripts/design-scan.sh ./src --allow-empty     # zero supported files is not an error
```

**Requires:** [ripgrep](https://github.com/BurntSushi/ripgrep) and [jq](https://jqlang.github.io/jq/). Optional: [ast-grep](https://ast-grep.github.io/) adds structural TSX checks.

**Coverage tiers:** lexical checks on `tsx jsx ts js css scss html vue svelte astro mdx`; structural checks are TSX-only. Symlinks are not followed.

**Exit contract:** `0` scanned & passed · `1` findings broke the gate · `2` could not produce reliable evidence (bad args, missing dependency, no supported files, tool failure, invalid JSON). A green exit without `--allow-empty` proves a scan actually ran. Score is advisory; the exit code is the gate.

**What it catches:** the slop-gradient family, gradient text, gradient orbs, colored side-stripe accent bars, section-seam borders on landing pages, dead controls (`href="#"`, empty handlers), `<div onClick>`, positive tabindex, zoom disabled, paste blocked, `h-screen`/`100vh`, hardcoded colors outside `:root` tokens, arbitrary spacing/type values, tracking below the floor, layout-property transitions, `transition-all`, un-gated `console.log`.

Contract tests: `bash design-qa/tests/run-tests.sh` (committed fixtures across all supported formats).

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

This is the statistical median of every Tailwind tutorial in the training data. It screams "AI made this" from across the room.

**With skills:** the guardrails fire on the gradient, the glass, and the fake metric; the color kernel replaces `bg-purple-900` with derived semantic tokens; the composition recipes replace the identical card grid with something content-driven; the scanner and Gate 12 catch whatever slipped through — in the rendered page, not just the source.

---

## Architecture

```
design-craft/
  SKILL.md                      <- kernels + guardrails + decision gate + self-check (auto-loaded)
  reference/                    <- 8 branch files, loaded by trigger

laws-of-ux/
  SKILL.md                      <- 30 laws + decision matrix + decision audit (standalone)

design-qa/
  SKILL.md                      <- 12 gates + scanner contract
  reference/live-verification.md<- Gate 12 runbook (commands + probes)
  scripts/design-scan.sh        <- fail-closed scanner (rg + jq, ast-grep optional)
  rules/                        <- ast-grep structural rules
  tests/                        <- scanner contract tests + fixtures

scripts/verify.sh               <- repository verify (scanner tests + skill consistency)
```

The skills layer by concern:
- **design-craft** = how to build it (kernels, recipes, guardrails)
- **laws-of-ux** = why users will hate it if you don't (cognitive load, attention, memory)
- **design-qa** = did you actually follow the rules (12 gates, scanner, live verification)

Use all three together for maximum effect. Or pick the ones you need — they work independently.

---

## Validation

The repository verify command is the current gate:

```bash
bash scripts/verify.sh
```

It runs the scanner's committed contract tests (exit codes, JSON validity, per-format detection, false-positive boundaries, allowlist behavior) plus skill-consistency checks (single-source numeric rules, resolvable pointers, standalone laws-of-ux).

Historical note: earlier revisions were tuned with autoresearch — autonomous binary-eval loops (design-craft 72.2%→100%, laws-of-ux 94.4%→100% on 6 evals) and cross-referenced against 19 design skills from [ui-skills.com](https://ui-skills.com). Those scores validated the earlier revision, not this one; current changes are validated by the verify command and live multi-model build evals.

---

## Credits

- laws-of-ux is based on [Laws of UX](https://lawsofux.com) by Jon Yablonski
- Validation methodology adapted from [Karpathy's autoresearch](https://x.com/karpathy)

## License

MIT
