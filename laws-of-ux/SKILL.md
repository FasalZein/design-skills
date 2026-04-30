---
name: laws-of-ux
description: User-psychology rules for UX decisions — cognitive load, attention, memory, mental models, motor cost, perception. Use when choosing nav structure, form length, decision flows, content ordering, error recovery, onboarding, progress indicators, or microcopy. Complements design-craft (craft) with the WHY (psychology).
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html"]
---

# Laws of UX

Psychology-driven constraints for interface decisions. Design-craft handles the HOW (tokens, spacing, animation). This skill handles the WHY (how cognition, memory, attention, and motor cost shape what users actually experience).

Based on [Laws of UX](https://lawsofux.com) by Jon Yablonski.

---

## 1. Reduce Decision & Memory Cost

Apply when: designing navigation, forms, settings, onboarding, any view with options.

**Hick's Law** — Decision time grows with the number and complexity of choices.
- Limit primary nav to 5-7 items. Highlight the recommended choice. Use progressive disclosure over walls of options.

**Miller's Law** — Working memory holds ~7 (±2) items.
- Don't use "magic number 7" as a hard cap — use it to justify chunking. Group related inputs (address block, payment block) rather than presenting 12 flat fields.

**Working Memory** — Temporary cognitive storage holds 4-7 chunks for ~20-30 seconds.
- Support recognition over recall: visually mark visited links, show breadcrumbs, carry critical context across screens (don't make users remember from the previous step). Comparison tables instead of "remember what was on screen 1."

**Chunking** — Breaking information into meaningful groups aids comprehension.
- Phone numbers as `(555) 123-4567` not `5551234567`. Split long forms into multi-step wizards. Group related settings under collapsible sections.

**Cognitive Load** — Mental resources are finite; intrinsic load (the task itself) + extraneous load (interface friction) = total burden.
- Minimize extraneous load: remove decorative elements that don't serve comprehension. Pre-fill known values. Show only what's needed for the current step. Every additional element competes for the same finite attention budget.

**Choice Overload** — Too many options leads to decision paralysis and lower satisfaction.
- Limit visible choices. Offer smart defaults. Use filters/search for large catalogs instead of showing everything. "Recommended" badges reduce cognitive cost.

**Tesler's Law** — Every system has irreducible complexity; the question is who absorbs it.
- Push complexity into the system, not onto the user. Auto-detect timezones instead of asking. Infer file types instead of requiring selection. If complexity can't be eliminated, provide contextual guidance (tooltips, inline help).

**Occam's Razor** — The simplest solution with fewest assumptions is preferred.
- Remove elements until further removal would break function. Fewer features executed well > many features half-done. Consider completion only when nothing else can be removed.

---

## 2. Build on Familiarity

Apply when: designing navigation patterns, form controls, onboarding, or making major redesigns.

**Jakob's Law** — Users spend most time on OTHER sites and expect yours to work the same way.
- Use conventional patterns: logo top-left links home, search top-right, settings behind a gear icon. Don't innovate on navigation to be "unique" — innovate on the content and value. When redesigning, allow users to ease into the new version (progressive rollout, option to revert).

**Mental Model** — Users carry compressed models of how systems work based on prior experience.
- Match your interface to the user's existing mental model, not your data model. A "shopping cart" works because people already understand physical carts. Test whether users' expectations match your structure — if not, adapt to theirs.

**Paradox of the Active User** — Users never read manuals; they start using immediately.
- Don't rely on tutorials or onboarding guides. Make the primary action obvious and discoverable. Use inline contextual help (tooltips, placeholder text, empty state CTAs) — not upfront instruction walls. Design for the user who skipped every tutorial.

---

## 3. Direct Attention & Create Emphasis

Apply when: designing CTAs, notifications, status indicators, visual hierarchy, or any view competing for attention.

**Von Restorff Effect** — The item that differs from the rest is most likely remembered.
- Make the primary CTA visually distinct from surrounding elements. Use restraint — if everything is emphasized, nothing is. Don't rely solely on color (accessibility); combine with size, weight, or position. Avoid styling content to look like ads (banner blindness).

**Selective Attention** — Users filter out information irrelevant to their current goal.
- Guide attention with visual hierarchy, not by adding more elements. Users develop banner blindness — don't place important content in ad-like positions or with ad-like styling. Avoid competing simultaneous changes (change blindness); sequence updates so each gets noticed.

**Serial Position Effect** — Users remember the first and last items in a series best.
- Place the most important nav items at the start and end (e.g., mobile tab bars: Home first, Profile last). Put the least critical items in the middle. Key actions in toolbars belong at the edges, not buried center.

**Aesthetic-Usability Effect** — Beautiful interfaces are perceived as more usable.
- Visual polish creates a halo effect — users tolerate minor friction in a well-crafted UI. But: aesthetics can MASK real usability problems during testing. Don't skip usability testing just because it "looks good."

---

## 4. Shape Experience & Memory

Apply when: designing onboarding flows, checkout, error recovery, long-running tasks, or any multi-step journey.

**Peak-End Rule** — People judge experiences by the peak moment and the ending, not the average.
- Invest disproportionately in: (1) the most intense/valuable moment and (2) the final step. A delightful confirmation screen matters more than a slightly faster step 3. Negative peaks (errors, confusion) are recalled more vividly than positive ones — prioritize eliminating pain points over adding delight.

**Zeigarnik Effect** — Incomplete tasks are remembered better than completed ones.
- Use progress indicators to signal incompleteness — users are motivated to close the loop. Show "3 of 5 steps complete" in onboarding. Checklist-style dashboards exploit this. But don't abuse it (dark pattern territory: fake urgency, manufactured incompleteness).

**Goal-Gradient Effect** — Motivation increases as users approach a goal.
- Show progress visually (progress bars, step indicators). Consider artificial progress: "You're already 20% done!" at sign-up increases completion rates. The closer users feel to the goal, the faster they'll work to finish.

**Flow** — Optimal engagement occurs when challenge matches skill, with clear feedback and no interruption.
- Remove unnecessary friction (extra confirmations, redundant steps). Provide immediate feedback for every action. Don't interrupt users mid-task with modals, popups, or unrelated notifications. Match task difficulty to user capability — progressive complexity for power users, simplicity for new users.

---

## 5. Motor Cost & Timing

Apply when: sizing touch targets, positioning actions, setting system response times, or designing time-sensitive interactions.

**Fitts's Law** — Time to reach a target = f(distance, size). Bigger + closer = faster.
- Touch targets ≥ 44×44px with adequate spacing between them. Place primary actions near the user's natural resting position (bottom of mobile screens, near current focus on desktop). Destructive actions should be small and far from the primary action — not next to "Save."

**Doherty Threshold** — System response under 400ms keeps users in flow; above it breaks engagement.
- Show feedback within 400ms. If processing takes longer, use perceived performance: skeleton screens, optimistic UI, progress animations. Purposeful micro-delays (200-300ms) on important actions can actually increase perceived value and trust — instant can feel cheap for "big" operations.
- EVERY submit/confirm button MUST have a loading state: disable the button + show inline spinner or "Processing..." text while the action completes. Never leave a user wondering if their click registered.

**Parkinson's Law** — Tasks expand to fill the time available.
- Set appropriate time expectations. Don't give users an open-ended text field for a 2-word answer. Autofill and smart defaults reduce form completion time. If you expect the task to take 2 minutes, design for 2 minutes — don't build a UI that feels like 10.

---

## 6. Perception & Grouping (Gestalt)

Apply when: organizing layout, grouping related controls, designing visual relationships.

> Design-craft §4 (Spacing) already covers Gestalt proximity in implementation. This section covers the psychological principles to apply when making grouping decisions.

**Law of Proximity** — Nearby elements are perceived as related.
- Tighter spacing within a group, more spacing between groups. This is your primary tool for visual organization — more powerful than borders or backgrounds.

**Law of Similarity** — Visually similar elements are perceived as related.
- Consistent styling (color, shape, size) signals shared function. Navigation links should look alike. Differentiate actionable elements from static content through consistent visual treatment.

**Law of Common Region** — Elements sharing a bounded area are perceived as a group.
- Use backgrounds or borders to create regions. But prefer proximity first — common region is the heavy-handed version. Don't put borders around everything (see design-craft: "cards are containers, not decoration").

**Law of Uniform Connectedness** — Visually connected elements are perceived as more related.
- Lines, arrows, and connecting elements create relationships. Flow diagrams, breadcrumbs, and step connectors use this. Stronger than proximity or similarity alone.

**Law of Prägnanz** — People interpret complex visuals as the simplest possible form.
- Simplify visual complexity. Users will "see" patterns even in noise — make sure the patterns they find are the ones you intended. Reduce visual elements to their essential form.

---

## 7. Robustness & Prioritization

Apply when: handling user input, planning feature scope, designing error tolerance.

**Postel's Law** — Be liberal in what you accept, conservative in what you send.
- Accept varied input formats (dates as "Jan 5", "1/5", "2026-01-05"). Auto-correct common mistakes. Validate on submit, not on every keystroke. Display output in a single consistent format regardless of input format.

**Pareto Principle** — ~80% of effects come from ~20% of causes.
- Focus design effort on the 20% of features used by 80% of users. The primary flow should be flawless; edge-case flows can be adequate. Prioritize fixing the top 20% of reported usability issues for maximum impact.

**Cognitive Bias** — Users make systematic, predictable errors in judgment.
- Design for real behavior, not rational behavior. Users satisfice (pick "good enough"), not optimize. They anchor on the first number they see (pricing), default to the pre-selected option, and overweight losses vs. gains. Use these patterns ethically: pre-select the best option, frame choices to reduce regret, show what they'll lose by not acting — but never to deceive.

---

## Decision Matrix

When facing a design decision, check the relevant row:

| Decision | Apply |
|---|---|
| How many nav items? | Hick + Miller: ≤7, highlight default |
| Form too long? | Chunking + Tesler: multi-step, push complexity into system |
| Where to place CTA? | Fitts + Serial Position: big target, edge position |
| What to emphasize? | Von Restorff: make ONE thing different. If everything is bold, nothing is |
| Multi-step flow stalling? | Goal-Gradient + Zeigarnik: show progress, signal incompleteness |
| Users confused by layout? | Jakob: match convention. Mental Model: match their model, not yours |
| Slow response? | Doherty: feedback <400ms, skeleton/optimistic UI for longer waits |
| Users ignoring key info? | Selective Attention: don't put it where ads go. Change blindness: sequence changes |
| Post-flow satisfaction low? | Peak-End: invest in the best moment + the final screen |
| Too many options shown? | Choice Overload + Occam: smart defaults, filter/search, remove until it breaks |
| Grouping unclear? | Proximity > Similarity > Common Region > Connectedness (in order of subtlety) |
| Varied/messy user input? | Postel: accept liberally, normalize internally, display consistently |
| Users having to remember from prior screen? | Working Memory: support recognition — breadcrumbs, persistent context, comparison views |
| Where to invest effort? | Pareto: 20% of features serve 80% of users — make those flawless |

---

## Self-Check

Before finishing any UX-significant work, verify each item. If ANY fail, fix before responding.

1. **No decision overload** — Count primary-styled buttons per view: must be exactly 1. Nav items visible without scrolling: ≤7. Long option lists use progressive disclosure (collapsible sections, tabs, or filters) not flat rendering.
2. **Conventions respected** — Logo/brand top-left. Search accessible from header. Settings behind a gear/cog icon. Form controls use native HTML elements (`<select>`, `<input>`, `<button type="submit">`).
3. **Progress visible** — Every multi-step flow has a visible step indicator ("Step X of Y"), progress bar, or breadcrumb. Users always know where they are and how much is left.
4. **Feedback on every action** — Every `<button>` with an onClick/onSubmit has: hover state, `focus-visible` ring, and a loading/disabled state for async actions (spinner + text change like "Saving..." or "Processing..."). Zero buttons that stay static after click.
5. **Attention guided** — Exactly ONE element per view is visually distinct (filled accent color, scale, badge). If everything is emphasized, nothing is.
6. **Errors recoverable** — Inputs accept varied formats and normalize internally. Validation on submit, not per-keystroke. Error messages appear inline next to the field, not in toasts or page-top banners.
7. **Peak + end designed** — The final screen of every flow (confirmation, success, completion) is deliberately crafted with: summary of what was done, clear next-action CTA, and a polished visual moment.
