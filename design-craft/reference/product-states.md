# Product States — Loading, Empty, Error, Validation, Destructive, Optimistic

A mock shows the populated state; a product designs all of them. The kernel requires the four-state contract on every async data surface — **loading, populated, empty, error** — this file owns the recipes. Conditional states when reachable: idle (before first query), success (after a completing action), permission-denied, offline, stale/partial data.

## Loading tiers

Timing decides the treatment — one spinner for everything is as wrong as none:

| Wait | Treatment |
|---|---|
| < 1s | No blocking indicator — a flash of spinner is worse than nothing. In-control feedback only (button pending state). |
| 1–4s | Content skeleton matching the incoming shape, or in-control spinner for actions. |
| > 4s | Measurable progress when the work reports it (percent, steps, "3 of 12 files"). |
| > 10s | Explicit status + a way to cancel or leave; the UI must survive the user navigating away. |

Skeleton rules: match the real content's shape and count (3 expected rows → 3 skeleton rows), reserve the same space (zero shift on arrival), `aria-hidden="true"` on the skeleton itself, `aria-busy="true"` on the containing region with a polite live-region status. Skeleton pulse is legitimate feedback (guardrail exempts it); the skeleton disappears completely on first data.

## Async action lifecycle

Every action that leaves the client runs **idle → pending → success | error** (kernel rule). The recipe:

- Pending: control disabled against duplicate activation, label states progress ("Saving…"), `aria-busy` set, focus stays on or returns to the control.
- Success: visible where the action happened — inline confirmation, updated data, or a toast for cross-page effects. A form that just goes quiet failed.
- Error: inline at the point of action with a retry path; the user's input is never destroyed by a failure.

```tsx
<button disabled={pending} aria-busy={pending}>
  {pending ? "Saving…" : "Save changes"}
</button>
```

## Empty states

Four different empties, four different messages:

| Type | Copy shape | Example |
|---|---|---|
| First use | Fact + what this will show + next action | "No deploys yet. Deploys appear here after your first push." [Connect repo] |
| User-cleared | Fact + how to refill | "Inbox zero. New mentions land here." |
| No results | Fact + query + loosen path | "Nothing matches 'sdak'. Try fewer filters." [Clear filters] |
| Error-caused | This is an error state, not an empty — see below | |

CTA only when a real next action exists (kernel rule) — "No audit logs yet" needs no button. An illustration is optional garnish, never the message.

**Position:** inside a data region (table, list, grid), the empty message sits where the first row would sit — top-anchored, one group unit of inset — and the region collapses to the message's height. Vertically centering three lines in the populated state's full reserved height reads as a broken page. Full-page empties (no shell content at all) may center.

## Error states

Answer three questions, in the user's language: what happened, why (when known), how to recover. Preserve last-known-good data where useful ("Showing cached results from 2:14 PM").

```
BAD:  "Error occurred" / "ECONNREFUSED" / "Oops! Something went wrong 😢"
GOOD: "Couldn't save your changes. Check your connection and try again." [Retry]
```

No blame ("you entered an invalid…" → "enter a date after 2020"), no humor, no raw codes in the message body (codes may follow in small print for support). Error-caused empty regions show the error treatment, not "No items".

Permission-denied states say who can grant access. Offline states say what still works. Stale states timestamp what's shown.

## Form validation

- Validate a field on completion (blur), inline, adjacent to the field. Never mid-keystroke errors — except live *positive* affordances (password strength meter, availability check after debounce).
- Once a field has erred, re-validate on change so the error clears the moment it's fixed.
- Submit-time validation is for cross-field and server checks; a submit failure focuses the first invalid field. An error summary may accompany field-adjacent errors, never replace them.
- Error message states the rule, not the failure: "Use at least 8 characters", not "Password invalid".
- Disabled submit buttons hide *why* — prefer enabled submit + validation over a mystery-disabled button.

## Destructive actions

Match the mechanism to reversibility (kernel rule):

- **Reversible** (archive, remove from list, unsubscribe): execute immediately, confirm with a 5–10s undo window (toast with Undo). Confirmation dialogs for reversible actions train click-through.
- **Irreversible / high-stakes** (delete data, cancel subscription, transfer ownership): explicit confirmation naming the object and scale — "Delete 5 projects and all their deployments?" For the highest stakes, typed confirmation of the resource name.
- Either way: the destructive control is visually quieter than and physically distant from the primary action.

## Optimistic updates

Only for safe, reversible, high-frequency actions (toggle, star, reorder) — never payments, deletions, or anything with server-side validation the client can't predict.

- Apply the change instantly; keep the request in flight.
- On failure: roll back visibly (the toggle flips back — motion draws the eye), explain, offer retry.
- On timeout: surface pending state rather than pretending success.
- On response: reconcile to the server's authoritative value.

## Realistic data matrix

Test every list/collection surface against: **0 items, 1, 3, 1000+**, the longest realistic string (no truncated mid-word overflow), empty strings, emoji content, RTL text. A layout that only survives 3–6 tidy English rows is a mock.
