---
name: design-craft
description: Opinionated UI craft rules that break out of the AI-slop median. Use when building or restyling any UI — pages, components, dashboards, forms, landing pages — or when existing UI looks generic, templated, or machine-made. Covers typography, color, spacing, layout, motion, interaction states, and UX writing.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.css", "**/*.scss"]
---

# Design Craft

Constraints + Consistency + Restraint = Quality. LLMs converge on the statistical median of every Tailwind tutorial and Bootstrap template — generic, safe, forgettable. This skill enforces specific, opinionated rules that break out of that median.

---

## Anti-Slop Rules (CRITICAL — read first, check last)

These are the fingerprints of AI-generated UI. Violating even one makes the output look machine-made.

> "If you showed this to someone and said 'AI made this,' would they believe you immediately? If yes, that's the problem."

| AI Slop Pattern | Why It Screams "AI" |
|---|---|
| Purple-to-blue gradient hero | Single most common AI training pattern |
| Gradient text on metrics/headings (`bg-clip-text`) | Decorative without purpose — solid color, emphasis via weight/size |
| Dark mode + glowing accents as default | Avoids actual design decisions |
| Glassmorphism everywhere | Overrepresented in 2021-2023 training data |
| Centered heading + subtitle + button + 3-card grid | The #1 AI layout — appears in 90%+ of template sites |
| Hero metrics: 3-4 identical big-number cards | Generic SaaS template. Instead: inline key-value bar, or ONE prominent metric with context |
| Large rounded icons above headings | Templated, adds no value |
| Inter/Roboto/Arial as default font | No brand consideration |
| Cards inside cards | Visual redundancy — flatten with borders/spacing |
| Sparklines as decoration | Tiny charts conveying nothing |
| Monospace as "technical" aesthetic | Not a design decision (as a small accent it can be — see Typography) |
| Same padding everywhere | No visual rhythm |
| Everything centered | Feels undesigned |
| Every button is primary | No hierarchy |
| Dot/line grid as hero or section background | Lazy technical filler — not a design choice |
| Glow effects as primary affordances | Decorative noise |
| "John Doe", "Jane Doe", "Acme Corp" | Training-data leakage |
| "99.99%", "50%" as metrics | Round/predictable = placeholder |
| "Seamless", "Unleash", "Next-Gen", "Elevate" | AI copywriting clichés |
| ALL CAPS labels/tabs/headings | Shouting hierarchy substitute |
| Title Case everywhere | AI tell — use sentence case |
| Tiny uppercase tracked eyebrow above every section ("ABOUT", "PROCESS") | The saturated 2023 kicker scaffold. One named kicker as a deliberate brand system is voice; an eyebrow on every section is AI grammar |
| Numbered section markers as scaffolding ("01 · About", "SECTION 02") | Fake hierarchy — numbers earn their place only when the section IS a real sequence |
| Side-stripe borders (border-left/right >1px as colored accent) | Template shortcut — use full borders, background tints, or icons instead |
| Ghost-card: `border: 1px solid` + soft wide `box-shadow` (blur ≥16px) on the same element | Pick one: a solid border OR a defined shadow ≤8px blur, never both as decoration |
| Over-rounded surfaces: `border-radius` ≥24px on cards/sections/inputs | Cards top out at 12-16px; full-pill is for tags/buttons only |
| Cream/sand/beige body background by reflex (`--paper`, `--linen`, warm near-white) | The saturated warm-neutral default. "Warmth" is carried by accent + typography + imagery, not body bg |
| Hand-drawn/sketchy SVG illustrations, `feTurbulence` paper grain | Reads amateurish, not whimsical. No real assets → ship no illustration |
| `repeating-linear-gradient` stripe backgrounds | Pure decoration reflex |
| Filler UI ("Scroll to explore", bouncing chevrons) | Decorative noise with zero utility |
| Free-floating step connector lines (`<div>` or absolute-positioned spans) | Always misalign. Use flexbox with `flex-1` spacer divs between step circles: `<div class="step-circle"/>` `<div class="connector" style="flex:1; height:2px; background:border-color"/>` `<div class="step-circle"/>` |
| Emojis in headings or UI markup | Use an icon library, not emoji |
| Domain-reflex coloring (healthcare = teal, crypto = neon on black) | Hue comes from the product-name formula ([reference/color.md](reference/color.md)), never from the category |
| Different background color per section | Breaks site continuity. ALL sections use the same neutral scale. Accent colors go on CTAs and interactive elements, never on section backgrounds |

---

## Project Context Scan (MANDATORY — before Design Decision Gate)

Determine if this is a **brownfield** (existing design system) or **greenfield** (no existing system) project:

1. Check for `components.json` → shadcn project, tokens in `globals.css` under `:root`
2. Check `tailwind.config` for `theme.extend.colors` custom tokens
3. Check `globals.css` / `app/globals.css` for CSS custom properties (`--primary`, `--background`, etc.)
4. Check `package.json` for UI libraries: shadcn, Radix, Panda CSS, vanilla-extract

**If ANY found → BROWNFIELD:** Catalog existing tokens. Use them. Do NOT run the color derivation procedure. Do NOT define new CSS variables for roles already covered. Only derive colors for genuinely missing roles, and harmonize new hues with existing ones.

**If none found → GREENFIELD:** Proceed with full Design Decision Gate including color derivation.

---

## Design Decision Gate (MANDATORY — before writing any code)

State these decisions explicitly in your reasoning:

1. **Structural archetype:** app shell (sidebar + content) · marketing page (sections + CTA) · focused tool (centered workspace) · dashboard (data-dense grid) · editorial (long-form reading)
2. **Visual density:** sparse · balanced · dense
3. **Aesthetic direction** — a specific adjective pair matched to the product, not "modern" or "clean": stark technical, bold expressive, soft organic, restrained editorial, luxury refined, playful toy-like, retro-futuristic, industrial utilitarian. NEVER default to the same direction twice in a row. Design light mode first — dark mode is a semantic token swap, not a separate design. Dark vs. light is never a default: write one sentence of physical scene (who uses this, where, under what light, in what mood) and let it force the answer.
4. **Typeface** — chosen from the font menu below to match the aesthetic
5. **Color system** — BROWNFIELD: list existing tokens and use them. GREENFIELD: run the derivation in [reference/color.md](reference/color.md) — semantic tokens, 60-30-10 rule, one accent max
6. **Hero architecture** — chosen from the hero menu below (if the page has a hero)
7. **The unforgettable question:** "If someone saw 10 similar pages today, what would make them remember THIS one?" Name one concrete visual or structural choice that distinguishes this design.
8. **The swap test:** "If I swapped this layout for a standard template and the font for Inter, would anyone notice?" The places where swapping wouldn't matter are the places that defaulted.
9. **The category-reflex check, at two altitudes:** First-order — if someone could guess the theme + palette from the product category alone, it's the first training-data reflex; rework. Second-order — if they could guess the aesthetic family from category-plus-anti-reference ("fintech that's not navy-and-gold → terminal dark mode"), that's the trap one tier deeper; rework until neither answer is obvious.

The archetype and density decisions drive everything else. An "app shell / balanced" produces a sidebar, top bar, and filled content area. A "focused tool / sparse" produces a centered workspace with intentional whitespace. A "dashboard / dense" fills the viewport with data.

**The delight-impact curve:** less-frequent moments deserve MORE delight. Daily actions get subtle micro-interactions; rare milestones (onboarding complete, first transaction) can be theatrical. And polish is uniform — settings pages, empty states, and error screens get the same care as the hero.

**Reference loading triggers (MANDATORY):**
- GREENFIELD color work, or any palette/contrast/dark-mode task → **READ [reference/color.md](reference/color.md)**
- Choosing/loading fonts, long-form text, truncation, or any typography beyond the core table below → **READ [reference/typography.md](reference/typography.md)**
- Nested rounded surfaces, shadow systems, optical alignment, or spacing rhythm problems → **READ [reference/spacing.md](reference/spacing.md)**
- Modals, drawers, transitions, gestures, or any interactive motion → **READ [reference/motion.md](reference/motion.md)**
- Dashboard, data table, chart, or financial UI → **READ [reference/data-dense.md](reference/data-dense.md)**

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
- Hero spacing: min `py-24 md:py-32`. Headlines: `text-5xl md:text-7xl tracking-tight`, clamp() max ≤ 6rem. Subtext: max 2 sentences, `text-xl text-muted-foreground max-w-[50ch]`.
- Use real imagery — `<img>` with descriptive alt text and `object-cover`, not colored boxes or icon grids. If no image is available, use bold typography as the visual element (oversized display text, typographic contrast, negative space).
- One CTA per hero. Secondary action as text link, not a second button.
- Heading copy must survive every breakpoint — if it overflows on tablet/mobile, reduce the clamp max or rewrite the copy. The viewport is part of the design.
- **Visual richness is mandatory.** Flat white sections with no surface treatment = visual poverty. Use subtle variation from your neutral scale (stop-50 → stop-100 alternating) or border treatments. NEVER dot grids, line grids, or repeating geometric patterns as backgrounds.
- **Section color consistency (CRITICAL):** ALL section backgrounds come from the SAME neutral scale. Visual variety comes from layout density shifts, typography contrast, and whitespace rhythm — not color changes per section.

**Background treatments by aesthetic direction:**

| Aesthetic | Background options |
|-----------|-------------------|
| **Editorial** | Neutral-50 base, alternate neutral-50/neutral-100 between sections, hairline rules between content blocks |
| **Technical / stark** | Neutral-50 base, thin rule lines between sections, subtle border treatments |
| **Friendly / soft** | Soft radial gradient from neutral-50 to neutral-100, gentle shadow layering on cards |
| **Bold / expressive** | One hero section can use a dark (neutral-950) or primary-tinted panel. Rest stays neutral. Max ONE dark section per page. |
| **Neutral / professional** | Alternate neutral-50/neutral-100 sections, rely on borders and spacing over color |

---

## Typography

Pick a font based on the product's aesthetic direction. The font must match the product — a fintech dashboard gets Technical/stark, a children's app gets Friendly/soft.

| Aesthetic | Fonts | Character |
|-----------|-------|-----------|
| **Editorial** | Instrument Sans, Source Sans 3, Libre Franklin | Readable, literary feel |
| **Technical / stark** | Geist, JetBrains Sans, IBM Plex Sans | Precise, engineering feel |
| **Friendly / soft** | Plus Jakarta Sans, Nunito Sans, Outfit | Approachable, rounded |
| **Bold / expressive** | Sora, Space Grotesk, Clash Display (display only) | Strong personality |
| **Neutral / professional** | General Sans, Satoshi, Switzer | Clean, versatile |

**Font forcing:** If you catch yourself reaching for DM Sans, Inter, or Roboto — stop. You are defaulting, not designing. Go back to the aesthetic direction and pick a font that matches the product's personality.

| Rule | Implementation |
|------|---------------|
| Type scale | 5 levels: Display, Heading, Body, Caption, Micro. Fewer sizes with more contrast > many close sizes. |
| Heading levels | From the document outline, sizes descend with level, one `h1` per page — never skip levels |
| Numeric data | `tabular-nums` on all numbers — prices, counts, dates, IDs, table columns |
| Headings | `text-balance`. Body: `text-pretty`. Max line length: `max-w-[65ch]` |
| Line height | Unitless. Body: 1.5. Headings: 1.2–1.3. Large display: 1.0–1.1 |
| Large display text | `tracking-tight` on text-3xl+, floor -0.04em. NEVER add positive tracking except small uppercase labels. |
| Case | Sentence case for headings, labels, tabs, buttons — stored in natural case, styled with `text-transform`. ALL CAPS only for micro-meta (timestamps, badges ≤3 words). |
| Font loading | `.woff2` only. `font-display: swap`. `font-synthesis: none`. Sizes in `rem`/`em`. `antialiased` once on root. |
| Fluid type | Use `clamp()` for marketing/content pages. Fixed sizes for app UI. |
| Limits | Max 3 font weights per view. One family unless genuine display/body contrast (contrast axis: serif+sans, geometric+humanist). |
| Font weight diversity | NEVER only 400 and 700 across an interface. Use minimum 400/500/600. Two-weight interfaces lack nuance. |
| Monospace as accent | Appropriate for reference numbers, timestamps, transaction IDs, overline labels in technical products. Small `font-mono text-xs` label alongside display font creates productive contrast. |
| Mobile inputs | ≥16px (`text-base sm:text-sm`) or iOS zooms. NEVER `user-scalable=no` / `maximum-scale=1`. |
| NEVER | Monospace for display headings. `tracking-wide` on body. Arbitrary sizes (`text-[13px]`). Raw axis tags when a CSS property exists (`font-weight`, `font-variant-numeric`). |

```
BAD:  text-[13px], text-[15px], text-[17px]  → too many sizes, too close together
GOOD: text-xs (12), text-sm (14), text-base (16), text-xl (20)  → clear jumps
```

Depth (font files, variable fonts, wrapping, punctuation, underlines, RTL): [reference/typography.md](reference/typography.md).

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

**Palette derivation:** GREENFIELD palettes come from the OKLCH lightness spine in [reference/color.md](reference/color.md) — deterministic hue from the product name, 12-stop ladder, companion neutral at H+180°, semantic token mapping, gamut safety, APCA contrast. Read it before creating or modifying any palette. BROWNFIELD: use existing tokens.

Use ONLY semantic color tokens in components. NEVER Tailwind palette with number suffixes (`bg-blue-500`). NEVER hex/rgb/hsl/oklch inline in JSX.

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

These are conventions users already know. NEVER invert them. NEVER use brand accent for status — status colors are universal, not branded.

| Rule | Detail |
|------|--------|
| Three layers | Primitives (oklch palette) → Semantic tokens (purpose) → Component tokens. Components reference ONLY semantic. |
| Contrast | ≥ 4.5:1 (WCAG AA) against the element's actual rendered background. No exceptions — including placeholders. Fix by moving L, not C ([reference/color.md](reference/color.md)). |
| Neutrals | Tinted toward the companion hue (H+180° from primary). NEVER `oklch(1 0 0)` or `#ffffff` as card/surface backgrounds — always the tinted stop-50/stop-100. Dead white has no personality. |
| 60-30-10 | 60% neutrals, 30% secondary, 10% accent. Max 1 primary + 1 secondary accent. |
| OKLCH | Define ALL oklch values in `:root` as CSS custom properties. NEVER inline `oklch()` in component rules, box-shadow, outline, or Tailwind classes — always `var(--token)`. |
| Dark mode | Derived, not hand-picked: invert the semantic lightness mapping, desaturate ~20%, lighter surfaces instead of shadows, font weight 350, never pure black. Swap the semantic layer, not components. |
| One accent, many opacities | Use one accent at 100%, 60%, 20%, 10% before reaching for a second accent color |
| Tinted shadows | Replace generic rgba(0,0,0,x) with hue-matched shadows tinted toward the background hue |
| Consistent light source | All shadows suggest a single light direction; mismatched angles = unnoticed flaw |
| Accent saturation | Keep below 80% — slightly desaturated feels premium |
| Token naming | Names should reveal the product's identity. `--gray-700` evokes a template; `--meridian-600` evokes a world. |
| NEVER | `#fff`, `#000` as surface tokens. Gray text on colored backgrounds — use a darker shade of the bg's own hue. Purple-to-blue gradients. |

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
| Border radius | ONE base radius, derive all others. Buttons/inputs: 4-6px. Cards/dialogs: 8-16px max. Badges: 4px or `rounded-full`. Concentric nesting: outer = inner + padding. NEVER ≥24px on cards/sections/inputs. NEVER mix arbitrary values. |
| Shadows | Barely perceptible, multi-layer. `shadow-sm` for elevation, `shadow-md` for popovers. NEVER `shadow-lg/xl` on small components. NEVER 1px border + wide soft shadow on the same element (ghost-card). |
| Grouping | Pick ONE method per section: borders OR shadows OR spacing. Never all three. |
| Three-surface limit | NEVER more than 3 surface levels visible at once (page bg → section bg → card surface). |
| Image outline | 1px outline on all images — pure `rgba(0,0,0,0.1)` light / `rgba(255,255,255,0.1)` dark, never a tinted neutral (reads as dirt on the image edge). |
| Inset inputs | Inputs slightly darker than their surface, not lighter — they are "inset" and receive content. |

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
| Structure | CSS Grid or Flexbox — Flexbox for 1D, Grid for 2D. NEVER absolute positioning for structural layout. |
| Viewport | `h-dvh` — NEVER `h-screen` (iOS Safari). |
| Overflow | `min-w-0` on flex/grid children. `flex-1 min-w-0` on flex children with text. |
| Z-index | Fixed semantic scale (dropdown → sticky → backdrop → modal → toast → tooltip) — NEVER `z-[999]`. |
| Safe area | `safe-area-inset` on fixed elements for mobile. |
| Container queries | `@container` for component-level responsiveness. |
| Cards | Containers, not decoration. NEVER wrap everything in cards. NEVER nest cards. Card test: "Is this content independently actionable or navigable?" If no → borders, spacing, or background. Form field groups → section dividers; settings → headings + dividers; activity feeds → list rows with border-bottom; stat metrics → KPI strip (single border with grid, not individual cards). |
| Overflow ban | `overflow: hidden` is BANNED as layout repair — fix the content or container sizing. |
| H1 line limit | H1 MUST NOT exceed 3 lines on desktop. Widen the container (`max-w-5xl`+), don't shrink the font. |
| Layout budget | For fixed-height regions: `usableHeight = trackHeight - padding - borders - gaps` vs contentHeight. Content > usable = invalid design — reduce content, don't hide overflow. |
| Sizing contract | Before placing any element, declare: **Hug** (wraps content — buttons, badges), **Fill** (expands — content areas, `flex: 1`), or **Fixed** (explicit — sidebars, avatars). |
| Grid completeness | NEVER leave empty grid cells. `items % columns ≠ 0`: remainder 1 → last item spans full row; remainder 2 → last two span half each. `auto-fill` + `minmax(280px, 1fr)` for variable counts. |
| Touch targets | 44×44px minimum on mobile, 40×40px desktop. Extend with a pseudo-element if the visible element is smaller. Hit areas of adjacent controls must never overlap. |
| Responsive | Prefer 2-tier (mobile + desktop). NEVER hide core functionality on mobile. Test extremes: 100+ char strings, emoji, RTL, empty, 1000+ items. |
| Square elements | `size-*` instead of `w-* h-*`. |
| Input method | `@media (pointer: coarse)` for touch, `@media (hover: none)` for no-hover devices. |

**Structural completeness** — a viewport should feel composed, not assembled with gaps:
- **App shells:** Navigation context (sidebar, top bar, or both) + full-height content area. A form in a void = missing structure.
- **Dashboards:** Fill the grid; see [reference/data-dense.md](reference/data-dense.md).
- **Detail pages:** Primary content + supporting context (metadata sidebar, related items, activity feed). A single centered element on a wide screen wastes the viewport.

**Spatial composition:**
- Asymmetry over centering. `grid-cols-[2fr_1fr]` is more dynamic than equal columns.
- Vary section density. Hero with generous whitespace → dense feature grid → spacious testimonial.
- Whitespace is composition, not emptiness. Intentional whitespace is *consistent and framed*; accidental emptiness is *asymmetric and unfinished*.

**Sidebar visual hierarchy** — sidebars must recede, not compete:
- Text/icons: 40-50% opacity when inactive, full opacity when active/hovered
- Background: same hue family as content area, 1-2 lightness steps dimmer. NEVER dark sidebar + light content — the contrast cliff reads as two unrelated apps.
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
| Button text | `white-space: nowrap`. Labels NEVER wrap to two lines — shorten the label or widen the button. |
| Icon-only buttons | MUST have `aria-label`. |
| Destructive actions | MUST use `AlertDialog`. Prefer undo over confirmation dialogs — users click through confirmations mindlessly. |
| Optimistic UI | Low-stakes reversible actions only (toggle, reorder). NEVER payments or deletions. Failed optimistic updates revert state + show error. |
| Errors | Inline, next to where the action happened. Not in a toast. |
| Empty states | Clear message + CTA + optional illustration. NEVER just "No items." |
| Loading | Structural skeletons that preview content shape, not generic spinners. |
| Numbers & dates | `Intl.NumberFormat` / `Intl.DateTimeFormat`, never string concatenation. |
| Dropdown clipping | `position: absolute` inside `overflow: hidden/auto` gets clipped — use popover API, `position: fixed`, or a portal. |
| Paste | NEVER block paste in inputs/textareas. |

**Interaction states** — EVERY interactive element MUST have ALL of these:

| State | Implementation |
|-------|---------------|
| Hover | Subtle lift, color shift, or underline — gated by `@media (hover: hover)` |
| Focus | `focus-visible:ring-2 focus-visible:ring-ring` — NEVER remove |
| Active | `active:scale-[0.97]` with 100ms ease-out (floor 0.95 — below feels exaggerated) |
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
| Dark mode looks washed out | Same chroma/weight as light mode | Desaturate accents slightly, reduce font weight (400 → 350) |
| Body text hard to read | Muted gray on tinted near-white | Bump foreground toward the ink end of the scale — verify contrast against the actual bg |
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

1. **No slop patterns** — Zero items from the anti-slop table (including eyebrows, numbered scaffolding, ghost-cards, over-rounding, cream-by-reflex)
2. **No hardcoded colors** — Every color uses semantic tokens. Zero hex/rgb/hsl/oklch in JSX.
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
15. **Grid completeness** — Zero empty grid cells. If remainder exists, last items span to fill.
16. **Button text** — Zero buttons with text wrapping to two lines.
17. **Monochrome mud** — Primary and neutral scales differ in hue by ≥120°.
18. **Section color consistency** — All section backgrounds use the same neutral scale.
19. **Reference gates honored** — Name which reference files you read this session (color / typography / motion / data-dense). If a mandatory trigger fired (greenfield palette, any animation, font work, dashboard/table) and you didn't read its file, read it now and re-verify the affected code.

If ANY fail, fix before responding.

---

## Deep References

See **Design Decision Gate** above for mandatory loading triggers.

| Area | File |
|------|------|
| Color & Contrast | [reference/color.md](reference/color.md) — OKLCH spine derivation, name→hue formula, companion scales, gamut safety, APCA/WCAG contrast, dark mode |
| Typography Depth | [reference/typography.md](reference/typography.md) — font files, variable fonts, scale mechanics, wrapping, punctuation, underlines, RTL |
| Spacing & Surfaces Depth | [reference/spacing.md](reference/spacing.md) — 4pt scale, rhythm, concentric radius, shadow-as-border recipes, optical alignment, hit areas |
| Motion & Animation | [reference/motion.md](reference/motion.md) — frequency gate, library selection, duration ladder, easing, springs, gestures, performance |
| Data-Dense UI | [reference/data-dense.md](reference/data-dense.md) — dashboard composition, table patterns, chart selection, data visualization |
