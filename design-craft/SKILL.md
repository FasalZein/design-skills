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
| Dot/line grid as hero background | Lazy technical filler — not a design choice |
| Glow effects as primary affordances | Decorative noise |
| "John Doe", "Jane Doe", "Acme Corp" | Training-data leakage |
| "99.99%", "50%" as metrics | Round/predictable = placeholder |
| "Seamless", "Unleash", "Next-Gen", "Elevate" | AI copywriting clichés |
| ALL CAPS labels/tabs/headings | Shouting hierarchy substitute |
| Title Case everywhere | AI tell — use sentence case |
| Side-stripe borders (border-left/right >1px as colored accent) | Template shortcut — use full borders, background tints, or icons instead |
| Meta-labels ("SECTION 01", "QUESTION 05", "FEATURE 03") | Fake hierarchy — real headings and spacing do this job |
| Filler UI ("Scroll to explore", bouncing chevrons) | Decorative noise with zero utility |
| Emojis in headings or UI markup | Use an icon library, not emoji |
| Domain-reflex coloring (healthcare = teal, crypto = neon on black) | Category alone shouldn't predict your palette |

> "If you showed this to someone and said 'AI made this,' would they believe you immediately? If yes, that's the problem."

---

## Design Decision Gate (MANDATORY — before writing any code)

State these decisions explicitly in your reasoning:

1. **Structural archetype:** app shell (sidebar + content) · marketing page (sections + CTA) · focused tool (centered workspace) · dashboard (data-dense grid) · editorial (long-form reading)
2. **Visual density:** sparse · balanced · dense
3. **Aesthetic direction** — a specific adjective pair matched to the product, not "modern" or "clean" (e.g., "stark technical", "bold expressive", "soft organic", "warm editorial"). NEVER default to the same direction twice in a row.
4. **Typeface** — chosen from the font menu below to match the aesthetic
5. **Color system** — semantic tokens, 60-30-10 rule, one accent max
6. **Hero architecture** — chosen from the hero menu below (if the page has a hero)

7. **The unforgettable question:** "If someone saw 10 similar pages today, what would make them remember THIS one?" Name one concrete visual or structural choice that distinguishes this design.
8. **The swap test:** "If I swapped this layout for a standard template and the font for Inter, would anyone notice?" The places where swapping wouldn't matter are the places that defaulted.

The archetype and density decisions drive everything else. An "app shell / balanced" produces a sidebar, top bar, and filled content area. A "focused tool / sparse" produces a centered workspace with intentional whitespace. A "dashboard / dense" fills the viewport with data.

**Reference loading triggers (MANDATORY):**
- If the page has modals, drawers, transitions, or any interactive motion → **READ [reference/motion.md](reference/motion.md)** before writing code
- If building a dashboard, data table, chart, or financial UI → **READ [reference/data-dense.md](reference/data-dense.md)** before writing code

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
- **Visual richness is mandatory.** Flat white sections with no surface treatment = visual poverty. Every section needs at least ONE of: tinted background, subtle gradient, noise/grain texture, dot/line pattern, or border treatment. CSS noise example: `background-image: url("data:image/svg+xml,...")` or repeating-radial-gradient for dot grids.

**Background treatments by aesthetic direction:**

| Aesthetic | Background options |
|-----------|-------------------|
| **Editorial / warm** | Warm off-white base (`oklch(0.97 0.01 80)`), subtle paper grain via CSS noise, tinted section bands |
| **Technical / stark** | Pure neutral base, faint dot grid (`radial-gradient` repeating pattern), thin rule lines between sections |
| **Friendly / soft** | Soft radial gradient behind hero, pastel-tinted card surfaces, gentle shadow layering |
| **Bold / expressive** | Mesh gradient accent panels, aurora wash on header areas, high-contrast dark sections |
| **Neutral / professional** | Alternating gray-50/white sections, minimal — rely on borders and spacing over color |

---

## Typography

Pick a font based on the product's aesthetic direction. The font must match the product — a fintech dashboard gets Technical/stark, a children's app gets Friendly/soft.

| Aesthetic | Fonts | Character |
|-----------|-------|-----------|
| **Editorial / warm** | Instrument Sans, Source Sans 3, Libre Franklin | Readable, literary feel |
| **Technical / stark** | Geist, JetBrains Sans, IBM Plex Sans | Precise, engineering feel |
| **Friendly / soft** | Plus Jakarta Sans, Nunito Sans, Outfit | Approachable, rounded |
| **Bold / expressive** | Sora, Space Grotesk, Clash Display (display only) | Strong personality |
| **Neutral / professional** | General Sans, Satoshi, Switzer | Clean, versatile |

**Font forcing:** If you catch yourself reaching for DM Sans, Inter, or Roboto — stop. You are defaulting, not designing. Go back to the aesthetic direction and pick a font that matches the product's personality.

| Rule | Implementation |
|------|---------------|
| Type scale | 5 levels: Display, Heading, Body, Caption, Micro. Fewer sizes with more contrast > many close sizes. |
| Numeric data | `tabular-nums` on all numbers — prices, counts, dates, IDs, table columns |
| Headings | `text-balance`. Body: `text-pretty`. Max line length: `max-w-[65ch]` |
| Line height | Body: 1.5. Headings: 1.2–1.3. Large display: 1.0–1.1 |
| Large display text | `tracking-tight` or `tracking-tighter` on text-3xl+. NEVER add positive tracking. |
| Case | Sentence case for headings, labels, tabs, buttons. ALL CAPS only for micro-meta (timestamps, badges ≤3 words). |
| Font loading | `font-display: swap`. Sizes in `rem`/`em`, not `px`. `-webkit-font-smoothing: antialiased` on root. |
| Fluid type | Use `clamp()` for marketing/content pages. Fixed sizes for app UI. |
| Limits | Max 3 font weights per view. One family unless genuine display/body contrast needed. |
| Font weight diversity | NEVER only 400 and 700 across an interface. Use minimum 400/500/600. Two-weight interfaces lack nuance. |
| Monospace as accent | Appropriate for reference numbers, timestamps, transaction IDs, overline labels in technical products. Small `font-mono text-xs` label alongside display font creates productive contrast. |
| NEVER | Monospace for display headings. `tracking-wide`. `user-scalable=no`. Arbitrary sizes (`text-[13px]`). |

```
BAD:  text-[13px], text-[15px], text-[17px]  → too many sizes, too close together
GOOD: text-xs (12), text-sm (14), text-base (16), text-xl (20)  → clear jumps
```

---

## Color

**Color strategy axis** — state before picking any colors:

| Strategy | Usage | Default for |
|----------|-------|-------------|
| **Restrained** | Tinted neutrals + one accent ≤10% of surface | Apps, tools, dashboards |
| **Committed** | One saturated color carries 30-60% of surface | Marketing, brand pages |
| **Full palette** | 3-4 named color roles used deliberately | Brand campaigns, data viz |
| **Drenched** | The surface IS the color | Hero sections, campaign pages |

Don't default everything to Restrained — "restrained by reflex" is the same failure as "Inter by reflex."

**Product accent color** — derive from the product's domain, not from aesthetic direction. A fitness app might use energetic green or electric orange; a writing tool might use deep amber or teal; a monitoring tool might use signal blue or alert red. The accent must feel inevitable for THIS product — if another product in the same category could use the same accent, you haven't differentiated.

Use ONLY semantic color tokens in components. NEVER Tailwind palette with number suffixes (`bg-blue-500`). NEVER hex/rgb/hsl in JSX.

```
REQUIRED tokens: bg-background, text-foreground, bg-card, bg-primary, text-primary,
  bg-secondary, bg-muted, text-muted-foreground, bg-accent, bg-destructive, border-border, ring-ring
Opacity modifiers on semantic tokens ARE allowed: bg-primary/10, border-destructive/30
```

**Universal status colors** (these never change regardless of brand):

| Status | Color | Token | Usage |
|--------|-------|-------|-------|
| Success / positive delta | Green | `--success` | Completed, profit, upward trend, active |
| Error / destructive | Red | `--destructive` | Failed, loss, downward trend, delete |
| Warning / caution | Amber | `--warning` | Pending, at risk, needs attention |
| Info / neutral action | Blue | `--info` | Links, informational, selected, in progress |

These are conventions users already know. NEVER invert them (red for success, green for error). NEVER use brand accent for status — status colors are universal, not branded.

| Rule | Detail |
|------|--------|
| Three layers | Primitives (oklch palette) → Semantic tokens (purpose) → Component tokens. Components reference ONLY semantic. |
| Contrast | ≥ 4.5:1 (WCAG AA). No exceptions. |
| Neutrals | Tint toward brand hue: `oklch(95% 0.01 60)` not `#f5f5f5`. Dead grays have no personality. |
| 60-30-10 | 60% neutrals, 30% secondary, 10% accent. Max 1 primary + 1 secondary accent. |
| OKLCH | Define in CSS tokens only. NEVER inline `bg-[oklch(...)]` in Tailwind classes. Reduce chroma at extreme lightness. |
| Dark mode | Not inverted light mode. No shadows for depth (use lighter surfaces). Desaturate accents slightly. Reduce font weight (350 instead of 400). Never pure black bg. Swap semantic token layer, not component layer. |
| One accent, many opacities | Use one accent at 100%, 60%, 20%, 10% before reaching for a second accent color |
| Tinted shadows | Replace generic rgba(0,0,0,x) with hue-matched shadows tinted toward the background hue |
| Consistent light source | All shadows must suggest a single light direction; mismatched angles = unnoticed flaw |
| Accent saturation | Keep below 80% — slightly desaturated feels premium |
| Token naming | Variable names should reveal the product. `--ink`/`--parchment` for a writing app, `--pulse`/`--iron` for fitness, `--signal`/`--void` for monitoring. `--gray-700` evokes a template. |
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
| Border radius | ONE base radius, derive all others. Buttons/inputs: 4-6px. Cards/dialogs: 8px. Badges: 4px or `rounded-full`. Outer = inner + padding (concentric). NEVER mix arbitrary values. |
| Shadows | Barely perceptible, multi-layer. `shadow-sm` for elevation, `shadow-md` for popovers. NEVER `shadow-lg/xl` on small components. |
| Grouping | Pick ONE method per section: borders OR shadows OR spacing. Never all three. |
| Three-surface limit | NEVER let more than 3 surface levels be visible at once (page bg → section bg → card surface). Each additional level adds cognitive overhead. |
| Image outline | Add 1px outline to all images — `rgba(0,0,0,0.1)` light / `rgba(255,255,255,0.1)` dark. Prevents images from floating. |
| Inset inputs | Inputs should be slightly darker than their surface, not lighter — they are "inset" and receive content. |

```css
/* Good: subtle, multi-layer (Stripe-style) */
box-shadow: 0 1px 1px rgba(0,0,0,0.03), 0 3px 6px rgba(0,0,0,0.02);
/* Bad: heavy, single-layer */
box-shadow: 0 4px 12px rgba(0,0,0,0.15);
```

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
| Cards | Containers, not decoration. NEVER wrap everything in cards. NEVER nest cards inside cards. Card appropriateness test: "Is this content independently actionable or navigable?" If no, use borders, spacing, or background color instead. Form field groups → section dividers, settings → section headings + dividers, activity feeds → list rows with border-bottom, stat metrics → KPI strip (single border with grid, not individual cards). |
| Overflow ban | `overflow: hidden` is BANNED as layout repair — it hides the problem instead of fixing it. Fix the content or container sizing. |
| H1 line limit | H1 MUST NOT exceed 3 lines on desktop. If it does, the container is too narrow — widen with `max-w-5xl` or wider, not shrink the font. |
| Layout budget | For fixed-height regions, calculate `usableHeight = trackHeight - padding - borders - gaps` vs contentHeight. If content > usable, the design is invalid — reduce content, don't hide overflow. |
| Grid completeness | NEVER leave empty grid cells. 5 items in 3-col: span one item across 2 columns. 4 items in 3-col: make one span full width or use 2+2 layout. Every cell must be filled or the grid resized. |
| Touch targets | 44x44px minimum on mobile. |
| Responsive | Prefer 2-tier (mobile + desktop). NEVER hide core functionality on mobile. |
| Square elements | Use `size-*` instead of `w-* h-*` (e.g., `size-10` not `w-10 h-10`). |
| Input method | Detect with `@media (pointer: coarse)` for touch, `@media (hover: none)` for no-hover devices. |

**Structural completeness** — a viewport should feel composed, not assembled with gaps:
- **App shells:** Navigation context (sidebar, top bar, or both) + full-height content area. A form in a void = missing structure.
- **Dashboards:** Fill the grid. Empty grid cells = layout hole. If 5 items in a 3-column layout, span one item across 2 columns. Every dashboard needs visual data — not just numbers in cards. Use sparklines in stat cards for trend, progress rings for goal completion, color-coded category indicators, and at least one chart panel with labeled axes. A dashboard of only text and numbers is a spreadsheet, not a dashboard.
- **Detail pages:** Primary content + supporting context (metadata sidebar, related items, activity feed). A single centered element on a wide screen wastes the viewport.

**Spatial composition:**
- Asymmetry over centering. `grid-cols-[2fr_1fr]` is more dynamic than equal columns.
- Vary section density. Hero with generous whitespace → dense feature grid → spacious testimonial.
- Background zones: alternate surface treatments (tinted sections, subtle texture, full-bleed accent bands) to break visual monotony.
- Whitespace is composition, not emptiness. Intentional whitespace is *consistent and framed*; accidental emptiness is *asymmetric and unfinished*.

**Sidebar visual hierarchy** — sidebars must recede, not compete:
- Text/icons: 40-50% opacity when inactive, full opacity when active/hovered
- Background: 1-2 steps dimmer than content area
- Width: fixed (200-280px), collapsible to icon-only
- Content area ALWAYS wins the visual hierarchy contest

**Key CSS patterns:**
```css
.app-shell { display: grid; grid-template-rows: auto 1fr; height: 100dvh; }
.with-sidebar { display: grid; grid-template-columns: 260px 1fr; height: 100dvh; }
.auto-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
.sticky-aside { position: sticky; top: 1rem; align-self: start; }
.content-aside { display: grid; grid-template-columns: 1fr minmax(240px, 320px); }
```

**Progressive disclosure:**
- Step-by-step flows > 12-field forms shown at once
- Sheets/drawers for contextual detail (preserve parent context)
- Dialogs only for blocking decisions that require confirmation
- ONE primary action per view. Two equal CTAs = hierarchy failure.

---

## Components & Interaction

| Rule | Detail |
|------|--------|
| Reuse | Check existing components first. Wrap, don't modify upstream. |
| Primitives | Use accessible primitives (shadcn, Base UI, Radix). NEVER mix systems. NEVER rebuild keyboard/focus behavior. |
| Variants | CVA or equivalent. Never inline ternary chains. `cn()` for class composition. |
| Semantic HTML | `<button>` for actions, `<a>` for navigation. NEVER `<div onClick>`. |
| Icon-only buttons | MUST have `aria-label`. |
| Destructive actions | MUST use `AlertDialog`. Prefer undo over confirmation dialogs — users click through confirmations mindlessly. |
| Errors | Inline, next to where the action happened. Not in a toast. |
| Empty states | Clear message + CTA + optional illustration. NEVER just "No items." |
| Loading | Use structural skeletons that preview content shape, not generic spinners. |
| Paste | NEVER block paste in inputs/textareas. |

**Interaction states** — EVERY interactive element MUST have ALL of these:

| State | Implementation |
|-------|---------------|
| Hover | Subtle lift, color shift, or underline |
| Focus | `focus-visible:ring-2 focus-visible:ring-ring` — NEVER remove |
| Active | `active:scale-[0.97]` with 100ms ease-out |
| Disabled | `opacity-50 pointer-events-none cursor-not-allowed` |
| Loading | Disable + "Saving..." text + `aria-busy={isLoading}` |

**Button className template** — every button MUST include:
```tsx
className="hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 active:scale-[0.97] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 transition-colors transition-transform duration-150"
```

**Async action template:**
```tsx
<button disabled={isSaving} aria-busy={isSaving}>
  {isSaving ? "Saving..." : "Save changes"}
</button>
```

**Empty states:**
```
BAD:  "No results"
GOOD: "No documents yet. Upload your first document to get started." [Upload Document]
```

**Error messages** answer 3 questions: What happened? Why? How to fix it?
```
BAD:  "Error occurred"
GOOD: "Couldn't save your changes. Check your internet connection and try again." [Retry]
```

---

## UX Writing

| Rule | Detail |
|------|--------|
| Button labels | Specific verb + object: "Save changes" not "OK". "Delete 5 items" not "Yes". |
| Terminology | Pick one term, use everywhere: Delete/Remove/Trash → pick one. Settings/Preferences → pick one. |
| Voice | Active: "Save changes" not "Changes will be saved". |
| Brevity | Cut every sentence in half, then do it again. |
| i18n | Add 30-40% space budget — German text is 30% longer than English. |
| Errors | Never use humor. Never use technical jargon (500, ECONNREFUSED, undefined). |
| NEVER | Repeat information. Redundant headers. Intros that restate the heading. |

---

## Symptom-to-Correction Table

When output looks "almost good but not quite," use this diagnostic:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Looks decent but generic | Equal-weight cards, uniform padding/radius | Remove a widget, merge a region, flatten one surface layer |
| Everything competes for attention | Multiple primary buttons, similar visual weight | Pick ONE dominant element, mute everything else |
| Feels cramped | Uniform tight spacing, no breathing room | Increase gap between sections (keep tight within groups) |
| Feels empty despite content | Too much whitespace between items, thin typography | Tighten item spacing, increase font weight on key elements |
| Layout clips on real content | Fixed heights without overflow | Use min-h instead of h, add overflow-y-auto on scrollable regions |
| Dark mode looks washed out | Same chroma/weight as light mode | Desaturate accents slightly, reduce font weight (350 → 400) |
| Numbers feel jumpy on update | Missing tabular-nums | Add `font-variant-numeric: tabular-nums` to all numeric displays |
| Sidebar fights content area | Sidebar too bright, same visual weight | Dim sidebar bg 1-2 steps, reduce inactive icon/text to 40-50% opacity |

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
11. **UX writing** — Verb+object button labels, sentence case, no jargon
12. **The swap test** — Could you swap the font for Inter and the layout for centered-heading+3-card-grid without anyone noticing? If yes, you defaulted — go back and make real choices.
13. **No side-stripe borders** — Zero `border-left`/`border-right` >1px used as colored accents
14. **Three-surface limit** — Count visible surface levels. Max 3.

If ANY fail, fix before responding.

---

## Deep References

See **Design Decision Gate** above for mandatory loading triggers.

| Area | File |
|------|------|
| Motion & Animation | [reference/motion.md](reference/motion.md) — animation library selection, frequency gate, duration ladder, easing, springs, performance |
| Data-Dense UI | [reference/data-dense.md](reference/data-dense.md) — dashboard composition, table patterns, chart selection, data visualization |
