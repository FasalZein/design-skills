# Typography — Fonts, Loading, Wrapping, Detail

Good typography is mostly restraint: a sensible scale, comfortable spacing, and enough contrast beat any clever effect. Tracking, line-height, case, and numeral rules live in the SKILL.md type kernel; this file owns fonts as engineering and text as detail.

## Choosing & sourcing

- Verify before committing: the font has a real source (Google Fonts, Fontshare, a licensed foundry, or a package like `@fontsource/*` / `geist`), a license that covers the use, and the weights you need. A font you cannot actually load is not a choice.
- System font stacks are a valid design decision — the default for brownfield UI that already uses them, and for performance-first product UI where a webfont buys little: `ui-sans-serif, system-ui, sans-serif` (+ `ui-serif`/`ui-monospace` axes). Choose them deliberately, not as a fallback for skipping the decision.
- Pair fonts on a contrast axis (serif + sans, geometric + humanist) or use one family in multiple weights. Two similar-but-not-identical sans-serifs read as a mistake.

## Loading

- Serve `.woff2`. `.woff` only as legacy fallback. Never ship raw `.ttf`/`.otf`.
- `font-display` is a decision, not a constant: `optional` for app UI where the metric-matched fallback is acceptable and layout shift is worse than a session in fallback; `swap` when brand type must appear even if late (marketing); `block` only when rendering in fallback is unacceptable (icon fonts, logotypes).
- Kill fallback layout shift with metric overrides on the `@font-face` fallback:

```css
@font-face {
  font-family: "Brand-fallback";
  src: local("Arial");
  size-adjust: 105%; ascent-override: 92%; descent-override: 24%; line-gap-override: 0%;
}
```

Frameworks automate this (`next/font`, Fontaine) — use the automation when available.

- Set `font-synthesis: none` on the root and load every weight/italic you use — a browser-faked bold should fail visibly, not render silently.
- Static files for 1–2 weights; a variable font pays off around three weights or when you need optical sizing or custom axes. `font-optical-sizing: auto` only when the font has a designed `opsz` axis.
- Use CSS properties over raw tags: `font-weight: 650` not `font-variation-settings: "wght" 650`; `font-variant-numeric: tabular-nums` not `font-feature-settings: "tnum" 1`. Properties keep working when a non-variable fallback renders. Raw tags only for custom axes (`"GRAD" 80`) and features with no property (`"ss01" 1`).
- Sizes in `rem`/`em`, not `px`. `-webkit-font-smoothing: antialiased` + `-moz-osx-font-smoothing: grayscale` once on the root, never scattered per component.

## Scale mechanics

- Heading levels come from the document outline; size comes from CSS. Map each level to a descending scale step — a lower level never renders larger than a higher one.
- **Display size ceiling: clamp() max ≤ 6rem (~96px)** — the kernel's hero rule; above it the page is shouting unless scale itself is the declared feature.
- Size floors: body 16px; UI text 14px; captions 13px; below 12px is exceptional.
- Fluid type (`clamp()`) for marketing/content pages; fixed sizes for app UI.

## Wrapping & measure

- Cap long-form measure at 60–75 characters (`max-w-[65ch]`, `max-w-prose`). Recheck when body size changes.
- `text-wrap: balance` on headings; `text-wrap: pretty` on short descriptions. Neither on long-form paragraphs — browsers ignore `balance` past a few lines.
- `overflow-wrap: break-word` wherever long words, URLs, or IDs could escape the container. `white-space: nowrap` on labels and badges where a mid-label break looks broken.
- Truncation hides content: single line = `truncate`, multi-line = `line-clamp-*`, and if the hidden text matters, keep the full value reachable (tooltip, expanded view, detail page). Truncate descriptions, never numbers or IDs.
- Smart punctuation: curly quotes in prose (straight in code), en dash for ranges (`2010–2020`), em dash for asides, the single ellipsis character, `&nbsp;` to bind values to units (`16&nbsp;px`), `&shy;` to control long-word breaks.

## Icon alignment

Icons beside text align to the cap height, not the line box — line-box centering sits icons visibly low next to single-line text. Size icons relative to the text they accompany (1em–1.25em inline, larger only as standalone controls). `text-box-trim`/`text-box-edge` (cap-height trimming on badges/buttons) has shipped in Chromium and Safari; treat it as progressive enhancement while Firefox lags.

## Numerals

The kernel requires `tabular-nums` + lining figures on data. Detail: oldstyle/proportional figures are legitimate only in running prose when the face provides them; any column, price, timer, or ID stays lining+tabular. Format with `Intl.NumberFormat` / `Intl.DateTimeFormat`.

## Detail & direction

- Store copy in natural case; control presentation with `text-transform`. Redesigns must never require rewriting strings.
- Underlines from the font's own metrics: `text-underline-position: from-font`, `text-decoration-thickness: from-font`, `text-decoration-skip-ink: auto`. Dotted underline = "extra info here". If an underline animates anything beyond color, build it as a separate element.
- RTL-ready by default: logical properties (`margin-inline-start`, `ps-4`, `text-align: start`), set `lang`, and `dir="rtl"` where needed.
- Style `::selection` subtly if at all. `user-select: none` on button labels in native-feel UI; keep selection on content worth copying.

## CJK & multi-script

When the product serves Chinese, Japanese, or Korean users:

- Per-language stacks selected by `lang` attribute — platform stacks (`"PingFang SC"`, `"Hiragino Sans"`, `"Noto Sans JP"`, `"Apple SD Gothic Neo"`) over webfonts; CJK webfonts are megabytes unless subset.
- Latin tracking values do not apply — CJK glyphs are full-width; leave tracking at 0 and rely on `text-spacing-trim`/`text-autospace` as progressive enhancements for punctuation rhythm.
- Measure: ~40 CJK glyphs per line (≈ the 65ch Latin rule).
- Line height runs taller than Latin: body 1.7–1.9.
- Test wrapping with real localized strings — CJK has no word spaces; `word-break`/`line-break` defaults usually suffice, but mixed Latin-CJK lines need checking.

Paragraph and heading block rhythm: [spacing.md](spacing.md).
