---
name: design-craft
description: Anti-slop UI craft rules that break out of the AI-generated median. Use when building or restyling any UI — pages, components, dashboards, forms, landing pages — when existing UI looks generic or machine-made, or when another skill needs rules for typography, color, spacing, layout, composition, motion, product states, or interaction.
disable-model-invocation: true
---

# Design Craft

Constraints + Consistency + Restraint = Quality. LLMs converge on the statistical median of every Tailwind tutorial and template — generic, safe, forgettable. This skill provides the decisions a strong designer would make, pre-made: executable kernels for type, color, spacing, and interaction, plus branch recipes for everything else.

---

## Hard Guardrails

| Reflex | Build instead |
|---|---|
| Purple/violet/indigo→pink/fuchsia gradients, gradient text, blurred gradient orbs | One flat committed surface, real media, or a tonal treatment derived from your own scale |
| Decorative glass/glow/blur on static surfaces | Named elevation (tint + shadow); glass only on overlays with a readable fallback |
| Centered hero + identical card grid; 3-4 equal big-number metric cards | A content-driven composition: asymmetric anchor + supporting cells, or one prominent metric with context — [reference/composition.md](reference/composition.md) |
| Fake proof: "Trusted by 10,000+", logo marquees, "John Doe"/"Acme Corp", round metrics (99.99%), fake terminal/browser/mac-window chrome (traffic-light dots on mockups included) | Real customers, real numbers, the real product surface without a fake window around it — or omit the section entirely |
| Colored left-border stripes on cards, callouts, event/schedule items, alerts | Tinted surface OR a leading dot/chip/time column — one cue, never stripe + tint. Category color lives in a filled dot or label, not an edge bar (`blockquote` prose quotes exempt) |
| Unmodified component-library defaults (verbatim shadcn variant strings, default radii/tokens, Inter-by-reflex) | Customize tokens, radius, and type to this product before composing pages |
| Dead controls: `href="#"`, empty onClick, toggles that don't persist | Wire the real behavior or remove the control — a dead affordance is a broken promise |
| Attention-begging motion: pulse/ping on CTAs or pricing, identical fade-in-up on every section | Motion communicates feedback, state, or spatial relationship, bounded to its role — [reference/motion.md](reference/motion.md) |
| Template copy: "Seamlessly", "Effortlessly", "Streamline", "Unlock", "It's not just X, it's Y", "Welcome to our platform", "Built with ❤️", "AI-powered" (non-AI product) | The concrete claim: what the product does, for whom, in specific verbs |

**The intent-and-repetition lens** — for every context-sensitive treatment (warm neutrals, texture, illustration, large radii, uppercase micro-labels, sparklines, dark sections): the treatment must communicate state, hierarchy, focus, information, or brand meaning, and be bounded to a named role. One brand kicker is voice; an eyebrow above every section is scaffolding. A skeleton pulse is feedback; a pricing pulse is begging. A coherent warm neutral scale is a palette; a `--cream` token by reflex is the median. Token names are never the failure — unbounded repetition without purpose is.

**Combination tells** — individually forgivable, failing in combination (2+ together): eyebrow kickers on multiple sections, numbered section markers outside a real sequence, radius ≥24px outside a declared soft/playful direction, cards nested in cards, icon-heading-line cells repeated identically, different background color per section.

---

## Project Context Scan (MANDATORY — before Design Decision Gate)

Determine **brownfield** (existing design system) or **greenfield**:

1. `components.json` → shadcn project, tokens in `globals.css` under `:root`
2. `tailwind.config` → `theme.extend.colors` custom tokens
3. `globals.css` / `app/globals.css` → CSS custom properties (`--primary`, `--background`, …)
4. `package.json` → UI libraries: shadcn, Radix, Panda CSS, vanilla-extract

**ANY found → BROWNFIELD:** catalog existing tokens and use them. Skip color derivation. Derive only genuinely missing roles, harmonized with existing hues.
**None → GREENFIELD:** run the full Design Decision Gate including color derivation.

---

## Design Decision Gate (MANDATORY — before writing any code)

State these decisions explicitly in your reasoning:

1. **Structural archetype:** app shell (sidebar + content) · marketing page (sections + CTA) · focused tool (centered workspace) · dashboard (data-dense grid) · editorial (long-form reading)
2. **Visual density:** sparse · balanced · dense
3. **Aesthetic direction** — a specific adjective pair matched to the product, not "modern" or "clean": stark technical, bold expressive, soft organic, restrained editorial, luxury refined, playful toy-like, retro-futuristic, industrial utilitarian.
4. **Initial mode from the physical scene** — write one sentence: who uses this, where, under what light, in what mood. That sentence picks light or dark. Design the chosen mode first; derive the other via semantic token remapping, never as a separate design.
5. **Typeface** — from the font menu below, matched to the aesthetic (availability rule in the type kernel).
6. **Color strategy** — BROWNFIELD: list existing tokens. GREENFIELD: run the color kernel below.
7. **Composition** — hero architecture from the menu below (marketing) or shell recipe from [reference/composition.md](reference/composition.md) (apps, dashboards, settings, detail pages).
8. **The unforgettable question:** "If someone saw 10 similar pages today, what would make them remember THIS one?" Name one concrete visual or structural choice.
9. **The swap test + category-reflex check:** If swapping the layout for a template and the font for Inter would go unnoticed, those choices defaulted — remake them. If the palette or aesthetic is guessable from the product category alone (or from category-plus-anti-reference: "fintech but not navy → terminal dark"), that's the training-data reflex one tier deep; rework until neither is obvious.

The archetype and density decisions drive everything else. **The delight-impact curve:** rare moments (onboarding complete, first success) earn more delight than daily actions. Polish is uniform — settings, empty states, and errors get the same care as the hero.

**Reference loading triggers (MANDATORY):**
- Palette, contrast, or dark-mode depth → **READ [reference/color.md](reference/color.md)**
- Font loading, fallbacks, variable fonts, long-form text, CJK/multi-script → **READ [reference/typography.md](reference/typography.md)**
- Radius/elevation systems, density modes, block rhythm, safe areas, optical alignment → **READ [reference/spacing.md](reference/spacing.md)**
- App shells, sidebars, gutters, metadata/date lockups, settings, features, pricing, proof, footers → **READ [reference/composition.md](reference/composition.md)**
- Async data, forms, validation, empty/error/loading, destructive actions, optimistic updates → **READ [reference/product-states.md](reference/product-states.md)**
- Modals, drawers, transitions, gestures, any interactive motion → **READ [reference/motion.md](reference/motion.md)**
- Dashboards, tables, charts, KPIs, financial UI → **READ [reference/data-dense.md](reference/data-dense.md)**
- Icons, images, illustration, emoji → **READ [reference/visual-assets.md](reference/visual-assets.md)**

---

## Hero Menu (marketing pages)

| Architecture | Layout | Use when |
|---|---|---|
| **Splitscreen** | 55/45 or 60/40 text + media, asymmetric | Product with strong visuals |
| **Editorial** | Oversized display heading, minimal supporting text, no image | Brand/statement pages |
| **Full-bleed media** | Viewport-height image/video with text overlay | Visual-first brands, portfolios |
| **Asymmetric mosaic** | Unequal grid cells with mixed media + text | Creative agencies, portfolios |
| **Anchored metric** | One hero stat with context paragraph | SaaS, data products |

Hero rules: spacing min `py-24 md:py-32`; headline sizes from the type kernel with a `clamp()` ceiling of 6rem — a larger ceiling is allowed only when visual scale IS the feature and the live render proves it survives every breakpoint. Subtext max 2 sentences, `max-w-[50ch]`. One CTA; secondary action is a text link. Real imagery with alt text, or bold typography as the visual — never colored boxes or icon grids. Heading copy must survive every breakpoint.

---

## Type Kernel

Five roles with default sizes — adjust deliberately per aesthetic, never by reflex: **Display** `clamp(2.5rem, 1.5rem + 4vw, 6rem)` (hero statements) · **Heading** `1.5–2.25rem` (section/page titles) · **Body** `1rem` (reading text) · **Caption** `0.875rem` (supporting meta) · **Micro** `0.75rem` (labels, badges). Fewer sizes with more contrast beat many close sizes — app UI rarely needs more than these five plus one intermediate heading step.

| Rule | Value |
|---|---|
| Tracking | ≥48px: `-0.02em` · 30–47px: `-0.01em` · <30px: `0` · uppercase micro-labels only: `+0.05em`. After rendering, adjust at most `±0.005em` for the chosen face. Hard floor `-0.03em`; `tracking-tighter` fails. |
| Line height | Display `1.0–1.1` · Heading `1.2–1.3` · Body `1.5–1.6` · short UI labels `1.0–1.2`. Unitless. |
| Case | Sentence case for headings, labels, tabs, buttons. ALL CAPS only for micro-meta ≤3 words. |
| Numerals | `tabular-nums` + lining figures on all data — prices, counts, dates, IDs, table columns. Right-align numeric columns. |
| Wrapping | Headings `text-balance`, body `text-pretty`, measure `max-w-[65ch]`. |
| Weights | Max 3 per view; minimum range 400/500/600 — two-weight interfaces lack nuance. |
| Mobile inputs | ≥16px or iOS zooms. Never `user-scalable=no`. |
| Availability | Verify the font's source/license/package before selecting. System font stacks are valid for brownfield and performance-first UI. |

**Font menu by aesthetic** (open menu — any verified font that matches the direction qualifies):

| Aesthetic | Examples |
|---|---|
| Editorial | Instrument Sans, Source Sans 3, Libre Franklin |
| Technical / stark | Geist, IBM Plex Sans, Commit Mono (accents) |
| Friendly / soft | Plus Jakarta Sans, Nunito Sans, Outfit |
| Bold / expressive | Sora, Space Grotesk, Clash Display (display only) |
| Neutral / professional | General Sans, Satoshi, Switzer |

Reaching for Inter/Roboto/DM Sans "just to pick something" is defaulting — return to the aesthetic direction. One family unless genuine display/body contrast (serif+sans, geometric+humanist). Monospace as small accent (`font-mono text-xs` on IDs, timestamps) creates productive contrast in technical products; monospace display headings do not.

Loading strategy, fallback metrics, variable fonts, CJK: [reference/typography.md](reference/typography.md).

---

## Color Kernel

**Strategy axis** — state before picking colors: **Restrained** (tinted neutrals + one accent ≤10%, default for tools/dashboards, chroma ×0.6) · **Committed** (one saturated color carries 30–60%, marketing, ×1.0) · **Full palette** (3-4 named roles, campaigns/data viz, ×1.2) · **Drenched** (the surface IS the color, heroes, ×1.4). The multiplier scales every stop's chroma; re-clamp against the gamut caps after scaling. "Restrained by reflex" is the same failure as "Inter by reflex."

**GREENFIELD derivation (executable, in order):**

1. **Hue from the product name:** `H = (first_letter_ordinal × 137 + second_letter_ordinal × 47) mod 360` (a=1…z=26; skip non-letters, and if fewer than two letters exist, reuse the first). Never replace with a category stereotype. If the derived hue cannot meet contrast/gamut after capping, shift ±30° and re-derive. A solid committed surface at the derived hue is always legal — the gradient guardrail bans gradient treatments, not hues.
2. **12-stop lightness spine** at the derived hue: `L = 0.99, 0.96, 0.90, 0.82, 0.71, 0.64, 0.55, 0.49, 0.40, 0.32, 0.27, 0.24` (stops 50…950). Committed-strategy chroma per stop: `C = 0.02, 0.04, 0.06, 0.09, 0.11, 0.13, 0.13, 0.12, 0.10, 0.08, 0.06, 0.05` — scale by the strategy multiplier, then cap C at `0.09` for hues 170–210° and ~`0.18` elsewhere (sRGB safety).
3. **Companion neutral scale** at `H+180°` (≥120° separation), C ≤ 0.02 — the tinted neutrals that replace dead white/gray. Never `#fff`/`#000` as surfaces; use stop-50/stop-100.
4. **Map to semantic tokens:** `--background --foreground --card --primary --secondary --muted --accent --destructive --border --ring`. Components use ONLY semantic tokens — never `bg-blue-500`, never inline hex/rgb/oklch in markup. Opacity modifiers on tokens are allowed (`bg-primary/10`).
5. **Contrast floors (WCAG 2.x conformance):** 4.5:1 normal text, 3:1 large text, 3:1 for required non-text UI (borders of inputs, icons carrying meaning, focus rings) — measured against the actual rendered background, placeholders included. Fix failures by moving L, not C. Every status conveys through a non-color cue too (icon, text, weight).
6. **Dark mode is a remap:** invert the semantic lightness mapping onto tonal surfaces (lighter = closer), reduce chroma ~10–20%, prefer surface tint over shadow, weight 350 only when the loaded font provides it. Swap the semantic layer, not components.

**Universal status colors** — success=green, error/destructive=red, warning=amber, info=blue. Users already know these; never invert, never use brand accent for status.

60-30-10: 60% neutrals, 30% secondary, 10% accent; one accent at 100/60/20/10% opacity before adding a second. All section backgrounds come from the same neutral scale, and a landing page is one continuous canvas: at most one emphasis panel + the footer change surface, no full-width rules between sections — variety comes from density, typography, and rhythm. Token names reveal the product (`--meridian-600`, not `--gray-700`).

Gamut mapping, P3, warm-neutral branch, APCA (supplementary only), dark-mode depth: [reference/color.md](reference/color.md).

---

## Spacing Kernel

4px grid — all spacing in multiples of 4.

```
tight: 4px   — within atomic elements
item:  8px   — between items in a group
group: 16px  — between related groups
section: 24–32px — between major sections
page: 32–64px — page-level margins
```

| Rule | Value |
|---|---|
| Inset vs stack | Inset = padding inside a component; stack = gap between siblings. Set them independently — equal inset+stack everywhere is how "same padding everywhere" happens. |
| Rhythm | Tight within groups, larger between groups, varied section density. |
| Grouping cue | Pick ONE per region: spacing, border, or elevation — never all three. |
| Surfaces | Max 3 visible surface levels (page → section → card). |
| Radius | One base radius, derive the rest; concentric nesting: outer = inner + padding. Scale values and aesthetic exceptions: [reference/spacing.md](reference/spacing.md). |
| Targets | Mobile web ≥44×44 CSS px (WCAG AA floor is 24px; Android-native prefers 48dp). Extend with pseudo-elements when the visible element is smaller. Adjacent hit areas never overlap. |
| Tokens | Framework scale only — never `p-[13px]`, `gap-[7px]`. Acceptable arbitrary: `max-w-[65ch]`, `min-h-[*rem]`, grid templates. |
| Height | Comes from content + the ladder, never from `min-height` + vertical centering (sole exception: a full-viewport hero where scale is the declared feature). Empty bands between blocks **within one surface**: ≤64px app/data, ≤128px marketing. At section boundaries stacked paddings may total ~192px on marketing pages; >256px is dead air anywhere. Larger = unowned gap: pull the next block up or give the band content. |

Density modes, block text rhythm, elevation ladder, shadows, safe areas, optical alignment: [reference/spacing.md](reference/spacing.md). Shell geometry, gutters, lockups: [reference/composition.md](reference/composition.md).

---

## Layout Mechanics

| Rule | Detail |
|---|---|
| Structure | Flexbox for 1D, Grid for 2D. Never absolute positioning for structural layout. |
| Viewport | `h-dvh`, never `h-screen` (iOS Safari). |
| Overflow | `min-w-0` on flex/grid children with text. `overflow: hidden` is banned as layout repair — fix the content or the container. |
| Z-index | Fixed semantic scale (dropdown → sticky → backdrop → modal → toast → tooltip), never `z-[999]`. |
| Overlays | Dropdowns/tooltips inside `overflow: hidden/auto` ancestors get clipped — use the Popover API, `position: fixed`, or a portal. |
| Sizing contract | Declare per element: **Hug** (wraps content), **Fill** (`flex: 1`), or **Fixed** (sidebars, avatars). |
| Grids | No empty cells: remainder 1 → last item spans the row; remainder 2 → both span half. `auto-fill` + `minmax(280px, 1fr)` for variable counts. |
| Semantic HTML | `<button>` for actions, `<a>` for navigation — never `<div onClick>`. Icon-only controls get `aria-label`. |
| Responsive | 2-tier default (mobile + desktop). `@container` queries when the same component serves different-width regions. Never hide core functionality on mobile. Test extremes: 100+ char strings, emoji, RTL, empty, 1000+ items. |
| Asymmetry | `grid-cols-[2fr_1fr]` beats equal columns; vary section density; whitespace is composition — consistent and framed, not accidental. |

**Structural completeness:** an app shell has navigation context + full-height content (a form in a void is missing structure); a dashboard fills its grid; a detail page pairs primary content with supporting context. Complete recipes: [reference/composition.md](reference/composition.md).

**Sidebar:** same hue family as content, 1–2 lightness steps apart — no chroma cliff between shell and content. Inactive items recede (reduced opacity), active state is tonal (no side-stripe). Content always wins the hierarchy contest. Full anatomy: [reference/composition.md](reference/composition.md).

---

## Interaction & Completeness Kernel

Every interactive element has all applicable states: **default, hover** (gated `@media (hover: hover)`), **focus-visible** (visible ring — never removed), **active** (pressed feedback), **disabled**. Every async action runs the lifecycle **idle → pending → success/error**: pending disables re-activation and shows status (`aria-busy`), success/error is visible where the action happened.

| Rule | Detail |
|---|---|
| Async data surfaces | Design all four: loading, populated, empty, error — before shipping any of them. Recipes: [reference/product-states.md](reference/product-states.md). |
| Empty states | Fact + context, plus a next action when one truly exists. |
| Errors | Inline, adjacent to the cause: what happened, why, how to fix. No jargon, no humor. |
| Destructive actions | Reversible → immediate + undo window. Irreversible/high-stakes → explicit confirmation naming what and how much. |
| Optimistic UI | Safe reversible actions only; visible rollback on failure — never payments or deletions. |
| Loading | Structural skeletons matching content shape, not generic spinners. |
| Buttons | Label never wraps (`white-space: nowrap`) — shorten the label or widen the button. Verb+object: "Save changes", not "OK". |
| Primitives | Accessible primitives (shadcn/Radix/Base UI) customized to the project; never rebuild keyboard/focus behavior; never mix systems. |
| Formatting | `Intl.NumberFormat`/`Intl.DateTimeFormat`, never string concatenation. Never block paste. |

---

## UX Writing

Specific verb + object on buttons. One term per concept (Delete/Remove → pick one). Active voice. Cut every sentence in half, then again. Budget +30–40% width for i18n. Errors: never humor, never raw jargon (500, ECONNREFUSED). Never restate the heading in an intro.

---

## Symptom → Correction

| Symptom | Likely cause | Fix |
|---|---|---|
| Decent but generic | Equal-weight cards, uniform padding | Remove a widget, merge a region, flatten one surface |
| Everything competes | Multiple primary-weight elements | ONE dominant element, mute the rest |
| Cramped | Uniform tight spacing | Increase section gaps, keep group spacing tight |
| Empty despite content | Oversized gaps, thin type | Tighten item spacing, add weight to key elements |
| Floaty content islands | `min-height` + centering, stacked margins, uniform huge section gaps | Height from content; snap every gap to the ladder; kill voids over the Height rule's band limits |
| Ragged two-column section | Heading, controls, and aside start at different y | One section origin: heading row baseline-aligned, both columns start one group unit below it |
| Clips on real content | Fixed heights | `min-h` + `overflow-y-auto` on scroll regions |
| Dark mode washed out | Same chroma/weight as light | Reduce chroma ~10–20%, reduce weight where the font allows |
| Numbers jump on update | Missing tabular-nums | `font-variant-numeric: tabular-nums` |
| Sidebar fights content | Too bright, equal weight | Dim shell 1–2 steps, inactive items to reduced opacity |

---

## Conflict Priority

Sacrifice in this order (last = drop first): 1. functional integrity → 2. readability → 3. spatial rhythm → 4. motion polish → 5. decorative novelty.

---

## Self-Check (MANDATORY — before finishing any UI work)

Re-read every line you wrote. Verify each item; fix failures before responding.

1. **Guardrails** — zero hard-guardrail patterns; combination tells don't stack.
2. **Tokens only** — every color is a semantic token; zero inline hex/rgb/oklch in markup; zero arbitrary spacing/type values.
3. **Type kernel** — tracking table honored, `tracking-tighter` absent, one h1, heading levels don't skip.
4. **States complete** — every interactive element has its five states; every async surface has loading/populated/empty/error; every async action blocks duplicate activation.
5. **Layout mechanics** — `h-dvh`, `min-w-0` where text can overflow, no empty grid cells, no wrapped button labels.
6. **The swap test** — could the font become Inter and the layout a centered template without anyone noticing? If yes, remake those decisions.
7. **References honored** — name which reference files you read this session. If a mandatory trigger fired and its file went unread, read it now and re-verify the affected code.

When the work claims done, run the `design-qa` gates (scanner + live render).
