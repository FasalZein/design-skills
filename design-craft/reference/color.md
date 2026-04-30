# Color

## System Architecture (Three Layers)

```
Layer 1: Primitive tokens (raw palette)     → oklch(95% 0.005 250)
Layer 2: Semantic tokens (purpose-driven)   → --color-bg, --color-text, --color-accent
Layer 3: Component tokens                   → --button-primary-bg
```

Components reference ONLY semantic tokens. Never use primitives or raw hex/rgb/hsl directly.

## Rules

- MUST use ONLY semantic color classes. NEVER use Tailwind palette colors directly in components.

```
BANNED (Tailwind palette — these are primitives, not semantic):
  bg-emerald-50, bg-emerald-500, text-emerald-600, text-emerald-700
  bg-red-50, bg-red-500, text-red-600, text-red-700
  bg-amber-50, bg-amber-500, text-amber-600, text-amber-700
  bg-blue-50, bg-blue-500, text-blue-600, text-blue-700
  bg-green-*, bg-cyan-*, bg-violet-*, bg-purple-*, bg-pink-*
  Any color with a number suffix (e.g., -50, -100, -200, ..., -950)

REQUIRED — use ONLY these semantic tokens in JSX className:
  bg-background, text-foreground
  bg-card, text-card-foreground
  bg-popover, text-popover-foreground
  bg-primary, text-primary, text-primary-foreground
  bg-secondary, text-secondary-foreground
  bg-muted, text-muted-foreground
  bg-accent, text-accent-foreground
  bg-destructive, text-destructive, text-destructive-foreground
  border-border, ring-ring

Opacity modifiers on semantic tokens ARE allowed:
  bg-primary/10, bg-primary/90, bg-destructive/10, border-destructive/30

STATUS COLORS (use these semantic patterns):
  Success: text-emerald classes → use a custom --status-success token OR bg-primary/10 text-primary
  Warning: text-amber classes → use a custom --status-warning token OR bg-accent text-accent-foreground
  Error: text-red classes → use bg-destructive/10 text-destructive
  Info: text-blue classes → use bg-secondary text-secondary-foreground
```

If the project does not define status tokens, use the destructive/primary/secondary/accent semantic tokens with opacity modifiers (e.g., `bg-primary/10 text-primary` for success, `bg-destructive/10 text-destructive` for error).

- MUST maintain text contrast ratio ≥ 4.5:1 (WCAG AA). No exceptions.
- MUST tint neutrals toward the brand hue. `oklch(95% 0.01 60)` not `#f5f5f5`. Dead grays have no personality.
- MUST use the 60-30-10 rule: 60% neutrals, 30% secondary, 10% accent.
- MUST limit accent palette to 1 primary + 1 secondary max. More = visual noise.
- SHOULD use OKLCH for color definitions — perceptually uniform (equal lightness steps look equal, unlike HSL).
- SHOULD reduce chroma as colors approach white or black. High chroma at extreme lightness looks garish.
- NEVER use pure black (`#000`) or pure white (`#fff`) for large areas. Tint everything.
- NEVER put gray text on colored backgrounds. Use a darker shade of the background color.
- NEVER use purple-to-blue gradients, neon accents, or cyan-on-dark palettes unless the brand specifically requires it.
- NEVER use inline `oklch(...)` in Tailwind class names (e.g., `bg-[oklch(...)]`). Define oklch values in CSS tokens only.

## Dark Mode

Dark mode is NOT inverted light mode:
- No shadows for depth — use lighter surfaces instead
- Desaturate accent colors slightly
- Reduce font weight slightly (350 instead of 400 for body)
- Never use pure black background
- Swap the semantic token layer, not the component layer
