# Typography — Fonts, Scale, Wrapping, Detail

Good typography is mostly restraint: a sensible scale, comfortable spacing, and enough contrast beat any clever effect. A label, a table cell, a marketing headline, and an article paragraph do not share one set of rules.

## Font Files & Loading

- Serve `.woff2` on the web. `.woff` only as a legacy fallback. Never ship raw `.ttf`/`.otf`.
- Set `font-synthesis: none` on the root and load every weight/italic you use — a browser-faked bold should fail visibly, not render silently.
- Static files when you need 1–2 faces; a variable font when you need several weights, optical sizing, or custom axes.
- Use CSS properties over raw tags: `font-weight: 650` not `font-variation-settings: "wght" 650`; `font-optical-sizing: auto` not `"opsz"`; `font-variant-numeric: tabular-nums` not `font-feature-settings: "tnum" 1`. Properties keep working when a non-variable fallback renders. Raw tags only for custom axes (`"GRAD" 80`) and features with no property (`"ss01" 1`).
- `font-display: swap`. Sizes in `rem`/`em`, not `px`. `-webkit-font-smoothing: antialiased` + `-moz-osx-font-smoothing: grayscale` once on the root, never scattered per component.
- Pair fonts on a contrast axis (serif + sans, geometric + humanist) or use one family in multiple weights. Two similar-but-not-identical sans-serifs read as a mistake.

## Scale & Hierarchy

- Heading levels come from the document outline; size comes from CSS. Map each level to a descending scale step — a lower level never renders larger than a higher one. Never skip levels or pick an `h4` because it "looks right". One `h1` per page.
- Line-height unitless and by role: display 1.0–1.1, headings 1.2–1.3, body 1.5–1.6. Fixed values like `24px` don't scale.
- Tracking by size: slight negative (`tracking-tight`) on large display text only; slight positive only on small uppercase labels; body at reading sizes gets neither.
- **Display tracking floor: ≥ -0.04em.** Tighter and letters touch — cramped, not "designed". -0.02 to -0.03em is plenty for tight display headings.
- **Display size ceiling: clamp() max ≤ 6rem (~96px).** Above that the page is shouting.
- Size floors: body 16px; UI text 14px; captions 13px; below 12px is exceptional. Inputs ≥16px on mobile viewports (`text-base sm:text-sm`) or iOS Safari zooms the page — and never "fix" that with `maximum-scale=1`, which blocks zoom everywhere else and fails WCAG.

## Wrapping & Measure

- Cap long-form measure at 60–75 characters (`max-w-[65ch]`, `max-w-prose`, or `max-w-2xl` at 16px). Recheck when body size changes.
- `text-wrap: balance` on headings; `text-wrap: pretty` on short descriptions. Neither on long-form paragraphs — browsers ignore `balance` past a few lines, and evening out a whole paragraph wastes space.
- `overflow-wrap: break-word` wherever long words, URLs, or IDs could escape the container. `white-space: nowrap` on labels and badges where a mid-label break looks broken.
- Truncation hides content: single line = `truncate`, multi-line = `line-clamp-*`, and if the hidden text matters, keep the full value reachable (tooltip, expanded view, detail page). Never truncate numbers or IDs — truncate descriptions.
- Smart punctuation: curly quotes in prose (straight in code), en dash for ranges (`2010–2020`), em dash for asides, the single ellipsis character, `&nbsp;` to bind values to units (`16&nbsp;px`), `&shy;` to control long-word breaks.

## Numbers

`font-variant-numeric: tabular-nums` on every value that changes or aligns: prices, counters, timers, table columns, dates, IDs. Right-align numeric table columns. Format with `Intl.NumberFormat` / `Intl.DateTimeFormat`, not string concatenation.

## Detail & Direction

- Store copy in natural case; control presentation with `text-transform`. Redesigns must never require rewriting strings.
- Underlines from the font's own metrics: `text-underline-position: from-font`, `text-decoration-thickness: from-font`, `text-decoration-skip-ink: auto`. Dotted underline = "extra info here" (abbreviations, defined terms). If an underline animates anything beyond color, build it as a separate element.
- RTL-ready by default: logical properties (`margin-inline-start`, `ps-4`, `text-align: start`), set `lang`, and `dir="rtl"` where needed.
- Style `::selection` subtly if at all; keep it legible. `user-select: none` on button labels in native-feel UI; keep selection on content worth copying.
- `text-box` trim (leading trim on badges/buttons) is progressive enhancement only — browser support is limited.
