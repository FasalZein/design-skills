# Component Architecture

## Composition Model

```
primitives/  → Raw framework components (shadcn, Base UI, Radix)
components/  → Lightly customized wrappers with project variants
blocks/      → Product-level compositions (forms, panels, dashboards)
```

## Rules

- MUST check existing components before creating new ones. Reuse > reinvent.
- MUST wrap, don't modify upstream components. Extend via variants.
- MUST use `data-slot` attributes for semantic styling targets.
- MUST preserve accessibility from primitives — never remove ARIA attributes or keyboard handlers.
- MUST use CVA or equivalent for variant management. Never inline ternary chains.
- SHOULD use the `cn()` utility (clsx + tailwind-merge) for class composition.
- NEVER mix primitive systems (Base UI + Radix + Headless UI in the same project).

## Interaction States

EVERY interactive element MUST have ALL of these states designed:

| State | Required | Notes |
|-------|----------|-------|
| Default | Yes | Resting appearance |
| Hover | Yes | Subtle lift, color shift, or underline |
| Focus | Yes | `:focus-visible` ring (2px solid, 2px offset) — NEVER remove |
| Active/Pressed | Yes | Scale down slightly (0.97-0.98) or darken |
| Disabled | Yes | `opacity-50` + `pointer-events-none` + `cursor-not-allowed` |
| Loading | Yes | Inline spinner or skeleton, disable interaction |
| Error | Contextual | Red border + inline message |
| Success | Contextual | Green indicator + confirmation |

**Concrete button className template** — every button MUST include these classes:

```tsx
className="hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 active:scale-[0.97] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 transition-colors transition-transform duration-150"
```

For async actions, MUST include loading state:

```tsx
<button disabled={isSaving} aria-busy={isSaving}>
  {isSaving ? "Saving..." : "Save changes"}
</button>
```

## Interaction Rules

- MUST use `AlertDialog` for destructive/irreversible actions (delete, discard, overwrite).
- MUST show errors inline, next to where the action happened. Not in a toast, not at the top of the page.
- MUST use `aria-label` on every icon-only button.
- MUST use semantic HTML: `<button>` for actions, `<a>` for navigation. Never `<div onClick>`.
- SHOULD prefer undo over confirmation dialogs. Users click through confirmations mindlessly.
- SHOULD use optimistic UI for low-stakes actions (toggle, reorder). Not for payments or deletions.
- SHOULD use structural skeletons for loading states, not spinners. They preview content shape.
- NEVER block paste in inputs/textareas.
- NEVER use placeholder text as the only label — it disappears on input.

## Empty States

Empty states are first impressions. NEVER just "No items."

Every empty state MUST have:
1. A clear, warm message explaining what will appear here
2. A primary CTA to take the first action
3. Optionally: a small illustration or icon

```
BAD:  "No results"
GOOD: "No documents yet. Upload your first document to get started." [Upload Document]
```

## Error Messages

Every error message MUST answer three questions:
1. **What happened?** (the problem)
2. **Why?** (the cause, if known)
3. **How to fix it?** (the action)

```
BAD:  "Error occurred"
GOOD: "Couldn't save your changes. Check your internet connection and try again." [Retry]
```

- NEVER use humor in error messages. Users are already frustrated.
- NEVER use technical jargon (500, ECONNREFUSED, undefined is not a function).

## UX Writing

- MUST use specific verb + object for button labels: "Save changes" not "OK". "Delete 5 items" not "Yes".
- MUST pick one term and use it everywhere: Delete/Remove/Trash → pick one. Settings/Preferences/Options → pick one.
- SHOULD use active voice: "Save changes" not "Changes will be saved".
- SHOULD cut every sentence in half, then do it again.
- SHOULD add 30-40% space budget for i18n (German text is 30% longer than English).
- NEVER repeat information — redundant headers, intros that restate the heading.

## Symptom-to-Correction Table

When output looks "almost good but not quite," use this diagnostic:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Looks decent but generic | Equal-weight cards, uniform padding/radius, shadow haze | Remove a widget, merge a region, flatten one surface layer |
| Everything competes for attention | Multiple primary buttons, similar visual weight on all sections | Pick ONE dominant element, mute everything else |
| Feels cramped | Uniform tight spacing, no breathing room between sections | Increase gap between sections (keep tight gaps within groups) |
| Feels empty despite content | Too much whitespace between items, thin typography | Tighten item spacing, increase font weight on key elements |
| Layout clips on real content | Fixed heights without overflow strategy | Use min-h instead of h, add overflow-y-auto on scrollable regions |
| Dark mode looks washed out | Same chroma/weight as light mode | Desaturate accents slightly, reduce font weight (350 instead of 400) |
| Numbers feel jumpy on update | Missing tabular-nums | Add `font-variant-numeric: tabular-nums` to all numeric displays |
| Sidebar fights content area | Sidebar too bright, same visual weight as main | Dim sidebar bg 1-2 steps, reduce inactive icon/text to 40-50% opacity |
