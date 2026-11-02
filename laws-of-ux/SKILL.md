---
name: laws-of-ux
description: User-psychology rules for UX decisions, one section per decision area (navigation, forms, flows, actions, feedback, layout, copy, errors), each rule tied to its law.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html"]
disable-model-invocation: true
---

# Laws of UX

Each rule states what to do. The law in parentheses is the reason, and the name to cite in the audit. Source: Laws of UX by Jon Yablonski (lawsofux.com).

1. Pick every section below whose decision area the change touches. A form usually touches Forms and data input and Errors and recovery.
2. Apply every rule of each picked section to every changed screen.
3. Write the audit (last section). The work is done when the audit is complete.

## Navigation and information architecture

Applies to: primary navigation, menus, sidebars, site structure, breadcrumbs.

1. Show at most 7 primary navigation items, and mark the current one. Put the rest behind progressive disclosure: a "More" menu, grouped submenus, or search. (Hick's Law: decision time grows with the number of choices)
2. Give the primary slots to the features most users use most. Everything else goes one level down. (Pareto Principle)
3. Put wayfinding where the users' other products put it: the logo goes home, search sits in the header, account and settings sit in the same corner on every screen. Deviate only when the deviation itself carries product meaning. (Jakob's Law)
4. Name three products your users already use for this task. Match the structure of at least two of them, not the structure of your data model. (Mental Model)
5. Keep context on screen across views: breadcrumbs, persistent filters, side-by-side comparison. The user recognizes what is shown and never recalls a value from an earlier screen. (Working Memory)
6. Put the most important items first and last in a navigation list or toolbar. (Serial Position Effect)

## Forms and data input

Applies to: input forms, settings pages, data entry, search.

1. Group related fields into named blocks (identity, address, payment) of at most 7 fields each. (Miller's Law; Chunking)
2. Give every input a visible label. A placeholder disappears on focus, so it is only an example value. (Working Memory)
3. Pre-fill every value the system can know or detect: the name from the session, country, timezone, file type. Each field the system could fill is work moved onto the user. (Tesler's Law)
4. Pre-select the best default for every choice, and frame the options honestly. (Cognitive Bias: anchoring and status-quo bias)
5. Accept every reasonable format for dates, phone numbers and names, and normalize it in the system: "Jan 5", "1/5" and "2026-01-05" are one date. Let the user type and paste freely; trim whitespace before checking. (Postel's Law)
6. Check a field when the user leaves it with a value in it. Show the error inline, beside the field, as a rule the user can follow ("Use at least 8 characters"). Once a field shows an error, re-check it on every change so the error clears the moment it is fixed. Positive live feedback (password strength, name availability after a debounce) may run while the user types. (Working Memory: the error appears where and when attention is)
7. Check every field again on submit. Keep the submit button enabled, run cross-field and server checks, and move focus to the first invalid field. An error summary may sit above the form in addition to the inline errors. (Working Memory)

## Multi-step flows and progress

Applies to: onboarding, checkout, wizards, setup flows, long tasks.

1. Show progress in every multi-step flow: "Step 3 of 5", or a segmented bar with completed segments filled. (Zeigarnik Effect; Goal-Gradient Effect)
2. Split a long form into steps of one topic each. (Cognitive Load; Chunking)
3. Count honest early progress for new users: "Profile 20% complete. Add a photo." (Goal-Gradient Effect)
4. State the expected time at the start ("About 2 minutes"). Ask for short answers where a short answer does the job. (Parkinson's Law)
5. Carry routine feedback inline: toasts, status banners, inline notices. Open a blocking dialog only for a decision the user must make before going on, such as an irreversible confirmation or a required choice. (Flow)
6. End every flow on a screen that confirms the outcome in specific terms, summarizes what was done, and offers the next action. Give it the most design care of any screen in the flow. (Peak-End Rule)

## Actions and calls to action

Applies to: buttons, action bars, toolbars, action menus, confirmation dialogs.

1. Give each view exactly one visually distinct primary action. Make every other action quieter. (Von Restorff Effect)
2. Make targets large and near where attention or the thumb rests: on phones, primary actions within thumb reach at the bottom; in toolbars, key actions at the ends. (Fitts's Law)
3. Make destructive controls (Delete, Remove, Deactivate) quieter than the primary action and place them apart from it. (Fitts's Law: distance is a safety margin)
4. Show at most 7 options in an action menu, and mark the recommended one. Longer lists get search or filters. (Hick's Law; Choice Overload)
5. Make every primary action findable without a tutorial: its label and its place say what it does. (Paradox of the Active User)

## Feedback and response time

Applies to: async actions, loading states, submits, real-time updates.

1. Answer every user action with a visible response at once: a pressed control looks pressed, a running action shows that it runs. (Doherty Threshold; Flow)
2. Match the treatment to the expected wait. (Doherty Threshold: a response under 400 ms keeps the user engaged)

   | Wait | Treatment |
   |---|---|
   | Under 400 ms | The press state is enough. |
   | 400 ms to 1 s | A pending state inside the control ("Saving…") or an optimistic update. No blocking spinner. |
   | 1 to 4 s | A skeleton with the shape and count of the incoming content. |
   | Over 4 s | Measurable progress ("3 of 12 files") when the work reports it. |
   | Over 10 s | Status text and a way to cancel or leave. The work survives navigation. |

3. Update optimistically only for safe, reversible, frequent actions such as toggle, star or reorder. On failure, roll back visibly and offer a retry. (Doherty Threshold)

## Grouping and layout

Applies to: any layout, control groups, grids, cards.

1. After building, remove one element at a time. Leave out every element whose removal leaves the screen as clear as before. (Occam's Razor; Cognitive Load)
2. Group with spacing first: tight inside a group, wider between groups, widest between sections. (Law of Proximity)
3. Add a background or border region only for a distinct container, such as a card, panel or dialog, that spacing alone cannot separate. (Law of Common Region)
4. Give one function one look everywhere: buttons look like buttons, static text never looks clickable, links and headings differ in weight or color. (Law of Similarity)
5. Draw a line or connector only for a relationship stronger than proximity can show: steps in a wizard, callouts on a diagram. (Law of Uniform Connectedness)
6. Align every element to one grid and use one corner style across the screen, so whitespace forms clean rectangles. (Law of Prägnanz)
7. Run every usability check even when the screen looks finished. Polish hides friction from the team as well as from users. (Aesthetic-Usability Effect)

## Content and copy

Applies to: labels, headings, onboarding, tooltips, confirmations.

1. Use the words this reader uses for each thing (an investor, a clinic client, an operator). Keep internal names, code names and database terms out of the interface. (Mental Model)
2. Show a requirement the user cannot see from the control itself (a password rule, a file size limit) as helper text before input. Users skip instructions, so the requirement sits where they act. (Paradox of the Active User)
3. Present important content as part of the page. Users skip anything placed or styled like an advertisement, such as a full-width strip at the top or a promo-styled box. Guide the eye with size, weight and position. (Selective Attention: banner blindness)

## Errors and recovery

Applies to: failed actions, page errors, destructive actions, empty states.

1. Show an error where the failed action happened: on the field, the row or the control. Say what happened and how to recover, offer a retry, and keep the user's input. A toast carries only an error tied to nothing on screen, and it stays until dismissed. (Working Memory: the error appears where attention is)
2. Match the safety mechanism to reversibility. A reversible action (archive, remove from a list) runs at once and offers Undo for 5 to 10 seconds. An irreversible action, an action that affects other people, or one that destroys many items asks first, and its title names the object and the scale: "Delete 5 projects and their deployments?" (Habituation: confirmations users see often stop being read)
3. Give each kind of empty state its own copy. First use: the fact, what will appear here, the next action. Cleared by the user: the fact and how it refills. No results: the fact, the query, a way to loosen it. Caused by an error: the error treatment of rule 1, never "No items". Offer a next action only when the user can take one. (Paradox of the Active User)

## Audit

The work is done when the audit has a row for every picked section. Put the table in the report or its artifact.

- A rule that failed gets one row: the section, the rule number, and "fixed: <change>" or "exception: <reason>".
- A section with no failed rule gets one row: rule "all", verdict "pass".
- Two rules that pull one decision in opposite directions get one exception row that names both rules.

| Section | Rule | Verdict |
|---|---|---|
| Forms and data input | 6 | fixed: errors moved from a submit toast to the fields |
| Navigation and information architecture | all | pass |

When reviewing existing UX instead of building, write the same table with one row per violation, every violation found. Add its location (file and component), and write the verdict as "fix: <change>".
