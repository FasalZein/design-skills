# Visual Assets — Icons, Imagery, Illustration, Emoji

Assets read as intentional when they form systems: one icon family, one illustration voice, one image treatment. Mixed sources read as assembled, not designed.

## Icons

- **One family per product** — one stroke weight, one corner character, matched to the typeface (geometric type → geometric icons; humanist → softer). Mixing Lucide with Heroicons in one view is the tell.
- Size relative to text context: 1em–1.25em inline with text, 16/20/24px in UI chrome; align to cap height ([typography.md](typography.md)).
- Outline vs filled is a state axis when the family supports both: outline = default/inactive, filled = selected/active. Never mix arbitrarily.
- Labeling by role: decorative icons `aria-hidden="true"`; interactive icon-only controls get `aria-label` (kernel rule); status icons pair with text or a tooltip — an icon alone is not a status.
- An icon that needs explanation is the wrong icon — prefer text over an ambiguous glyph.

## Imagery

- Define a small role set with fixed aspect ratios (hero 16:9, card 3:2, avatar 1:1, thumbnail 4:3) — every image belongs to a role; no free-size images.
- Reserve the box before load (`aspect-ratio` or width/height attributes) — zero layout shift. `object-cover` with a chosen focal point; `object-position` when the subject is off-center.
- Responsive delivery: `srcset`/`sizes` (or the framework's image component), lazy-load below the fold, `loading="eager"` only for the LCP image.
- Every image has a designed placeholder (blur-up or tinted-surface) and a broken-state fallback (tinted surface + icon — never the browser's broken-image glyph).
- Alt text describes function/content; decorative images get `alt=""`.
- 1px black/white outline for edge definition ([spacing.md](spacing.md)).

## Illustration

Three legitimate roles — each needs a consistent, brand-owned family:

| Role | Use | Scale |
|---|---|---|
| Spot | empty states, errors, celebration | small, beside the message |
| Workflow | onboarding, explainer steps | medium, low-fidelity |
| Ambient | promotional/hero surfaces | large, background-weight |

- One illustration voice per product (same palette, same line weight, same fidelity). One stock graphic + one hand-drawn blob + one 3D render = three products.
- Illustrations stay lower-saturation than primary actions and never replace the explanatory copy — they accompany it.
- No brand-owned family available → use typography, icons, and surface treatment instead. A well-set empty state with a good message beats a mismatched free SVG (the sketchy-illustration slop the guardrails target).

## Emoji

Emoji are content tone, not UI: acceptable inside user content and informal body copy; never as functional icons, bullets, status indicators, or in headings/buttons. Rendering varies per platform and screen readers announce them verbosely — an icon from the product's family does the same job predictably.
