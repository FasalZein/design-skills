# Motion — Library Choice and Reveals

Timing, easing, springs, enter/exit, press feedback, tooltips, gestures, and performance: emil-design-eng and better-ui. Use their exact values in app UI: exits use `ease-out` (never `ease-in`), a pressed button scales to `0.96` over `150ms` with `ease-out`. This file keeps what those skills do not carry.

## Animation Library Selection

Pick the simplest tool that handles the job. Use one library per concern.

| Need | Use | Why |
|------|-----|-----|
| Hover, focus, toggle, color change | **CSS transitions** | GPU-composited, interruptible, zero JS. Default for all interactive states. |
| Staged sequences (page load, hero entrance) | **CSS @keyframes** | No JS dependency, runs off main thread under load. |
| Enter/exit, layout animation, shared element | **motion/react** (formerly framer-motion) | `AnimatePresence` handles exit; `layoutId` handles shared element morphs. |
| Scroll-driven reveals, parallax | **CSS `animation-timeline: scroll()`** or **IntersectionObserver** | CSS-only where supported; IO as fallback. Never `scrollTop` or `scrollY` listeners. |
| Complex timeline sequences, pinned scroll sections | **GSAP + ScrollTrigger** | When CSS scroll timelines can't express the choreography. Pin, scrub, and sequence. |
| Drag, dismiss, gesture with momentum | **motion/react springs** | Springs maintain velocity on interrupt; CSS transitions restart from zero. |
| Programmatic one-shot (JS-controlled timing) | **Web Animations API (WAAPI)** | JS control + CSS performance. No library needed. |

**Rules:**
- CSS first. Reach for JS animation when CSS can't express it (exit animations, gesture physics, complex timelines).
- CSS transitions for interactive state changes — they interrupt cleanly mid-animation. Keyframes only for staged sequences that run once. Rapidly-triggered elements (toasts, toggles) use transitions.
- One of motion/react or GSAP per interaction surface.
- Single-file HTML pages without a build system: CSS transitions + keyframes + WAAPI only.

## Reveals

- A reveal enhances an already-visible default. Content visibility stays independent of a class-triggered transition: transitions pause in hidden tabs and headless renderers, so a gated reveal ships a blank section.
- Vary reveals by content. One fade-in-up recipe on every section is the guardrail's attention-begging row.
- Pause toast auto-dismiss timers while the document is hidden; pause looping animations when off-screen (IntersectionObserver).
- Data-dense and professional apps default to no animation beyond state changes that need attention, overlay enter/exit, and loading→loaded.
