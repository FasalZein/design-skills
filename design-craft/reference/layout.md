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
