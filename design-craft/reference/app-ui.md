# App UI rules

Craft rules for app UI: the decisions that move a screen off the median of every Tailwind tutorial. The direction comes first, from DESIGN.md, the brief, or a dealt direction. These rules turn that direction into tokens, type, space, and states. The router ([../SKILL.md](../SKILL.md)) reads this file in its Intake phase (Project Context Scan) and its Build phase (app UI).

**One rule set per surface.**
- **App UI** (tools, dashboards, settings, forms): this file. Where a topic points to a better-* skill or emil-design-eng, use that skill's exact values.
- **Public pages** (landing, marketing, docs home): design-taste-frontend's house rules. They decide shadows at rest, eyebrows, monospace, thin rules, and section backgrounds there, and they win over every rule below.
- **Direction sources win over defaults.** A value named in DESIGN.md or the brief (a pure black ground, a large radius, a serif) overrides the defaults in this file.

---

## Hard Guardrails

| Reflex | Build instead |
|---|---|
| Purple/violet/indigo→pink/fuchsia gradients, gradient text, blurred gradient orbs | One flat committed surface, real media, or a tonal treatment derived from your own scale |
| Decorative glass/glow/blur on static surfaces | Named elevation (tint + shadow); glass only on overlays with a readable fallback |
| Centered hero + identical card grid; 3-4 equal big-number metric cards; colored boxes or icon grids as the hero visual | A content-driven composition: asymmetric anchor + supporting cells, or one prominent metric with context. App: [composition.md](composition.md); public pages: design-taste-frontend |
| Fake proof: "Trusted by 10,000+", logo marquees, "John Doe"/"Acme Corp", round metrics (99.99%), fake terminal/browser/mac-window chrome (traffic-light dots on mockups included) | Real customers, real numbers, the real product surface without a fake window around it — or omit the section entirely |
| Colored left-border stripes on cards, callouts, event/schedule items, alerts | Tinted surface OR a leading dot/chip/time column — one cue. Category color lives in a filled dot or label, not an edge bar (`blockquote` prose quotes exempt) |
| **Stock** stack: shadcn neutral tokens (chroma-0 greys, `--radius` 0.5–0.625rem), verbatim variant strings, Inter or Geist as the only face | Owned tokens: change neutral hue, radius, and type in the token layer before composing pages (Project Context Scan) |
| Dead controls: `href="#"`, empty onClick, toggles that don't persist | Wire the real behavior or remove the control |
| Attention-begging motion: pulse/ping on CTAs or pricing, one fade-in-up on every section | Motion communicates feedback, state, or spatial relationship, bounded to its role — [motion.md](motion.md) |
| Template copy: "Seamlessly", "Effortlessly", "Streamline", "Unlock", "It's not just X, it's Y", "Welcome to our platform", "Built with ❤️", "AI-powered" (non-AI product) | The concrete claim: what the product does, for whom, in specific verbs |

**Intent and repetition.** A context-sensitive treatment (warm neutrals, texture, illustration, large radii, uppercase micro-labels, sparklines, dark sections) passes when it carries state, hierarchy, focus, information, or brand meaning and stays bounded to a named role. One brand kicker is voice; an eyebrow above every section is scaffolding.

**Combination tells** — each forgivable alone, a tell when 2+ appear together: eyebrow kickers on multiple sections, numbered section markers outside a real sequence, radius ≥24px outside a declared soft/playful direction, cards nested in cards, identical icon-heading-line cells, a different background color per section.

---

## Project Context Scan

Tokens are material, not a direction. Find the token layer (`components.json`, Tailwind v4 `@theme` or `tailwind.config`, the global CSS `:root`, DESIGN.md), catalog it, then grade it:

- **Owned** — the values belong to this product: tinted neutrals, a deliberate radius, a chosen face. Reuse them. Derive only the roles that are missing, harmonized with the existing hues.
- **Stock** — the values are library defaults or copied from another app: shadcn's chroma-0 neutrals (`oklch(L 0 0)` or `0 0% L%` on `--foreground`, `--primary`, `--muted-foreground`), `--radius` 0.5rem or 0.625rem, Inter or Geist as the only face. Stock tokens never count as a direction. Change neutral hue, radius, and type through the token layer before composing pages, and keep the component code on semantic tokens.
- **None** — greenfield: derive the palette with the color kernel below.

The design-qa scanner reports a stock token layer as `STOCK_TOKEN`.

**Complete when** the decision line names the grade (owned, stock, or none) and, for stock, the token changes made.

---

## Design Decision Gate

Before writing code, write one decision line in the report covering:

1. **Structural archetype:** app shell (sidebar + content) · focused tool (centered workspace) · dashboard (data-dense grid) · editorial (long-form reading) · marketing page (public: design-taste-frontend).
2. **Visual density:** sparse · balanced · dense.
3. **Aesthetic direction** — a specific adjective pair from the direction source, not "modern" or "clean".
4. **Initial mode from the physical scene** — one sentence: who uses this, where, under what light, in what mood. That sentence picks light or dark. Derive the other mode by remapping semantic tokens.
5. **Typeface** — from the brief's world, with a verified source and license. Stock faces (Inter, Geist, DM Sans, Roboto) need a stated reason.
6. **Token grade and color strategy** — owned, stock, or none (Project Context Scan), plus the strategy from the color kernel.
7. **Composition** — the shell recipe from [composition.md](composition.md).
8. **The unforgettable question:** "If someone saw 10 similar screens today, what would make them remember THIS one?" Name one concrete visual or structural choice.
9. **The swap test + category-reflex check:** if swapping the layout for a template and the font for Inter would go unnoticed, those choices defaulted — remake them. If the palette or aesthetic is guessable from the product category alone (or from category-plus-anti-reference: "fintech but not navy → terminal dark"), rework until neither is obvious.

**Complete when** the decision line answers all nine. "Existing" or "brownfield" does not answer items 3, 8, or 9: the existing tokens are material, and the answer names the direction built from them.

---

## References

Open the file whose topic the work touches:
- palette, gamut, warm neutrals, dark-mode depth → [color.md](color.md)
- font loading, fallback metrics, CJK → [typography.md](typography.md)
- density modes, radius, elevation, the spacing pass → [spacing.md](spacing.md)
- shells, sidebars, gutters, lockups, section header rows, settings → [composition.md](composition.md)
- loading tiers, async lifecycle, empty/error states, validation, destructive actions, optimistic updates → [product-states.md](product-states.md)
- motion library choice, reveals → [motion.md](motion.md)
- charts → [data-dense.md](data-dense.md)

Covered elsewhere, with exact values: typography detail → better-typography · layout mechanics (`dvh`, `min-w-0`, container queries, z-index) → better-layout · copy, errors, empty states → better-writing · press, enter/exit, icons, surfaces → better-ui · animation timing and easing → emil-design-eng · tables, KPIs, dashboards → design-taste-frontend `references/app-screens.md` · public-page heroes and sections → design-taste-frontend.

---

## Type

Five roles: **Display** `clamp(2.5rem, 1.5rem + 4vw, 6rem)` · **Heading** `1.5–2.25rem` · **Body** `1rem` · **Caption** `0.875rem` · **Micro** `0.75rem`. Fewer sizes with more contrast beat many close sizes. A Display ceiling above 6rem needs scale to be the declared feature.

**Tracking** (better-typography values): headings ≥24px `-0.01em` to `-0.02em` · body `0` · uppercase labels ≤14px `+0.05em`. Floor `-0.03em`; `tracking-tighter` fails.

**Font synthesis:** set only the unwanted longhand (`font-synthesis-weight: none`) after checking the fallback stack; leave `font-synthesis: none` off body text.

One family unless the pairing has real contrast (serif + sans, geometric + humanist). Every other type rule: better-typography.

---

## Color Kernel

**Strategy axis** — state it before picking colors: **Restrained** (tinted neutrals + one accent ≤10%, chroma ×0.6) · **Committed** (one saturated color carries 30–60%, ×1.0) · **Full palette** (3-4 named roles, campaigns/data viz, ×1.2) · **Drenched** (the surface IS the color, ×1.4). The multiplier scales every stop's chroma; re-clamp against the gamut caps after scaling. Pick the strategy from the direction; when Restrained is the pick, name what makes it distinctive (the neutral hue, the accent, the type).

**GREENFIELD derivation (token grade "none", in order):**

1. **Hue from the product name:** `H = (first_letter_ordinal × 137 + second_letter_ordinal × 47) mod 360` (a=1…z=26; skip non-letters, and if fewer than two letters exist, reuse the first). Never replace with a category stereotype. If the derived hue cannot meet contrast/gamut after capping, shift ±30° and re-derive. A solid committed surface at the derived hue is always legal — the gradient guardrail bans gradient treatments, not hues.
2. **12-stop lightness spine** at the derived hue: `L = 0.99, 0.96, 0.90, 0.82, 0.71, 0.64, 0.55, 0.49, 0.40, 0.32, 0.27, 0.24` (stops 50…950). Committed-strategy chroma per stop: `C = 0.02, 0.04, 0.06, 0.09, 0.11, 0.13, 0.13, 0.12, 0.10, 0.08, 0.06, 0.05` — scale by the strategy multiplier, then cap C at `0.09` for hues 170–210° and ~`0.18` elsewhere (sRGB safety).
3. **Companion neutral scale** at `H+180°` (≥120° separation), C ≤ 0.02 — the tinted neutrals that replace dead white/gray. Surfaces use stop-50/stop-100.
4. **Map to semantic tokens:** `--background --foreground --card --primary --secondary --muted --accent --destructive --border --ring`. Components use semantic tokens only; opacity modifiers on tokens are allowed (`bg-primary/10`). Token names reveal the product (`--meridian-600`, not `--gray-700`).
5. **Contrast floors (WCAG 2.x):** 4.5:1 normal text, 3:1 large text, 3:1 for required non-text UI (input borders, meaningful icons, focus rings) — measured against the actual rendered background, placeholders and dimmed nav items included. Fix failures by moving L, not C. Every status also has a non-color cue (icon, text, weight).
6. **Dark mode** remaps the semantic layer: re-pick tonal surfaces from the same scale (lighter = closer), reduce chroma ~10–20%, prefer surface tint over shadow. Check each pair against the floors; a mechanical inversion of the light theme is not the method.

One accent at 100/60/20/10% opacity before adding a second. Gamut mapping, P3, warm-neutral branch, ΔL pre-check, dark-mode depth: [color.md](color.md).

---

## Spacing Kernel

4px grid. Ladder: **tight** 4px (within atomic elements) · **item** 8px · **group** 16px · **section** 24–32px (app) · **page** 32–64px.

| Rule | Value |
|---|---|
| Inset vs stack | Inset = padding inside a component; stack = gap between siblings. Set them independently — equal inset+stack everywhere is how "same padding everywhere" happens. |
| Grouping cue | One per region: spacing, border, or elevation. |
| Surfaces | Max 3 visible surface levels (page → section → card). |
| Radius | One base radius, derive the rest; concentric nesting: outer = inner + padding. |
| Height | Comes from content + the ladder, not `min-height` + vertical centering (sole exception: a full-viewport hero where scale is the declared feature). Empty bands between blocks **within one surface**: ≤64px app/data, ≤128px marketing. At section boundaries stacked paddings may total ~192px on marketing pages; >256px is dead air anywhere. Larger = unowned gap: pull the next block up or give the band content. |
| Sizing contract | Declare per element: **Hug** (wraps content), **Fill** (`flex: 1`), or **Fixed** (sidebars, avatars). |
| Grid remainders | No empty cells: remainder 1 → last item spans the row; remainder 2 → both span half. |
| Sidebar | Same hue family as content, 1–2 lightness steps apart. Active state is tonal; content wins the hierarchy. |

Density modes, elevation ladder, the spacing pass: [spacing.md](spacing.md).

---

## Symptom → Correction

| Symptom | Likely cause | Fix |
|---|---|---|
| Decent but generic | Stock tokens, equal-weight cards, uniform padding | Grade the tokens (Project Context Scan); remove a widget, merge a region, flatten one surface |
| Everything competes | Multiple primary-weight elements | One dominant element, mute the rest |
| Cramped | Uniform tight spacing | Increase section gaps, keep group spacing tight |
| Empty despite content | Oversized gaps, thin type | Tighten item spacing, add weight to key elements |
| Floaty content islands | `min-height` + centering, stacked margins, uniform huge section gaps | Height from content; snap every gap to the ladder; remove voids over the Height rule's band limits |
| Ragged two-column section | Heading, controls, and aside start at different y | One section origin: heading row baseline-aligned, both columns start one group unit below it |
| Clips on real content | Fixed heights | `min-h` + `overflow-y-auto` on scroll regions |
| Dark mode washed out | Same chroma as light | Reduce chroma ~10–20%, re-pick surface steps |
| Sidebar fights content | Too bright, equal weight | Dim the shell 1–2 steps; inactive items recede by color, still at the contrast floor |

---

## Conflict Priority

Sacrifice in this order (last = drop first): 1. functional integrity → 2. readability → 3. spatial rhythm → 4. motion polish → 5. decorative novelty.

When the work claims done, run the `design-qa` gates (scanner + live render).
