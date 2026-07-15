---
name: laws-of-ux
description: User-psychology rules for UX decisions — cognitive load, attention, memory, mental models, motor cost, perception. Use when choosing nav structure, form length, decision flows, error recovery, onboarding, progress indicators, or microcopy, or when a flow feels confusing, overwhelming, or hard to complete. Complements design-craft (craft) with the WHY (psychology).
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html"]
---

# Laws of UX

Psychology-driven constraints for interface decisions, organized by **engineering decision**. Rules lead; law names follow in parentheses as justification.

---

## Global Principles

Apply these everywhere before category-specific rules.

- **Remove every element that doesn't serve comprehension.** After building, delete one element at a time — if the page still works and communicates clearly, leave it deleted. (Cognitive Load / Occam's Razor)
- **Focus engineering on the 20% of features used by 80% of users.** The primary flow must be flawless; edge cases adequate. (Pareto / 80-20 Rule)
- **Push complexity into the system, not onto the user.** Auto-detect timezones, infer file types, pre-fill from context. If the user configures something the system could detect, the system failed. (Tesler's Law)

---

## 1. Navigation & Information Architecture

Apply when: designing primary nav, menus, sidebars, site structure, breadcrumbs.

- **Limit primary nav to 5–7 items.** Highlight the single recommended/current path. Use progressive disclosure for anything beyond 7. (Hick's Law: decision time grows log-linearly with the number of choices)
- **Match established mental models before innovating.** Users expect your product to work like the last 10 products they used: logo leading to home, search in the header, settings in a predictable place. These placements are the default because they are what users already know — deviate only when the deviation itself carries product meaning. Innovate on content, not on wayfinding. (Jakob's Law / Mental Model)
- **Name 3 prior products your users use for this task. Your IA structure should match at least 2 of them.** If it doesn't, adapt to their model, not your data model. (Mental Model)
- **Show breadcrumbs and persist context across screens.** Use comparison tables instead of asking users to remember screen 1. Never make users carry mental state across views. (Working Memory / Recognition over Recall)
- **Place the most important nav items at the first and last positions.** Key toolbar actions belong at edges, not center. (Serial Position Effect: first and last positions are remembered best)

---

## 2. Forms & Data Input

Apply when: building input forms, settings pages, data entry flows, search.

- **Group related fields into named blocks, not a flat list.** Address, payment, and identity fields should each form a distinct visual unit — never 12 flat fields. Aim for ≤7 items per group. (Miller's Law: working memory holds ~7±2 items)
- **Accept every reasonable date, phone, and name format.** "Jan 5", "1/5", "2026-01-05" are all valid inputs. Normalize internally, display consistently, and never reject valid intent due to format — if the user types "555-867-5309" and your model wants "5558675309", convert silently. (Postel's Law)
- **Validate a field when the user finishes it, not while they type.** Errors mid-keystroke punish incomplete input; errors deferred to submit arrive after the user has mentally left the field. Show the error inline, adjacent to the field, at field completion (blur); reserve submit-time validation for cross-field and server checks. (Postel's Law + Working Memory: put the error where and when the user is looking)
- **Pre-fill every value the system can infer.** Name from session, country from IP, timezone from browser. Every field the user doesn't have to fill is friction removed. (Tesler's Law — see Global Principles)
- **Pre-select the best default option.** Users anchor on the first value they see and default to pre-selected choices. Frame options to reduce regret. Never deceive, but never leave defaults unset. (Cognitive Bias: anchoring and status quo bias)
- **Every text input must have a visible label, not just placeholder text.** Placeholder disappears on focus, leaving no memory aid mid-entry. (Working Memory)

---

## 3. Multi-Step Flows & Progress

Apply when: building onboarding, checkout, wizards, setup flows, long tasks.

- **Every multi-step flow must show a step indicator or progress bar.** "Step 3 of 5" or a segmented bar with completed segments filled. Zero progress indicators on multi-step = fail. (Zeigarnik Effect: incomplete tasks stay top-of-mind; Goal-Gradient Effect: motivation increases near the goal)
- **Show honest early progress for new users.** "Profile 20% complete — add a photo" increases completion. Use it to accelerate initial engagement, not to deceive. (Goal-Gradient Effect)
- **Keep routine work inline; reserve blocking dialogs for decisions that must stop progress.** Toasts, banners, and inline notices carry routine feedback without breaking flow. A blocking dialog is justified only when the user must make a deliberate decision before continuing — an irreversible confirmation, a required choice. A modal that merely announces something mid-task kills flow. (Flow: optimal engagement requires no gratuitous interruption)
- **Set time expectations explicitly.** "This takes about 2 minutes." Don't give open-ended inputs where 2-word answers will do. Autofill and smart defaults cut completion time. (Parkinson's Law: tasks expand to fill available time)
- **Invest disproportionately in the final screen of every flow.** It should include: a summary of what was done, a clear next-action CTA, and a polished visual moment. The peak moment and the ending are what users remember; everything in between fades. (Peak-End Rule)

---

## 4. CTAs & Action Hierarchy

Apply when: designing buttons, action bars, toolbars, confirmation dialogs.

- **Exactly 1 visually distinct primary CTA per view.** Every other action must be visually quieter. If everything is emphasized, nothing is. (Von Restorff Effect: the distinct item gets remembered)
- **Make targets easy to hit: large, and near the user's resting attention.** Primary actions near the resting thumb position on mobile (bottom of screen); destructive actions — Delete, Remove, Deactivate — visually quieter and physically distant from Save. (Fitts's Law: target acquisition time = f(distance, size))
- **Limit visible options in any action menu to ≤7.** For large catalogs, use filters or search. Add "Recommended" badges to the best option. (Hick's Law / Choice Overload)

---

## 5. Feedback & Response Time

Apply when: building async actions, loading states, real-time updates, async submits.

- **Provide immediate visual feedback for every user action.** No silent-on-click interactions anywhere; a pressed control shows it was pressed, an async action shows it is working. (Doherty Threshold / Flow: clear feedback is required for optimal engagement)
- **Response under 400ms keeps flow unbroken.** Past 400ms, show feedback in the control itself (pending state) or update optimistically; past ~1 second, show the content's shape (skeleton); past a few seconds, show measurable progress. (Doherty Threshold: sub-400ms keeps the user engaged; over 400ms breaks concentration)

---

## 6. Visual Grouping & Layout

Apply when: organizing any layout, grouping controls, building grids, designing cards.

- **Use spacing to signal grouping before using borders or backgrounds.** Tight within a group, generous between groups, largest between sections. Proximity is stronger than common region. (Gestalt Proximity)
- **Identical visual style signals identical function.** Buttons look like buttons everywhere; static content never looks clickable. Don't make links and headings share the same weight at the same size. (Gestalt Similarity)
- **Use a background or border region to group related controls only when spacing isn't enough.** Regions are heavier-handed than proximity — use them for genuinely distinct semantic containers (a card, a panel, a modal). (Gestalt Common Region)
- **Use lines, arrows, or connectors when you need to express a relationship stronger than proximity or similarity can.** Step connectors in wizards, callout lines on diagrams. Connectedness overrides all other grouping cues. (Gestalt Connectedness)
- **Align all elements to a visible grid. Use consistent shapes — all rounded or all sharp corners, not mixed.** Whitespace should form clean rectangles. If a layout looks messy, the shapes aren't resolving to simple forms. (Gestalt Prägnanz: people perceive the simplest possible form)
- **Polish earns forgiveness — but only for minor friction.** Polished interfaces are perceived as more usable and buy patience for small flaws. Never skip usability checks because the surface looks good; the halo effect masks real problems. (Aesthetic-Usability Effect)

---

## 7. Content & Copy

Apply when: writing labels, empty states, onboarding copy, tooltips, confirmation messages.

- **Make the primary action visible without scrolling and discoverable without a tutorial.** Every primary action needs an inline affordance — tooltip, empty-state next action, helper text. Design for the user who skipped every tutorial and never reads documentation. (Active User Paradox: users never read manuals)
- **Never place important content in banner-like positions at top of page.** Users develop banner blindness and filter out anything resembling an advertisement in position and style. Use size contrast (2× difference between primary and secondary elements), weight, and left-alignment to guide the eye instead. (Selective Attention / Banner Blindness)

---

## 8. Error Handling & Recovery

Apply when: designing validation, error states, empty states, destructive action flows.

- **Errors appear inline, adjacent to the field that caused them** — not in a toast, not in a banner at the top. Timing and format acceptance follow the Forms rules above. (Working Memory: put the error where the user is looking)
- **Match the safety mechanism to reversibility.** A reversible destructive action gets immediate execution plus a visible undo window — confirmation dialogs for reversible actions train users to click through them. An irreversible or high-stakes action gets an explicit confirmation that names what is being destroyed and how much. In both cases the destructive control is visually quieter and physically distant from the primary action. (Fitts's Law: distance creates safety margin; habituation: repeated confirmations stop being read)
- **An empty state explains itself and offers a way forward when one exists.** State the fact ("No deploys yet"), give context (why, or what this will show), and offer the next action when the user can actually take one. First-use, user-cleared, no-results, and error-caused empties are different states with different copy. (Active User Paradox: discoverable actions over passive dead ends)

---

## Decision Matrix

| Engineering decision | Rule | Laws |
|---|---|---|
| How many nav items? | ≤7, highlight the recommended/current one | Hick + Miller |
| Form feels too long? | Multi-step; push complexity into system; pre-fill what you can | Tesler + Miller + Chunking |
| Where to place the CTA? | Big target, thumb-reachable on mobile, edge in toolbar | Fitts + Serial Position |
| What to emphasize? | ONE element per view is visually distinct; everything else quieter | Von Restorff |
| Multi-step flow stalling? | Show step indicator + honest early progress | Zeigarnik + Goal-Gradient |
| Users confused by navigation? | Match the convention; match their existing mental model | Jakob + Mental Model |
| Slow response (>400ms)? | Show the content's shape or optimistic update; then measurable progress | Doherty Threshold |
| When to validate a field? | On field completion (blur), inline; submit only for cross-field/server | Postel + Working Memory |
| Destructive action? | Undo for reversible; explicit confirmation for irreversible | Fitts + habituation |
| Interrupt with a modal? | Only for decisions that must stop progress; routine feedback stays inline | Flow |
| Users ignoring important content? | Avoid ad-like positions; use size contrast 2×+, not color alone | Selective Attention + Banner Blindness |
| Low satisfaction after a flow? | Redesign the peak moment and the final screen | Peak-End Rule |
| Too many options in a menu? | ≤7 visible; add filter/search for larger lists; pre-select best | Hick + Choice Overload |
| Grouping visually unclear? | Spacing first → similarity → common region → connectedness | Gestalt (subtlety order) |
| Accepting user input? | Accept any reasonable format, normalize on the back end | Postel's Law |
| Users forgetting prior screen? | Breadcrumbs, persistent context, comparison views | Working Memory |
| Where to invest engineering time? | Primary flow flawless; edge cases adequate | Pareto 80/20 |

---

## Decision Audit

Before finishing any UX-significant work, audit each decision against the principle that governs it. Every UX-significant choice names its law; no two applied principles conflict.

1. **Decision load** — exactly 1 primary action per view; ≤7 nav items; ≤7 visible menu options (or search/filter).
2. **Familiarity** — wayfinding matches the user's prior products; deviations are deliberate and meaningful.
3. **Feedback** — every action produces an immediate visible response; async work shows its state.
4. **Recovery** — errors are inline and adjacent; formats are accepted and normalized; destructive actions match their reversibility.
5. **State completeness** — every surface has a designed answer for empty, loading, and error, not just populated.
6. **Motor cost** — targets are comfortably hittable; destructive controls sit away from primary ones.
7. **End-state quality** — the final screen of each flow has a summary, a next action, and a polished moment.

---

## Review Output Format

When reviewing existing UX (rather than building), present findings as a markdown table — every violation, not a subset:

| Violation | Law | Fix |
|---|---|---|
| 11 items in primary nav | Hick's Law | Keep 6, move the rest behind "More" with progressive disclosure |
| Checkout has no step indicator | Zeigarnik / Goal-Gradient | Add "Step 2 of 4" segmented bar, completed segments filled |

Cite file and component when not obvious from the row. If a category was checked and passed, omit it — silence = pass.
