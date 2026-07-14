# Spacing & Surfaces — Scale, Rhythm, Radius, Shadows, Hit Areas

Space is the most underused design tool. When an interface feels "off" despite good colors and fonts, the root cause is usually spatial: monotone spacing, weak hierarchy, or mismatched radii.

## Scale

- 4pt base scale: 4, 8, 12, 16, 24, 32, 48, 64, 96px. Prefer it over 8pt — 8pt is too coarse; you constantly need 12px between 8 and 16.
- Every value comes from the scale. Custom properties get semantic names (`--space-xs`…`--space-xl`), not size names (`--spacing-8`).
- Use `gap` for sibling spacing instead of margins — kills margin-collapse hacks.
- `clamp()` for fluid spacing on marketing pages so sections breathe on large screens. App UI keeps fixed values — consistency IS an affordance in product surfaces.

## Rhythm & Hierarchy

- Tight grouping: 8–12px between related siblings. Generous separation: 48–96px between distinct sections. Equal padding everywhere = no rhythm.
- **Squint test:** blur your eyes at the layout — the primary element, the secondary, and the groupings must still be identifiable. If not, hierarchy has failed regardless of colors.
- Space alone can carry hierarchy — generous whitespace around an element draws the eye. The strongest hierarchy combines 2–3 dimensions:

| Tool | Strong | Weak |
|------|--------|------|
| Size | ≥3:1 ratio | <2:1 ratio |
| Weight | Bold vs Regular | Medium vs Regular |
| Color | High contrast | Similar tones |
| Position | Top/left (LTR primary) | Bottom/right |
| Space | Surrounded by whitespace | Crowded |

- Density matches content: data-dense UIs tighter, marketing pages more air. Vary spacing between sections — monotonous repetition reads as templated.

## Border Radius

- ONE base radius per project; derive all others. Buttons/inputs 4–6px, cards/dialogs 8–16px, badges 4px or `rounded-full`. Never ≥24px on cards/sections/inputs.
- **Concentric nesting:** `outerRadius = innerRadius + padding`.

```tsx
// Good: outer accounts for padding          // Bad: same radius on both
<div className="rounded-2xl p-2">            <div className="rounded-xl p-2">
  <div className="rounded-lg">…</div>          <div className="rounded-xl">…</div>
</div>                                        </div>
```

- Exception: when the gap between layers exceeds ~24px, treat them as separate surfaces and pick each radius independently — strict concentric math no longer reads.

## Shadows

- Barely perceptible, multi-layer, single implied light direction across the whole page. Tint shadows toward the background hue instead of generic black.
- **Shadow-as-border** for cards, buttons, and elevated containers — transparency adapts to any background where a solid border color can't:

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

## Optical Alignment

Geometric centering often looks wrong; adjust optically — but only when you can see it's off, never speculatively.

- Button with trailing icon: icon-side padding = text-side padding − 2px (`pl-4 pr-3.5`).
- Play triangles: shift ~2px toward the point. Arrows: shift toward their direction.
- Text at `margin-left: 0` looks indented because of letterform whitespace; `-0.05em` negative margin aligns the glyph edge.
- Asymmetric icons (stars, carets): best fixed in the SVG viewBox itself so components need no compensation.

## Hit Areas

44×44px minimum on touch/mobile, 40×40px on desktop. Extend small visuals with a pseudo-element:

```css
.icon-button { position: relative; width: 24px; height: 24px; }
.icon-button::before { content: ''; position: absolute; inset: -10px; }
```

Collision rule: if the extended area would overlap another interactive element, shrink it to the largest non-overlapping size. Two controls never share hit-area pixels.

## Image Outlines

1px inset outline creates consistent depth without affecting layout:

```css
img { outline: 1px solid oklch(0 0 0 / 0.1); outline-offset: -1px; }
.dark img { outline-color: oklch(1 0 0 / 0.1); }
```

Pure black/white only (`outline-black/10 dark:outline-white/10`) — a tinted neutral (slate/zinc) picks up the surface color and reads as dirt on the image edge. `outline` over `border` so the image keeps its intended size.
