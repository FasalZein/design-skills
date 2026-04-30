# Spacing

## System

Use a 4px base grid. All spacing values MUST be multiples of 4px.

Define semantic spacing tokens:
```
tight:    0.25rem (4px)   — within atomic elements
item:     0.5rem  (8px)   — between items in a group
group:    1rem    (16px)  — between related groups
section:  1.5rem  (24px)  — between major sections
page:     2-4rem  (32-64px) — page-level margins
```

## Rules

- MUST use spacing tokens or the framework's spacing scale. NEVER arbitrary values like `p-[13px]` or `gap-[7px]`.
- MUST create visual rhythm through varied spacing: tight within groups, generous between sections. Not the same padding everywhere.
- MUST use Gestalt proximity: related elements get tighter spacing, unrelated get looser.
- SHOULD give white space generously between unrelated elements — white space is a feature, not waste.
- NEVER use triple-layered responsive padding (`p-4 lg:p-8 xl:p-10`). Pick one value per context.

**Acceptable arbitrary values** (these are NOT violations):
- `max-w-[65ch]` or `max-w-prose` — line length control (recommended)
- `max-w-[45ch]` — narrower body text (e.g., empty states, descriptions)
- `min-h-[*rem]` — minimum heights for textareas or containers
- `grid-template-columns` or `grid-template-rows` with specific values

**Still banned** arbitrary values:
- `p-[17px]`, `m-[13px]`, `gap-[7px]` — spacing that should use the 4px scale
- `w-[423px]`, `h-[287px]` — sizing that should use the Tailwind scale or tokens
- `text-[13px]`, `text-[15px]` — typography that should use the type scale

## Border Radius

- MUST pick ONE base radius and derive all others from it. Consistency > variety.
- Buttons/inputs: medium radius (4-6px)
- Cards/dialogs: larger radius (8px)
- Badges/chips: small radius (4px) or `rounded-full` for pills
- Avatars: `rounded-full` only
- Outer radius = inner radius + padding (concentric border radius)
- NEVER mix arbitrary radius values. NEVER `rounded-[10px]`.

## Shadows

Shadows should be barely perceptible. Premium = multi-layer, low opacity:

```css
/* Good: subtle, multi-layer (Stripe-style) */
box-shadow: 0 1px 1px rgba(0,0,0,0.03), 0 3px 6px rgba(0,0,0,0.02);

/* Bad: heavy, single-layer */
box-shadow: 0 4px 12px rgba(0,0,0,0.15);  /* shadow-lg — too much */
```

- SHOULD use `shadow-sm` for subtle elevation, `shadow-md` sparingly for popovers
- NEVER use `shadow-lg` or `shadow-xl` on small components
- Pick ONE grouping method per section: borders OR shadows OR spacing. Never all three together.

## Anti-Pattern

```
BAD:  <div className="p-4"><div className="p-4"><div className="p-3">  → padding soup
GOOD: <div className="space-y-6"><section className="space-y-4">       → semantic rhythm
```
