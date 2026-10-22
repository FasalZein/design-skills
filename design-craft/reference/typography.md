# Typography — Fallback Metrics and CJK

Sourcing, loading, scale, wrapping, numerals, and detail: better-typography. Tracking and font synthesis: the Type section in [app-ui.md](app-ui.md). This file keeps what better-typography does not carry.

## Fallback metrics

Kill fallback layout shift with metric overrides on the `@font-face` fallback:

```css
@font-face {
  font-family: "Brand-fallback";
  src: local("Arial");
  size-adjust: 105%; ascent-override: 92%; descent-override: 24%; line-gap-override: 0%;
}
```

Frameworks automate this (`next/font`, Fontaine) — use the automation when available.

## CJK & multi-script

When the product serves Chinese, Japanese, or Korean users:

- Per-language stacks selected by `lang` attribute — platform stacks (`"PingFang SC"`, `"Hiragino Sans"`, `"Noto Sans JP"`, `"Apple SD Gothic Neo"`) over webfonts; CJK webfonts are megabytes unless subset.
- Latin tracking values do not apply — CJK glyphs are full-width; leave tracking at 0 and rely on `text-spacing-trim` and `text-autospace` as progressive enhancements for punctuation rhythm.
- Measure: ~40 CJK glyphs per line (≈ the 65ch Latin rule).
- Line height runs taller than Latin: body 1.7–1.9.
- Test wrapping with real localized strings — CJK has no word spaces; `word-break` and `line-break` defaults usually suffice, but mixed Latin-CJK lines need checking.

Paragraph and heading block rhythm: [spacing.md](spacing.md).
