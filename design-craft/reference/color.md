# Color — OKLCH Palette Derivation & Contrast

OKLCH is perceptually uniform: equal L steps = equal brightness, hue stays stable across lightness, chroma is independent of lightness. Every palette in this system is derived, never hand-picked.

## Syntax & Formatting

```
oklch(L C H)          oklch(L C H / alpha)
```

- L: 0–1 (0 = black, 1 = white). C: 0–~0.4 (0 = gray; max depends on L and H). H: 0–360.
- Format L and C to 3 decimals, H to ≤3 decimals. Drop trailing zeros. Alpha uses slash syntax, never commas.
- Define ALL oklch values in `:root` as CSS custom properties. NEVER inline `oklch()` in component rules, box-shadow, outline, or Tailwind classes — always `var(--token)`.
- When converting hex/rgb/hsl → oklch, convert only values you own. Leave `currentColor`, `inherit`, `transparent`, and third-party hex-only config untouched.

## Palette Generation — OKLCH Lightness Spine

Any hue in, correct palette out. No color lookup tables, no domain→color mapping.

**Step 1 — Derive hue from product name (deterministic, bias-free):**
Take the first two letters of the product name (case-insensitive, a=0, b=1, ..., z=25):
`Hue = (firstLetter × 137 + secondLetter × 47) mod 360`
This removes model color bias — different names always produce different hues. If no product name exists in the prompt, name the product first, then derive. Never skip the formula and "choose" a hue — that reintroduces the amber/slate bias every model has, and never override it with a "more appropriate" category color (healthcare ≠ teal, crypto ≠ neon).

BROWNFIELD: Extract hue from the existing `--primary` token instead of computing from name.

**Step 2 — Walk the lightness spine:**
Fixed 12-stop OKLCH ladder. Chroma follows a bell curve — low at the extremes, peaking at mid-lightness. Hue stays constant (>10° drift across stops = broken palette).

| Stop | L | C (bell curve) | Role |
|------|------|------|------|
| 50 | 0.99 | 0.01 | Tinted background |
| 100 | 0.96 | 0.02 | Subtle surface |
| 200 | 0.90 | 0.04 | Hover surface |
| 300 | 0.82 | 0.07 | UI border light |
| 400 | 0.71 | 0.10 | UI border strong |
| 500 | 0.64 | 0.13 | Secondary text |
| 600 | 0.55 | 0.15 | **Primary fill** (peak chroma) |
| 700 | 0.49 | 0.14 | Primary fill hover |
| 800 | 0.40 | 0.11 | Strong accent |
| 900 | 0.32 | 0.08 | Heading text |
| 950 | 0.27 | 0.05 | Body text |
| 1000 | 0.24 | 0.03 | High-contrast text |

Scale chroma by strategy: Restrained ×0.6, Committed ×1.0, Full palette ×1.2, Drenched ×1.4. The shape stays — only amplitude changes.

**Step 3 — Derive companion scales:**
- **Neutral:** H + 180° (opposite hue), chroma ≈ 0.01 at all stops. Neutrals must NOT share the primary hue — a warm primary (H=55) gets cool-tinted grays (H=235), a cool primary (H=220) gets warm-tinted grays (H=40). Primary and neutral hues MUST differ by ≥120° or the page reads as a sepia photograph (monochrome mud).
- **Secondary:** Same H, chroma ×0.4. Muted version of primary for large surfaces.
- **Tertiary (if needed):** H + 60°, chroma ×0.5. Analogous harmony — never complementary for UI.

**Step 4 — Map semantic tokens from spine stops:**
- From **neutral** scale: `--background: neutral-50`, `--card: neutral-100`, `--border: neutral-300`, `--muted-foreground: neutral-500`, `--foreground: neutral-950`
- From **primary** scale: `--primary: primary-600`, `--primary-hover: primary-700`, `--accent: primary-100`, `--ring: primary-400`

## Gamut Safety

- Max chroma varies by hue: purple (H~285) reaches C≈0.29 at L=0.5; cyan (H~195) only C≈0.09. For hues in the 170–210 range, cap peak chroma at 0.09.
- Clamp out-of-gamut colors by reducing C only — preserve L and H.
- For multi-hue palettes (e.g., status colors), use the same *percentage of each hue's max chroma*, not the same absolute C — equal absolute C makes some hues look more vivid than others.
- P3 colors need an sRGB-safe base value first; add the vivid value only inside `@media (color-gamut: p3)`.

## Contrast

Contrast is controlled by L distance alone — adjusting C has negligible effect. To fix failing contrast, move the L channel and keep C/H.

| Threshold | Value |
|-----------|-------|
| WCAG AA (conformance floor) | ≥ 4.5:1 body, ≥ 3:1 large text (~24px+) |
| APCA body text | \|Lc\| ≥ 75 (prefer 90) |
| APCA labels/non-body | \|Lc\| ≥ 60 |
| APCA large text | \|Lc\| ≥ 45 |
| APCA UI components | \|Lc\| ≥ 30 |
| Quick OKLCH check | ΔL ≥ 0.4 body, ≥ 0.3 large text |

- Check contrast against the element's **actual nearest rendered background**, not the page background. The most common failure: muted gray body text on a tinted near-white. Placeholder text needs the same 4.5:1 as body — the muted-gray default fails.
- Lightness gap guide: on light backgrounds (bg L > 0.9), foreground L < 0.35. On dark backgrounds (bg L < 0.25), foreground L > 0.9.
- L > 0.6 = light surface → dark text; L ≤ 0.6 → light text.
- Gray text on a colored background looks washed out — use a darker shade of the background's own hue, or the text color at reduced alpha.

## Dark Mode

Derive, don't hand-pick: invert the semantic lightness mapping (neutral-950 → background, neutral-50 → foreground) rather than choosing an unrelated dark palette. Then:

- Reduce chroma ~20% (saturated accents vibrate on dark).
- No shadows for depth — use lighter surfaces instead.
- Reduce font weight (350 instead of 400) — light-on-dark renders heavier.
- Never pure black background.
- Swap the semantic token layer, not the component layer.
