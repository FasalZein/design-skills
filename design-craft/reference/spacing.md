# Spacing & Surfaces — Density, Rhythm, Radius, Elevation, Safe Areas

Space is the most underused design tool. When an interface feels "off" despite good colors and fonts, the root cause is usually spatial: monotone spacing, weak hierarchy, or mismatched radii. The base ladder and grouping rules live in the SKILL.md spacing kernel; this file owns the depth.

## Working the 4px grid

- The grid is granular: 4, 8, 12, 16, 24, 32, 48, 64, 96. 12px exists — an 8pt-only grid forces wrong choices between 8 and 16.
- Custom properties get semantic names (`--space-xs`…`--space-xl`), not size names (`--spacing-8`).
- Use `gap` for sibling spacing instead of margins — kills margin-collapse hacks.
- `clamp()` for fluid section spacing on marketing pages. App UI keeps fixed values — consistency IS an affordance in product surfaces.
- Containers align to the grid; elements inside them use spacing tokens. When optical correction moves something off-grid (icon centering, cap-height alignment), the correction wins — the grid serves perception, not the reverse.

## Inset vs stack

Two independent decisions per component:

- **Inset** — padding inside a surface. Symmetric by default; text-heavy surfaces read better with horizontal inset ≥ vertical (e.g. `12px 16px`).
- **Stack** — gap between siblings. Owned by the parent (`gap`), never by children's margins.

Equal inset and stack everywhere is how "same padding everywhere" happens. A card grid with `24px` inset wants a visibly different stack (`16px` or `32px`) so the eye can tell containment from adjacency.

## Density modes

Density is a system decision, not per-component taste. Pick one mode per surface — mixing modes inside one view reads as a bug:

| Mode | Control height | Field gap | Use |
|---|---|---|---|
| Compact | 32px | 12–16px | Data tools, admin surfaces, pro users |
| Comfortable (default) | 40px | 16–24px | Product UI |
| Spacious | 48px | 24–32px | Marketing, onboarding, touch-first |

Grouped controls share equal heights — a 40px input beside a 36px button reads as broken. Offer a persisted density toggle only in genuinely data-heavy tools (table density values: [data-dense.md](data-dense.md)).

## Block text rhythm

- Paragraph spacing: `1em` (margin between paragraphs ≈ font size). Never both text-indent and paragraph spacing.
- Headings bind to what follows: space above ≥ 1.5× space below. A heading floating equidistant between sections belongs to neither.
- List items: `0.5em` between items; nested lists indent one `1em` step.
- Label → input: 4–8px. Field → field: 16–24px. Group → group: 32px+.
- Icon + text lockups: center icons to the text's cap height, not the line box — see Optical alignment below.

## Rhythm & hierarchy

- Tight grouping: 8–12px between related siblings. Section separation is surface-scoped and **per side**: 32–48px on app/data surfaces, 48–96px section padding on marketing pages (adjacent paddings stack to ~96–192px of visual air at the boundary — that is the genre's rhythm, not a bug). The kernel band limits cap the total — big air beyond them is a declared feature proven in render, never a default.
- **Where dead air comes from:** `min-height` boxes centering short content, margins stacking on top of padding, and each block adding its own "safe" margin. Blocks own no outer margin — the parent owns all separation via `gap`; a box is as tall as its content plus ladder inset.
- **Squint test:** blur your eyes at the layout — the primary element, the secondary, and the groupings must still be identifiable. If not, hierarchy has failed regardless of colors.
- The strongest hierarchy combines 2–3 dimensions:

| Tool | Strong | Weak |
|------|--------|------|
| Size | ≥3:1 ratio | <2:1 ratio |
| Weight | Bold vs Regular | Medium vs Regular |
| Color | High contrast | Similar tones |
| Position | Top/left (LTR primary) | Bottom/right |
| Space | Surrounded by whitespace | Crowded |

- Density matches content: data-dense UIs tighter, marketing pages more air. Vary spacing between sections — monotonous repetition reads as templated.

## Border radius

- ONE base radius per project; derive all others from it. Defaults: buttons/inputs 4–6px, cards/dialogs 8–16px, badges 4px or `rounded-full` (pills are for tags/badges/avatars — a role, not a look).
- Declared soft-organic or playful directions may take cards to 20–24px and large sheets/hero surfaces to 24–28px. Outside such a declared direction, ≥24px on cards/sections/inputs is the over-rounding tell.
- **Concentric nesting:** `outerRadius = innerRadius + padding`.

```tsx
// Good: outer accounts for padding          // Bad: same radius on both
<div className="rounded-2xl p-2">            <div className="rounded-xl p-2">
  <div className="rounded-lg">…</div>          <div className="rounded-xl">…</div>
</div>                                        </div>
```

- Exception: when the gap between layers exceeds ~24px, treat them as separate surfaces and pick each radius independently — strict concentric math no longer reads.

## Elevation ladder

Name four levels and map every surface to one — depth comes from the pairing of tint and shadow, not from either alone:

| Level | Surface | Shadow |
|---|---|---|
| Sunken | 1 stop darker than page (wells, inset inputs) | none or inset |
| Default | page surface | none |
| Raised | 1 stop lighter (cards, bars) | `--shadow-border` (below) |
| Overlay | lightest (menus, dialogs, popovers) | wider two-layer shadow |

Max three visible levels per view (kernel rule); overlay is transient so it rarely counts against the three.

- Shadows: barely perceptible, multi-layer, single implied light direction across the whole page. Tint shadows toward the background hue instead of generic black.
- **Shadow-as-border** for cards, buttons, and elevated containers — transparency adapts where a solid border color can't:

```css
:root {
  --shadow-border:
    0px 0px 0px 1px oklch(0 0 0 / 0.06),   /* 1px ring   */
    0px 1px 2px -1px oklch(0 0 0 / 0.06),  /* lift       */
    0px 2px 4px 0px oklch(0 0 0 / 0.04);   /* ambient    */
}
/* Dark mode: layered depth is invisible on dark — one white ring */
.dark { --shadow-border: 0 0 0 1px oklch(1 0 0 / 0.08); }
```

Hover: raise each alpha ~0.02 and transition `box-shadow` only (150ms ease-out).

| Use shadows | Keep borders |
|-------------|--------------|
| Cards, containers with depth | Dividers between list items |
| Elevated elements (dropdowns, modals) | Table cell boundaries |
| Elements on varied backgrounds | Form input outlines (accessibility) |
| Hover/focus lift states | Hairline separators in dense UI |

- Never pair a 1px border with a wide soft shadow (≥16px blur) on the same element — the ghost-card tell. One or the other.
- Inset inputs: slightly darker than their surface, not lighter — they are "inset" and receive content.

## Glass & texture

- Backdrop blur is an overlay treatment: sheets, menus, bars over scrolling content — surfaces where showing what's beneath carries meaning. Always pair with a readable fallback (`@supports not (backdrop-filter: blur())` → opaque) and respect `prefers-reduced-transparency`. Glass on static cards is decoration, not information.
- Texture (grain, weave, pattern) is legal as a brand system: one texture, bounded to named roles (hero panel, brand band), subtle enough to survive the squint test. Reflexive full-page grain or animated noise fails the intent-and-repetition lens.

## Optical alignment

Geometric centering often looks wrong; adjust optically — but only when you can see it's off, never speculatively.

- Button with trailing icon: icon-side padding = text-side padding − 2px (`pl-4 pr-3.5`).
- Play triangles: shift ~2px toward the point. Arrows: shift toward their direction.
- Text at `margin-left: 0` looks indented because of letterform whitespace; `-0.05em` negative margin aligns the glyph edge.
- Icon–text rows: center the icon on the text's cap height (roughly `top: 0.1em` adjustment), not the full line box — line-box centering sits icons visibly low next to a single line of text.
- Asymmetric icons (stars, carets): best fixed in the SVG viewBox itself so components need no compensation.

## Hit areas

Target sizes live in the SKILL.md spacing kernel. Extend small visuals with a pseudo-element:

```css
.icon-button { position: relative; width: 24px; height: 24px; }
.icon-button::before { content: ''; position: absolute; inset: -10px; }
```

Collision rule: if the extended area would overlap another interactive element, shrink it to the largest non-overlapping size. Two controls never share hit-area pixels.

## Safe areas

Fixed and sticky elements on mobile must respect device insets:

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

```css
.bottom-bar { padding-bottom: calc(env(safe-area-inset-bottom) + 12px); }
.top-bar    { padding-top: calc(env(safe-area-inset-top) + 8px); }
```

`env()` without `viewport-fit=cover` returns 0 — both halves are required.

## Image outlines

1px inset outline creates consistent depth without affecting layout (token in `:root` — the no-inline-oklch rule applies to outlines too):

```css
:root { --img-outline: oklch(0 0 0 / 0.1); }
.dark  { --img-outline: oklch(1 0 0 / 0.1); }
img { outline: 1px solid var(--img-outline); outline-offset: -1px; }
```

Pure black/white only (`outline-black/10 dark:outline-white/10`) — a tinted neutral (slate/zinc) picks up the surface color and reads as dirt on the image edge. `outline` over `border` so the image keeps its intended size.

## The spacing pass (method)

Run once after building, before QA:

1. Classify every gap on the page as tight / item / group / section / page (kernel ladder).
2. Any gap that fits no class is unowned — snap it to the nearest class.
3. Check inset ≠ stack on repeated surfaces; check grouped controls share heights.
4. Squint test the result: groupings and the primary element must survive the blur.

Complete when every gap names its class and the squint test passes.
