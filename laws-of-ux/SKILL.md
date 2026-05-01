---
name: laws-of-ux
description: User-psychology rules for UX decisions — cognitive load, attention, memory, mental models, motor cost, perception. Use when choosing nav structure, form length, decision flows, content ordering, error recovery, onboarding, progress indicators, or microcopy. Complements design-craft (craft) with the WHY (psychology).
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html"]
---

# Laws of UX

Psychology-driven constraints for interface decisions. Design-craft handles the HOW (tokens, spacing, animation). This skill handles the WHY (how cognition, memory, attention, and motor cost shape what users experience).

---

## 1. Reduce Decision & Memory Cost

Apply when: designing navigation, forms, settings, onboarding, any view with options.

| Law | Rule |
|-----|------|
| **Hick's Law** | Decision time grows with choices. Limit primary nav to 5-7 items. Highlight the recommended choice. Progressive disclosure over walls of options. |
| **Miller's Law** | Working memory holds ~7 (±2) items. Use chunking — group related inputs (address block, payment block) rather than 12 flat fields. |
| **Working Memory** | Support recognition over recall: mark visited links, show breadcrumbs, carry context across screens. Comparison tables instead of "remember from screen 1." |
| **Cognitive Load** | Intrinsic + extraneous = total burden. Minimize extraneous: remove decorative elements that don't serve comprehension, pre-fill known values, show only what the current step needs. DO: for every element on screen, ask "does removing this hurt comprehension?" If no, remove it. |
| **Choice Overload** | Too many options → paralysis. Limit visible choices, offer smart defaults, use filters/search for large catalogs. "Recommended" badges reduce cognitive cost. |
| **Tesler's Law** | Every system has irreducible complexity — push it into the system, not onto the user. DO: auto-detect timezones, infer file types, pre-fill from context, provide smart defaults. If the user has to configure something the system could detect, you failed. |
| **Occam's Razor** | Remove elements until further removal breaks function. DO: after building, delete one element at a time — if the page still works and communicates clearly, leave it deleted. Fewer features done well > many half-done. |

## 2. Build on Familiarity

Apply when: designing navigation, form controls, onboarding, or making major redesigns.

| Law | Rule |
|-----|------|
| **Jakob's Law** | Users expect yours to work like other sites. Logo top-left → home, search top-right, settings behind gear. Don't innovate on navigation — innovate on content. |
| **Mental Model** | Match the user's model, not your data model. A "cart" works because people know physical carts. If users' expectations don't match your structure, adapt to theirs. |
| **Active User Paradox** | Users never read manuals. Make primary actions obvious and discoverable. Inline help (tooltips, empty state CTAs) over instruction walls. Design for the user who skipped every tutorial. |

## 3. Direct Attention & Create Emphasis

Apply when: designing CTAs, notifications, status indicators, visual hierarchy.

| Law | Rule |
|-----|------|
| **Von Restorff Effect** | The distinct item gets remembered. Make ONE CTA visually different. If everything is emphasized, nothing is. Combine size + weight + position, not color alone. |
| **Selective Attention** | Users filter out irrelevant info. DO: use size contrast (2x+ difference between primary and secondary elements), weight contrast, and position (above the fold, left-aligned) to guide the eye. Don't place important content in ad-like positions (banner blindness). Never add more elements to draw attention — subtract competing ones. |
| **Serial Position** | First and last items are remembered best. Primary nav items at start and end. Key toolbar actions at edges, not center. |
| **Aesthetic-Usability** | Beautiful interfaces are perceived as more usable. DO: invest in visual polish (consistent spacing, refined typography, smooth transitions) because it buys forgiveness for minor friction. But never skip usability testing because it "looks good" — the halo effect masks real problems. |

## 4. Shape Experience & Memory

Apply when: designing onboarding, checkout, error recovery, long-running tasks, multi-step journeys.

| Law | Rule |
|-----|------|
| **Peak-End Rule** | People judge by the peak moment and the ending. Invest disproportionately in the best moment + the final step. Negative peaks are recalled more vividly — prioritize eliminating pain over adding delight. |
| **Zeigarnik Effect** | Incomplete tasks are remembered. Use progress indicators: "3 of 5 complete." Checklist dashboards exploit this. Don't abuse (fake urgency = dark pattern). |
| **Goal-Gradient** | Motivation increases near the goal. Show progress visually. Artificial progress ("Already 20% done!") increases completion. |
| **Flow** | Optimal engagement = challenge matches skill + clear feedback + no interruption. Don't interrupt mid-task with modals. Provide immediate feedback for every action. |

## 5. Motor Cost & Timing

Apply when: sizing targets, positioning actions, setting response times, time-sensitive interactions.

| Law | Rule |
|-----|------|
| **Fitts's Law** | Time to reach = f(distance, size). Touch targets ≥ 44×44px. Primary actions near resting position (bottom on mobile). Destructive actions small and far from "Save." |
| **Doherty Threshold** | Response under 400ms keeps flow. Longer → skeleton screens, optimistic UI. Every submit button MUST have loading state: disable + "Processing..." text. |
| **Parkinson's Law** | Tasks expand to fill time. Set expectations: don't give open-ended input for 2-word answers. Autofill + smart defaults reduce completion time. |

## 6. Perception & Grouping (Gestalt)

Apply when: organizing layout, grouping controls, designing visual relationships.

| Law | Rule |
|-----|------|
| **Proximity** | Nearby = related. Tight within groups, generous between. Primary tool for visual org — stronger than borders. |
| **Similarity** | Same style = same function. Consistent styling signals shared purpose. Differentiate actions from static content. |
| **Common Region** | Shared boundary = group. Use backgrounds/borders to create regions. Prefer proximity first — common region is heavy-handed. |
| **Connectedness** | Visual connections (lines, arrows, step connectors) create relationships. Stronger than proximity or similarity. |
| **Prägnanz** | People see the simplest form. DO: align elements to a visible grid, use consistent shapes (all rounded OR all sharp, not mixed), and ensure whitespace creates clean rectangles — not ragged edges. If a layout looks "messy," the shapes aren't resolving to simple forms. |

## 7. Robustness & Prioritization

Apply when: handling user input, planning feature scope, designing error tolerance.

| Law | Rule |
|-----|------|
| **Postel's Law** | Accept varied input ("Jan 5", "1/5", "2026-01-05"). Validate on submit, not per-keystroke. Display consistently. |
| **Pareto (80/20)** | Focus on 20% of features used by 80% of users. Primary flow must be flawless; edge cases adequate. |
| **Cognitive Bias** | Users satisfice, anchor on first numbers, default to pre-selected. Pre-select the best option, frame to reduce regret — but never deceive. |

---

## Decision Matrix

| Decision | Apply |
|---|---|
| How many nav items? | Hick + Miller: ≤7, highlight default |
| Form too long? | Chunking + Tesler: multi-step, push complexity into system |
| Where to place CTA? | Fitts + Serial Position: big target, edge position |
| What to emphasize? | Von Restorff: ONE thing different. Everything bold = nothing bold |
| Multi-step flow stalling? | Goal-Gradient + Zeigarnik: show progress, signal incompleteness |
| Users confused? | Jakob: match convention. Mental Model: match theirs, not yours |
| Slow response? | Doherty: feedback <400ms, skeleton/optimistic for longer |
| Users ignoring key info? | Selective Attention: avoid ad positions. Sequence changes (change blindness) |
| Low post-flow satisfaction? | Peak-End: invest in best moment + final screen |
| Too many options? | Choice Overload + Occam: defaults, filter/search, remove until it breaks |
| Grouping unclear? | Proximity > Similarity > Common Region > Connectedness (subtlety order) |
| Messy user input? | Postel: accept liberally, normalize, display consistently |
| Users forgetting prior screen? | Working Memory: breadcrumbs, persistent context, comparison views |
| Where to invest effort? | Pareto: 20% features serve 80% users — make those flawless |

---

## Self-Check

Before finishing any UX-significant work, verify each. If ANY fail, fix before responding.

1. **No decision overload** — Exactly 1 primary button per view. Nav items ≤7. Long option lists use progressive disclosure.
2. **Conventions respected** — Logo top-left. Search in header. Settings behind gear. Native form elements.
3. **Progress visible** — Every multi-step flow has step indicator, progress bar, or breadcrumb.
4. **Feedback on every action** — Every button has hover, `focus-visible`, and loading/disabled state for async. Zero static-after-click buttons.
5. **Attention guided** — ONE element per view is visually distinct. If everything is emphasized, nothing is.
6. **Errors recoverable** — Accept varied formats, normalize internally. Validate on submit. Errors inline next to field.
7. **Peak + end designed** — Final screen of every flow has: summary, next-action CTA, polished visual moment.
