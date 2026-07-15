# Color — OKLCH Depth, Gamut, Contrast, Dark Mode

OKLCH is perceptually uniform: equal L steps read as equal brightness, and L, C, H are independent coordinates — changing one does not shift the others. The maximum *displayable* chroma still varies with L and H (that's the sRGB/P3 gamut, not the color model). The derivation procedure — name→hue formula, 12-stop lightness spine, companion neutral, semantic token mapping, WCAG floors — lives in the SKILL.md color kernel; this file owns the depth behind it.

## Syntax & formatting

```
oklch(L C H)          oklch(L C H / alpha)
```

- L: 0–1. C: 0–~0.4 (0 = gray; displayable max depends on L and H). H: 0–360.
- Format L and C to 3 decimals, H to ≤3 decimals. Drop trailing zeros. Alpha uses slash syntax, never commas.
- Define ALL oklch values in `:root` as CSS custom properties. Never inline `oklch()` in component rules, box-shadow, outline, or utility classes — always `var(--token)`.
- When converting hex/rgb/hsl → oklch, convert only values you own. Leave `currentColor`, `inherit`, `transparent`, and third-party hex-only config untouched.

## Chroma strategy

The spine's bell curve is the shape; the strategy scales its amplitude:

| Strategy | Multiplier |
|---|---|
| Restrained | ×0.6 |
| Committed | ×1.0 |
| Full palette | ×1.2 |
| Drenched | ×1.4 |

Hue is held constant through the whole procedure — >10° drift across stops reads as a broken palette. After scaling, re-clamp every stop against the gamut (below): ×1.2–1.4 will exceed sRGB for many hues, and the clamp must win.

## Companion scales

- **Neutral** (kernel: H+180°, C ≤ 0.02): warm primaries get cool-tinted grays and vice versa. Primary and neutral hues differ by ≥120° or the page reads as a sepia photograph (monochrome mud).
- **Secondary:** same H as primary, chroma ×0.4 — the muted version for large surfaces.
- **Tertiary (only when genuinely needed):** H+60°, chroma ×0.5 — analogous harmony; complementary accents fight the primary in UI.

## Warm neutrals (branch)

A deliberately warm interface derives its neutral scale at a warm hue (H 40–90°) with C 0.01–0.03 — a coherent temperature-bearing scale where every surface, border, and text stop shares the temperature. That is a palette decision and passes. What fails the intent-and-repetition lens is the reflex: one `--cream`/`--paper` token dropped on `body` while everything else stays cold gray. Warmth is a system or it is slop.

## Gamut safety

- Displayable chroma varies sharply by hue: purple (H≈285) reaches C≈0.29 at L=0.5; cyan (H≈195) only C≈0.09. Hence the kernel's cap: C ≤ 0.09 for hues 170–210°.
- Gamut-map by reducing C only — preserve L (contrast lives there) and H (identity lives there).
- For multi-hue sets (status colors, categorical chart palettes), use the same *percentage of each hue's displayable max*, not the same absolute C — equal absolute C makes some hues look more vivid than others.
- P3 is an enhancement layer: sRGB-safe base value first, vivid value only inside `@media (color-gamut: p3)`.

## Contrast method

Conformance is the measured WCAG 2.x ratio (kernel floors: 4.5:1 / 3:1 / 3:1 non-text) — computed or checked in the rendered page, against the element's **actual nearest rendered background**. The most common failure: muted gray body text on a tinted near-white, and placeholder text styled lighter than 4.5:1.

- Fix failing contrast by moving L; C barely moves the ratio and H not at all.
- ΔL is a *pre-check for near-neutral pairs only* (both C < 0.05): ΔL ≥ 0.4 body / ≥ 0.3 large text usually lands near the floor. It is not conformance — chromatic pairs (colored text, colored buttons) can pass ΔL and fail the ratio. Measure.
- Lightness gap guide: on light backgrounds (bg L > 0.9), foreground L < 0.35. On dark (bg L < 0.25), foreground L > 0.9. Surface L > 0.6 → dark text; L ≤ 0.6 → light text.
- Gray text on a colored background looks washed out — use a darker shade of the background's own hue, or the text color at reduced alpha.

**APCA** is a supplementary perceptual model — useful for judging thin/light type on modern displays, not a W3C standard and not a conformance substitute. If you use it, treat |Lc| ≥ 75 body / ≥ 60 labels / ≥ 45 large as advisory targets *after* the WCAG floors pass.

## Dark mode

Derive, don't hand-pick: invert the semantic lightness mapping (neutral-950 → background, neutral-50 → foreground) rather than choosing an unrelated dark palette. Then:

- Reduce chroma moderately (~10–20%) — saturated accents vibrate on dark. Verify the reduced accents still meet the floors; re-measure, don't assume.
- Depth from lighter surfaces, not shadows — the elevation ladder inverts to tint.
- Reduce font weight (350) only when the loaded font actually provides it — a synthesized 350 is worse than 400.
- Never pure black background; never pure white text.
- Swap the semantic token layer, not components — if dark mode requires editing a component, the token layer failed.
