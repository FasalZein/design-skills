---
name: design-craft
description: Universal design principles for AI agents to produce world-class UI. Typography, color, spacing, animation, layout, interaction, component patterns. Eliminates AI slop. Use when building any UI — pages, components, dashboards, forms, landing pages.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.css", "**/*.scss"]
---

# Design Craft

Constraints + Consistency + Restraint = Quality. This skill makes LLMs produce world-class UI instead of generic slop.

**The core problem:** LLMs converge on the statistical median of every Tailwind tutorial and Bootstrap template. The result is generic, safe, forgettable. This skill enforces specific, opinionated rules that break out of that median.

---

## Anti-Slop Rules (CRITICAL — read first, check last)

These are the fingerprints of AI-generated UI. Violating even one makes the output look machine-made.

| AI Slop Pattern | Why It Screams "AI" |
|---|---|
| Purple-to-blue gradient hero | Single most common AI training pattern |
| Gradient text on metrics/headings | Decorative without purpose |
| Dark mode + glowing accents as default | Avoids actual design decisions |
| Glassmorphism everywhere | Overrepresented in 2021-2023 training data |
| Centered heading + subtitle + button + 3-card grid | The #1 AI layout — appears in 90%+ of template sites |
| Inter/Roboto/Arial as default font | No brand consideration |
| Cards inside cards | Visual redundancy |
| Same padding everywhere | No visual rhythm |
| Everything centered | Feels undesigned |
| Every button is primary | No hierarchy |
| Glow effects as primary affordances | Decorative noise |
| "John Doe", "Jane Doe", "Acme Corp" | Training-data leakage |
| "99.99%", "50%" as metrics | Round/predictable = placeholder |
| "Seamless", "Unleash", "Next-Gen", "Elevate" | AI copywriting clichés |
| ALL CAPS labels/tabs/headings | Shouting hierarchy substitute |
| Title Case everywhere | AI tell — use sentence case |

> "If you showed this to someone and said 'AI made this,' would they believe you immediately? If yes, that's the problem."

---

## Design Decision Gate (MANDATORY — before writing any code)

State these decisions explicitly in your reasoning:

1. **Structural archetype:** app shell (sidebar + content) · marketing page (sections + CTA) · focused tool (centered workspace) · dashboard (data-dense grid) · editorial (long-form reading)
2. **Visual density:** sparse · balanced · dense
3. **Aesthetic direction** — a specific adjective pair matched to the product, not "modern" or "clean" (e.g., "warm editorial", "stark technical", "soft organic", "bold expressive")
4. **Typeface** — chosen from the font menu below to match the aesthetic
5. **Color system** — semantic tokens, 60-30-10 rule, one accent max
6. **Hero architecture** — chosen from the hero menu below (if the page has a hero)

The archetype and density decisions drive everything else. An "app shell / balanced" produces a sidebar, top bar, and filled content area. A "focused tool / sparse" produces a centered workspace with intentional whitespace. A "dashboard / dense" fills the viewport with data.

---

## Hero & Visual Composition

Before building any hero or landing section, pick ONE architecture:

| Architecture | Layout | Use when |
|-------------|--------|----------|
| **Splitscreen** | 55/45 or 60/40 text + media, asymmetric | Product with strong visuals |
| **Editorial** | Oversized display heading (text-7xl+), minimal supporting text, no image | Brand/statement pages |
| **Full-bleed media** | Viewport-height image/video with text overlay | Visual-first brands, portfolios |
| **Asymmetric mosaic** | Unequal grid cells with mixed media + text blocks | Creative agencies, portfolios |
| **Anchored metric** | Single hero stat/number with context paragraph below | SaaS, data products |

**Hero rules:**
- Hero spacing: min `py-24 md:py-32`. Headlines: `text-5xl md:text-7xl tracking-tight`. Subtext: max 2 sentences, `text-xl text-muted-foreground max-w-[50ch]`.
- Use real imagery — `<img>` with descriptive alt text and `object-cover`, not colored boxes or icon grids. If no image is available, use bold typography as the visual element (oversized display text, typographic contrast, negative space).
- One CTA per hero. Secondary action as text link, not a second button.
- Background depth: use surface variation (tinted sections, subtle gradients, noise textures) instead of flat solid colors. Match to aesthetic direction.

---

## Typography

Pick a font based on the product's aesthetic direction:

| Aesthetic | Fonts | Character |
|-----------|-------|-----------|
| **Editorial / warm** | Instrument Sans, Source Sans 3, Libre Franklin | Readable, literary feel |
| **Technical / stark** | Geist, JetBrains Sans, IBM Plex Sans | Precise, engineering feel |
| **Friendly / soft** | Plus Jakarta Sans, Nunito Sans, Outfit | Approachable, rounded |
| **Bold / expressive** | Sora, Space Grotesk, Clash Display (display only) | Strong personality |
| **Neutral / professional** | DM Sans, General Sans, Satoshi | Clean, versatile |

The font must match the product — a fintech dashboard gets Technical/stark, a children's app gets Friendly/soft. DM Sans is fine for neutral contexts but wrong for editorial or expressive ones.

| Rule | Implementation |
|------|---------------|
| Type scale | 5 levels: Display, Heading, Body, Caption, Micro. Fewer sizes with more contrast > many close sizes. |
| Numeric data | `tabular-nums` on all numbers — prices, counts, dates, IDs, table columns |
| Headings | `text-balance`. Body: `text-pretty`. Max line length: `max-w-[65ch]` |
| Line height | Body: 1.5. Headings: 1.2–1.3. Large display: 1.0–1.1 |
| Large display text | `tracking-tight` or `tracking-tighter` on text-3xl+. NEVER add positive tracking. |
| Case | Sentence case for headings, labels, tabs, buttons. ALL CAPS only for micro-meta (timestamps, badges ≤3 words). |
| Font loading | `font-display: swap`. Sizes in `rem`/`em`, not `px`. `-webkit-font-smoothing: antialiased` on root. |
| Limits | Max 3 font weights per view. One family unless genuine display/body contrast needed. |
| NEVER | Monospace for display headings. `tracking-wide`. `user-scalable=no`. Arbitrary sizes (`text-[13px]`). |

---

## Color

Use ONLY semantic color tokens in components. NEVER Tailwind palette with number suffixes (`bg-blue-500`). NEVER hex/rgb/hsl in JSX.

```
REQUIRED tokens: bg-background, text-foreground, bg-card, bg-primary, text-primary,
  bg-secondary, bg-muted, text-muted-foreground, bg-accent, bg-destructive, border-border, ring-ring
Opacity modifiers on semantic tokens ARE allowed: bg-primary/10, border-destructive/30
Status: bg-primary/10 text-primary (success), bg-destructive/10 text-destructive (error),
  bg-accent text-accent-foreground (warning), bg-secondary text-secondary-foreground (info)
```

| Rule | Detail |
|------|--------|
| Contrast | ≥ 4.5:1 (WCAG AA). No exceptions. |
| Neutrals | Tint toward brand hue: `oklch(95% 0.01 60)` not `#f5f5f5`. Dead grays have no personality. |
| 60-30-10 | 60% neutrals, 30% secondary, 10% accent. Max 1 primary + 1 secondary accent. |
| OKLCH | Define in CSS tokens only. NEVER inline `bg-[oklch(...)]` in Tailwind classes. |
| Dark mode | Not inverted light mode. No shadows for depth (use lighter surfaces). Desaturate accents slightly. Reduce font weight (350 instead of 400). Never pure black bg. Swap semantic token layer, not component layer. |
| NEVER | Pure black/white for large areas. Gray text on colored backgrounds. Purple-to-blue gradients. |

---

## Spacing & Surfaces

4px base grid. All spacing MUST be multiples of 4px.

```
tight: 0.25rem (4px) — within atomic elements
item:  0.5rem (8px)  — between items in a group  
group: 1rem (16px)   — between related groups
section: 1.5rem (24px) — between major sections
page: 2-4rem (32-64px) — page-level margins
```

| Rule | Detail |
|------|--------|
| Spacing tokens | Use framework scale only. NEVER `p-[13px]`, `gap-[7px]`. |
| Visual rhythm | Tight within groups, generous between sections. Not the same padding everywhere. |
| Border radius | ONE base radius, derive all others. Outer = inner + padding (concentric). NEVER mix arbitrary values. |
| Shadows | Barely perceptible, multi-layer. `shadow-sm` for elevation, `shadow-md` for popovers. NEVER `shadow-lg/xl` on small components. |
| Grouping | Pick ONE method per section: borders OR shadows OR spacing. Never all three. |

**Acceptable arbitrary values:** `max-w-[65ch]`, `max-w-[45ch]`, `min-h-[*rem]`, grid-template values.
**Still banned:** `p-[17px]`, `w-[423px]`, `text-[13px]`.

---

## Layout & Composition

| Rule | Detail |
|------|--------|
| Structure | CSS Grid or Flexbox. NEVER absolute positioning for structural layout. |
| Viewport | `h-dvh` — NEVER `h-screen` (iOS Safari). |
| Overflow | `min-w-0` on flex/grid children. `flex-1 min-w-0` on flex children with text. |
| Z-index | Fixed semantic scale — NEVER `z-[999]`. |
| Safe area | `safe-area-inset` on fixed elements for mobile. |
| Container queries | `@container` for component-level responsiveness. |
| Cards | Containers, not decoration. NEVER wrap everything in cards. NEVER nest cards inside cards. |
| Touch targets | 44x44px minimum on mobile. |
| Responsive | Prefer 2-tier (mobile + desktop). NEVER hide core functionality on mobile. |

**Structural completeness** — a viewport should feel composed, not assembled with gaps:
- **App shells:** Navigation context (sidebar, top bar, or both) + full-height content area. A form in a void = missing structure.
- **Dashboards:** Fill the grid. Empty grid cells = layout hole. If 5 items in a 3-column layout, span one item across 2 columns.
- **Detail pages:** Primary content + supporting context (metadata sidebar, related items, activity feed). A single centered element on a wide screen wastes the viewport.

**Spatial composition:**
- Asymmetry over centering. `grid-cols-[2fr_1fr]` is more dynamic than equal columns.
- Vary section density. Hero with generous whitespace → dense feature grid → spacious testimonial.
- Background zones: alternate surface treatments (tinted sections, subtle texture, full-bleed accent bands) to break visual monotony.
- Whitespace is composition, not emptiness. Intentional whitespace is *consistent and framed*; accidental emptiness is *asymmetric and unfinished*.

**Key CSS patterns:**
```css
.app-shell { display: grid; grid-template-rows: auto 1fr; height: 100dvh; }
.with-sidebar { display: grid; grid-template-columns: 260px 1fr; height: 100dvh; }
.auto-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
```

---

## Components & Interaction

| Rule | Detail |
|------|--------|
| Reuse | Check existing components first. Wrap, don't modify upstream. |
| Primitives | Use accessible primitives (shadcn, Base UI, Radix). NEVER mix systems. NEVER rebuild keyboard/focus behavior. |
| Variants | CVA or equivalent. Never inline ternary chains. `cn()` for class composition. |
| Semantic HTML | `<button>` for actions, `<a>` for navigation. NEVER `<div onClick>`. |
| Icon-only buttons | MUST have `aria-label`. |
| Destructive actions | MUST use `AlertDialog`. |
| Errors | Inline, next to where the action happened. Not in a toast. |
| Empty states | Clear message + CTA + optional illustration. NEVER just "No items." |
| Paste | NEVER block paste in inputs/textareas. |

**Interaction states** — EVERY interactive element MUST have ALL of these:

| State | Implementation |
|-------|---------------|
| Hover | Subtle lift, color shift, or underline |
| Focus | `focus-visible:ring-2 focus-visible:ring-ring` — NEVER remove |
| Active | `active:scale-[0.97]` with 100ms ease-out |
| Disabled | `opacity-50 pointer-events-none cursor-not-allowed` |
| Loading | Disable + "Saving..." text + `aria-busy={isLoading}` |

**Error messages** answer 3 questions: What happened? Why? How to fix it?

---

## Conflict Priority

When requirements conflict, sacrifice in this order (last = drop first):

1. Functional integrity — layout must not break
2. Readability — text legible, hierarchy clear
3. Spatial rhythm — spacing creates grouping
4. Motion polish — transitions and animations
5. Decorative novelty — visual flair

---

## Self-Check (MANDATORY — before finishing any UI work)

Re-read every line you wrote. Verify:

1. **No slop patterns** — Zero items from the anti-slop table
2. **No hardcoded colors** — Every color uses semantic tokens. Zero hex/rgb/hsl in JSX.
3. **No arbitrary values** — No `text-[13px]`, `p-[17px]`, `w-[423px]`
4. **`h-dvh` not `h-screen`**
5. **Interaction states complete** — Every button has hover, focus-visible, active, disabled
6. **Async loading states** — Every form submit disables + shows loading text
7. **Empty/error states** — Every async list has empty state with CTA
8. **No `transition-all`** — Specify exact properties
9. **Labels on all inputs** — Visible `<label>`, not just placeholder
10. **Destructive actions use AlertDialog**

If ANY fail, fix before responding.

---

## Deep References (load when needed)

| Area | File | When to load |
|------|------|-------------|
| Motion & Animation | [reference/motion.md](reference/motion.md) | Building animation-heavy interactions, transitions, gesture-driven UI |
| Data-Dense UI | [reference/data-dense.md](reference/data-dense.md) | Building dashboards, tables, charts, financial data |

For most tasks, the rules above are sufficient. Load references only for specialized depth.
