# Layout

## Rules

- MUST use CSS Grid or Flexbox. NEVER absolute positioning for structural layout.
- MUST use `h-dvh` — NEVER `h-screen` (iOS Safari viewport issues).
- MUST use `min-w-0` on flex/grid children to prevent text overflow.
- MUST use `z-index` from a fixed semantic scale — NEVER arbitrary `z-[999]`.
- MUST respect `safe-area-inset` for fixed elements on mobile.
- SHOULD use container queries (`@container`) for component-level responsiveness.
- SHOULD left-align content with asymmetric layouts — centering everything feels undesigned.
- SHOULD use `size-*` for square elements instead of `w-* h-*` (e.g., `size-10` not `w-10 h-10`).
- SHOULD detect input method with `@media (pointer: coarse)` for touch targets and `@media (hover: none)` to avoid hover-dependent interactions on touch.
- NEVER wrap everything in cards. Use spacing and alignment for grouping. Cards are containers, not decoration.
- NEVER nest cards inside cards. Flatten hierarchy with borders, spacing, and typography.

## Structural Completeness

A viewport should feel *composed*, not assembled from parts with gaps between them.

- **App shells:** Every app view needs navigation context (sidebar, top bar, or both) and a content area that accounts for the full viewport height. A form floating in a void = missing structure.
- **Dashboards:** Fill the grid. If a 2x3 grid has only 4 cards, either reduce to 2x2 or add meaningful content. Empty grid cells = layout hole.
- **Detail pages:** Pair the primary content with supporting context (metadata sidebar, related items, activity feed). A single centered element on a wide screen wastes the viewport.
- **Whitespace is composition, not emptiness.** Large margins around a focal element are intentional. A gap where content should be is not. The difference: intentional whitespace is *consistent* and *framed*; accidental emptiness is *asymmetric* and *unfinished*.

## Spatial Composition

Layouts should have visual energy, not just be stacked boxes.

- **Asymmetry over centering.** A 7/5 or 8/4 split is more dynamic than 6/6. Use `grid-cols-[2fr_1fr]` or `grid-cols-[1fr_2fr]` instead of equal columns.
- **Vary section density.** Alternate between spacious sections and tighter clusters. A hero with generous whitespace followed by a dense feature grid creates rhythm.
- **Overlap and layering.** Use negative margins (`-mt-8`, `-ml-4`) or `translate` to overlap elements intentionally. A card breaking out of its section creates depth.
- **Background zones.** Break visual monotony with alternating background treatments — a tinted section, a full-bleed accent band, a subtle texture. Not every section should live on the same flat surface.

## Grid and Flex Tricks

Practical patterns to eliminate layout holes and create professional structures:

```css
/* Fill remaining viewport height (no gaps at bottom) */
.app-shell { display: grid; grid-template-rows: auto 1fr; height: 100dvh; }

/* Sidebar + content that fills the viewport */
.with-sidebar { display: grid; grid-template-columns: 260px 1fr; height: 100dvh; }

/* Auto-fill grid that adapts without breakpoints */
.auto-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }

/* Sticky sidebar that scrolls independently */
.sticky-aside { position: sticky; top: 1rem; align-self: start; }

/* Content + aside with the aside never shrinking */
.content-aside { display: grid; grid-template-columns: 1fr minmax(240px, 320px); }
```

**Flex patterns:**
- `flex-1 min-w-0` — fill remaining space without overflow. Use on EVERY flex child that contains text.
- `flex-shrink-0` — prevent icons, avatars, and fixed-width elements from collapsing.
- `gap-*` over `space-y-*` — gap works on both axes and doesn't break with conditionally rendered children.
- `flex-wrap` with `min-w-[280px]` children — responsive grid without media queries.

**Preventing common layout holes:**
- Use `grid-template-rows: auto 1fr auto` for header/content/footer — content stretches to fill.
- Use `min-h-0` on grid/flex children inside scrollable containers — prevents overflow.
- Use `place-content-center` on grid for true centering (simpler than flex centering).
- Use `@container` queries on card components for density that adapts to available space, not viewport width.

## Sidebar Visual Hierarchy

Sidebars must recede, not compete with content:
- Sidebar text/icons: 40-50% opacity when inactive, full opacity when active/hovered
- Sidebar background: 1-2 steps dimmer than content area
- Sidebar width: fixed (200-280px), collapsible to icon-only
- Active item: subtle background highlight, no loud accent colors
- Content area must ALWAYS win the visual hierarchy contest

## Progressive Disclosure

- Step-by-step flows > 12-field forms shown at once
- Sheets/drawers for contextual detail (preserve parent context)
- Dialogs only for blocking decisions that require confirmation
- Expand/collapse for optional detail
- ONE primary action per view. Two equal CTAs = hierarchy failure.

## Responsive Design

- MUST ensure 44x44px minimum touch targets on mobile.
- MUST use logical CSS properties (`margin-inline-start` not `margin-left`) for RTL support.
- MUST test with extreme inputs: 100+ char names, emoji, RTL text, empty data, 1000+ items.
- SHOULD use a simplified 2-tier approach (mobile + desktop) over 4+ breakpoints.
- SHOULD adapt navigation for context: sidebar on desktop, bottom sheet on mobile.
- NEVER hide core functionality on mobile. Adapt, don't amputate.
- NEVER use fixed widths on text containers. Use `px-*` padding + flexible content.
