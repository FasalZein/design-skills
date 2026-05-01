# Animation & Motion

## Decision Gate — Should This Animate At All?

Before choosing duration or easing, answer this first:

| Trigger Frequency | Decision |
|-------------------|----------|
| 100+/day (keyboard shortcuts, command palette, toggle) | No animation. Ever. |
| Tens of times/day (hover, list nav, tab switch) | Opacity-only or remove entirely |
| Occasional (modals, drawers, toasts) | Standard animation |
| Rare / first-time (onboarding, celebrations) | Full delight |

Hard rule: keyboard-initiated actions MUST NEVER animate. If the action is triggered more than tens of times per day, skip the rest of this file.

## Animation Library Selection

Pick the simplest tool that handles the job. Never mix libraries for the same concern.

| Need | Use | Why |
|------|-----|-----|
| Hover, focus, toggle, color change | **CSS transitions** | GPU-composited, interruptible, zero JS. Default for all interactive states. |
| Staged sequences (page load, hero entrance) | **CSS @keyframes** | No JS dependency, runs off main thread under load. |
| Enter/exit, layout animation, shared element | **motion/react** (formerly framer-motion) | `AnimatePresence` handles exit; `layoutId` handles shared element morphs. |
| Scroll-driven reveals, parallax | **CSS `animation-timeline: scroll()`** or **IntersectionObserver** | CSS-only where supported; IO as fallback. Never `scrollTop`/`scrollY` listeners. |
| Complex timeline sequences, pinned scroll sections | **GSAP + ScrollTrigger** | When CSS scroll timelines can't express the choreography. Pin, scrub, and sequence. |
| Drag, dismiss, gesture with momentum | **motion/react springs** | Springs maintain velocity on interrupt; CSS transitions restart from zero. |
| Programmatic one-shot (JS-controlled timing) | **Web Animations API (WAAPI)** | JS control + CSS performance. No library needed. |

**Rules:**
- CSS first. Only reach for JS animation when CSS can't express it (exit animations, gesture physics, complex timelines).
- Check `package.json` before importing any animation library. If missing, output the install command before the code.
- NEVER mix motion/react and GSAP in the same component. Pick one per interaction surface.
- For single-file HTML pages without a build system: CSS transitions + keyframes + WAAPI only. No npm dependencies.

## Duration Ladder

| Element | Duration |
|---------|----------|
| Button press feedback | 100–160ms |
| Tooltips, small popovers | 125–200ms |
| Dropdowns, selects | 150–250ms |
| Modals, drawers | 200–500ms |
| Any user-initiated animation | ≤300ms total |

Similar UI elements must use identical timing values — never mix 200ms and 250ms for two dropdowns.

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

| Context | Easing |
|---------|--------|
| Entrances | `ease-out` (arrives fast, settles) |
| Exits | `ease-in` (builds momentum before departure) |
| On-screen moves | `ease-in-out` |
| Hover/color | `ease` |
| Constant motion (progress bar, marquee) | `linear` |

NEVER use `ease-in` for entering elements — it delays initial movement and feels sluggish. Recommended custom curves: `--ease-out: cubic-bezier(0.23, 1, 0.32, 1)`, `--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1)`. NEVER `transition: all` — specify exact properties.

## Spring Animations

For gesture interactions (drag, dismiss, mouse tracking) where the user may interrupt mid-animation, use springs instead of CSS transitions:

```js
// Apple-style (recommended — easier to reason about):
{ type: "spring", duration: 0.5, bounce: 0.2 }

// Standard UI state changes — no bounce:
{ type: "spring", duration: 0.3, bounce: 0 }
```

Bounce range: 0.1–0.3 for gestures/decorative only. bounce: 0 for all standard UI transitions. NEVER bounce on buttons, tabs, menus, or form controls.

Safe default config: stiffness 100, damping 20. Springs maintain velocity when interrupted; CSS transitions restart from zero — this is why springs feel better for gestures and interruptible animations.

## Mechanics

- Never start scale from 0. Use `scale(0.95)` + `opacity: 0` as hidden state.
- Stagger delays: 30–50ms per item max. Stagger is decorative — never block interaction during it.
- Popovers scale from trigger: use `transform-origin` from trigger position. Modals are the exception — always `transform-origin: center`.
- Tooltips: animate first hover normally; subsequent hovers in the same group show instantly (`transition-duration: 0ms`).
- Context menus: exit animation only, no entrance. Users expect instant response at cursor.
- Asymmetric press/release: press is slow and deliberate (~2s linear), release is always snappy (~200ms ease-out).
- `prefers-reduced-motion` means fewer and gentler, NOT zero — keep opacity/color fades, remove positional movement.
- Gate hover effects: `@media (hover: hover) and (pointer: fine)` to avoid sticky hover on touch devices.

## Performance

- Only animate `transform` and `opacity` — they're GPU-composited. Everything else triggers layout/paint.
- Framer Motion shorthand (`x`, `y`, `scale`) is NOT hardware-accelerated — use full `transform` string for GPU compositing.
- Never drive animation from `scrollTop`/`scrollY` — use Scroll Timelines or IntersectionObserver.
- `backdrop-blur` ONLY on fixed/sticky elements — never on scrolling containers.
- `will-change: transform` only when first-frame stutter is observed; remove after. Never `will-change: all`.
- Pause looping animations when off-screen via IntersectionObserver.
- Never animate inherited CSS custom properties — triggers recalc on all children.

## Scroll Entry Pattern

| Property | Value |
|----------|-------|
| Start state | `translateY(12–16px)` + `opacity: 0` (optional `blur(0–4px)`) |
| End state | `translateY(0)` + `opacity: 1` |
| Duration | 600–800ms with expo ease |
| Trigger | IntersectionObserver with `{ once: true, rootMargin: "-100px" }` |

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
