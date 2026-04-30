# Animation & Motion

## Decision Gate — Should This Animate At All?

Before choosing duration or easing, answer this first:

| Trigger Frequency | Decision |
|-------------------|----------|
| 100+/day (keyboard shortcuts, command palette, toggle) | No animation. Ever. |
| Tens of times/day (hover, list nav, tab switch) | Opacity-only or remove entirely |
| Occasional (modals, drawers, toasts) | Standard animation |
| Rare / first-time (onboarding, celebrations) | Full delight |

If the action is triggered more than tens of times per day, skip the rest of this file.

## Duration Scale

```
100-150ms: Instant feedback (button press, toggle, tooltip)
200-300ms: State changes (menu open, hover, accordion)
300-500ms: Layout changes (modal, drawer, panel)
500-800ms: Entrance animations (page load, hero)
```

Open durations MUST be longer than close durations. Asymmetric timing: slow where the user is deciding, fast where the system responds.

| Component | Open | Close |
|-----------|------|-------|
| Dropdown | 250ms | 150ms |
| Modal | 250ms | 150ms |
| Panel/drawer | 400ms | 350ms |
| Tooltip | 125ms | 100ms |
| Toast | 400ms | 200ms |

## Easing Curves (use these, not CSS defaults)

```css
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);    /* Default — smooth, refined */
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);   /* Snappier — dominant curve for most UI */
--ease-out-expo:  cubic-bezier(0.16, 1, 0.3, 1);    /* Confident, decisive */
--ease-drawer:    cubic-bezier(0.32, 0.72, 0, 1);   /* iOS-like drawer feel */
```

Decision tree: entering/exiting → ease-out. On-screen movement → ease-in-out. Hover/color → ease. Marquee/progress → linear. NEVER use built-in CSS `ease-in` for entering elements — it makes UI feel sluggish.

## Spring Animations

For gesture interactions (drag, dismiss, mouse tracking) where the user may interrupt mid-animation, use springs instead of CSS transitions:

```js
// Apple-style (recommended — easier to reason about):
{ type: "spring", duration: 0.5, bounce: 0.2 }

// Standard UI state changes — no bounce:
{ type: "spring", duration: 0.3, bounce: 0 }
```

Bounce range: 0.1–0.3 for gestures/decorative only. bounce: 0 for all standard UI transitions. NEVER bounce on buttons, tabs, menus, or form controls.

## Rules

- MUST animate ONLY `transform` and `opacity`. NEVER animate `width`, `height`, `top`, `left`, `margin`, `padding` — they trigger layout reflow. For height: use `grid-template-rows: 0fr → 1fr`. For layout-like effects on large surfaces: use FLIP.
- MUST keep interaction feedback under 200ms. Under 300ms for standard transitions.
- MUST respect `prefers-reduced-motion` — see Reduced Motion section below.
- MUST use ease-out for entrances, ease-in-out for moving elements.
- MUST set `transform-origin` to trigger location for popovers/tooltips (`var(--radix-popover-content-transform-origin)` or `var(--transform-origin)`). Modals keep center origin.
- MUST enter from `scale(0.95)` or higher with opacity. NEVER `scale(0)` — it looks broken.
- MUST gate hover animations behind `@media (hover: hover) and (pointer: fine)`.
- Exit animations: ~75% of entrance duration. Use ease-in for exits.
- Stagger delays for lists: 30-50ms per item, max 5-8 items staggered.
- Button press feedback: `active:scale-[0.97]` with 100ms ease-out.
- Use CSS transitions for interactive state changes — they can be interrupted mid-animation. Reserve keyframes for staged sequences that run once. Rapidly-triggered elements (toasts, toggles) MUST use CSS transitions, not keyframes.
- NEVER use bounce or elastic easing on standard UI. Acceptable only for gesture physics (drag momentum, decorative mouse tracking).
- NEVER apply `will-change` outside active animation scope. Only for `transform`, `opacity`, `filter` — never `all`.
- NEVER animate decoratively. Every motion must serve a UX purpose.
- NEVER animate `blur()` continuously or on large surfaces. Short one-time blur ≤8px is acceptable for icon swaps and crossfade masking.
- Pause looping animations when element is off-screen (Intersection Observer).
- NEVER use `transition: all` — always specify exact properties.
- NEVER use Framer Motion `x`/`y` shorthand props under load — they run on the main thread. Use `transform: "translateX()"` for GPU compositing.
- NEVER update CSS variables on parent containers to animate children — triggers style recalc on all descendants. Apply `transform` directly on the target element.

## Transition Architecture

**Shared element transitions:** Elements must visually travel between states. When a card expands to a detail view, morph the card — don't unmount/remount. Use `layoutId` (Framer Motion) or View Transitions API.

**Directional consistency:** Navigate forward → content enters from right. Navigate back → content enters from left. Tab switching: slide indicator + content slides in direction of the tab.

**Persistent elements don't re-animate.** If a header/nav stays across route changes, never re-animate it.

**For data-dense/professional apps:** Default to NO animation. Only add purposeful transitions for: (1) state changes that need attention, (2) overlays entering/exiting, (3) loading→loaded transitions.

**Enter/exit pattern:** Stagger semantic chunks with ~100ms delay. Exits softer than enters — small fixed `translateY` instead of full height.

**Icon animations:** Animate with `opacity`, `scale`, and `blur` instead of toggling visibility. Scale from `0.25` to `1`, opacity `0` to `1`, blur `4px` to `0px`.

**Tooltip skip-delay:** First tooltip in a group delays normally. Subsequent adjacent tooltips open instantly with `transition-duration: 0ms` while the user is still hovering in the group.

## Reduced Motion

Prefer selective reduction over nuclear reset. Keep opacity and color transitions that aid comprehension. Remove transform, position, and clip-path animations:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

For crafted design systems, prefer per-component handling that keeps opacity/color transitions:

```jsx
const shouldReduceMotion = useReducedMotion();
const closedX = shouldReduceMotion ? 0 : '-100%';
```

## Rendering Cost Reference

Before choosing an animation technique, know the cost:

- **Composite only (free):** transform, opacity
- **Paint (small/isolated surfaces only):** color, borders, filters (including blur ≤8px)
- **Layout (never animate):** width, height, padding, margin, grid-template-columns

For scroll-driven effects, prefer CSS `animation-timeline: view()` over JS scroll listeners.
