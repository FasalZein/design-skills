---
name: design-craft
description: Universal design principles for AI agents to produce world-class UI. Typography, color, spacing, animation, layout, interaction, component patterns. Eliminates AI slop. Use when building any UI — pages, components, dashboards, forms, landing pages.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.css", "**/*.scss"]
---

# Design Craft

Constraints + Consistency + Restraint = Quality. This skill makes LLMs produce world-class UI instead of generic slop.

**The core problem:** LLMs converge on the statistical median of every Tailwind tutorial and Bootstrap template. The result is generic, safe, forgettable. This skill enforces specific, opinionated rules that break out of that median.

---

## Anti-Slop Rules (CRITICAL)

These are the fingerprints of AI-generated UI. Violating even one makes the output look machine-made.

| AI Slop Pattern | Why It Screams "AI" |
|---|---|
| Purple-to-blue gradient hero | Single most common AI training pattern |
| Gradient text on metrics/headings | Decorative without purpose |
| Dark mode + glowing accents as default | Avoids actual design decisions |
| Glassmorphism everywhere | Overrepresented in 2021-2023 training data |
| Hero metrics (big number in card) | Generic SaaS template layout |
| Three identical icon-card grid | Appears in 90%+ of template sites |
| Inter/Roboto/Arial as default font | No brand consideration |
| Large rounded-corner icons above headings | Templated, adds no value |
| Cards inside cards | Visual redundancy |
| Sparklines as decoration | Tiny charts conveying nothing |
| Same padding everywhere | No visual rhythm |
| Everything centered | Feels undesigned |
| Every button is primary | No hierarchy |
| Glow effects as primary affordances | Decorative noise |
| "John Doe", "Jane Doe", "Acme Corp" as placeholder names | The Jane Doe Effect — training-data leakage |
| "99.99%", "50%" as fake metrics | Round/predictable numbers = placeholder content |
| "Seamless", "Unleash", "Next-Gen", "Elevate" as copy | AI copywriting clichés, zero content value |
| "lorem ipsum" in any form | Never acceptable as placeholder content |
| ALL CAPS labels, tabs, or headings | Shouting hierarchy substitute |
| Title Case everywhere | All nouns capitalized = no sentence case = AI tell |

**Hero Metrics — the #1 dashboard slop pattern:**
3-4 identical cards in a row, each with: icon + big number + small label + change indicator. NEVER use this layout. Instead: inline key-value pairs in a single bar, a single prominent metric with context below, or stats integrated into the content they relate to.

> "If you showed this interface and said 'AI made this,' would they believe you immediately? If yes, that's the problem."

---

## Reference Files

**For full pages, sites, or multi-component builds:** Load ALL reference files before writing any code. Every page involves typography, color, spacing, layout, and components — skipping references means skipping rules.

**For single-component work:** Load the relevant reference(s) for that area:

| Area | File | When to load |
|------|------|-------------|
| Typography | [reference/typography.md](reference/typography.md) | Font choices, type scale, tabular-nums, text-balance, line-height |
| Color | [reference/color.md](reference/color.md) | Semantic tokens, OKLCH, dark mode, contrast, 60-30-10 rule |
| Spacing | [reference/spacing.md](reference/spacing.md) | 4px grid, semantic spacing tokens, border radius, shadows |
| Motion | [reference/motion.md](reference/motion.md) | Duration scale, easing curves, transitions, reduced motion, enter/exit |
| Layout | [reference/layout.md](reference/layout.md) | Grid/flex, h-dvh, z-index scale, sidebar hierarchy, responsive, progressive disclosure |
| Components | [reference/components.md](reference/components.md) | Composition model, interaction states, empty states, error messages, UX writing |
| Data-Dense UI | [reference/data-dense.md](reference/data-dense.md) | Tables, dashboards, financial data, performance |

---

## Conflict Priority Order

When requirements conflict, sacrifice in this order (last = drop first):

1. **Functional integrity** — layout must not break, content must not clip
2. **Readability** — text must be legible, hierarchy must be clear
3. **Spatial rhythm** — spacing must create grouping and flow
4. **Motion polish** — transitions and animations
5. **Decorative novelty** — visual flair, creative flourishes

Never sacrifice layout integrity to preserve decorative ambition.

---

## The Design Decision Checklist

Before writing any UI code:

- [ ] Committed to a specific aesthetic direction (not "modern" or "clean")
- [ ] Defined the typeface (not a default)
- [ ] Established color system with semantic tokens
- [ ] Set the spacing scale
- [ ] Designed light mode first (dark mode = theme swap on semantic tokens)
- [ ] ONE primary action per view identified
- [ ] All interactive elements have 8 states planned
- [ ] Empty states and error states designed (not afterthoughts)

---

## Self-Check (MANDATORY before finishing any UI work)

Re-read every line of code you wrote or modified. Verify against these 10 checks:

1. **No slop patterns** — Zero purple gradients, glassmorphism, glow, gradient text, hero metrics, identical card grids
2. **No hardcoded colors** — Every color uses semantic tokens (bg-primary, text-muted-foreground). Zero Tailwind palette colors with numeric suffixes (bg-blue-500, text-red-600). Zero hex/rgb/hsl in JSX.
3. **No arbitrary values** — No `text-[13px]`, `p-[17px]`, `w-[423px]`. Use the scale.
4. **No `h-screen`** — Use `h-dvh`
5. **Interaction states complete** — Every `<button>` has `hover:*`, `focus-visible:ring-2 focus-visible:ring-ring`, `active:scale-[0.97]`, `disabled:opacity-50 disabled:pointer-events-none`. Zero buttons missing any state.
6. **Async actions have loading state** — Every form submit/save/delete button disables during action and shows "Saving...", "Deleting..." text. Uses `aria-busy={isLoading}`.
7. **Empty/error states** — Every async list has empty state with CTA, every action has inline error handling
8. **No `transition-all`** — Specify exact properties: `transition-colors`, `transition-transform`, `transition-opacity`
9. **Labels on all inputs** — Every `<input>` has a visible `<label>`. Placeholder is not a label.
10. **Destructive actions use alert dialog** — Delete/discard/overwrite use `role="alertdialog"` or AlertDialog component

If ANY fail, fix before responding. Do not explain the violation — just fix it.

---

## Tooling Integration

Run the design scanner after completing UI work (if available in the project):

```bash
bash design-qa/scripts/design-scan.sh [target-dir] --fix
```
