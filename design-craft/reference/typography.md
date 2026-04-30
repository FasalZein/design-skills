# Typography

## Rules

- MUST choose a font with intention. For creative/brand work, NEVER default to Inter, Roboto, Arial, Open Sans, or Montserrat. Good alternatives: DM Sans, Instrument Sans, Plus Jakarta Sans, Geist, Outfit, Sora.
- MUST define a type scale with clear hierarchy. 5 levels cover most needs: Display, Heading, Body, Caption, Micro. Fewer sizes with more contrast > many sizes close together.
- MUST use `tabular-nums` (`font-variant-numeric: tabular-nums`) on all numeric data — prices, counts, dates, IDs, table columns.
- MUST use `text-balance` on headings. SHOULD use `text-pretty` on body paragraphs.
- MUST keep body text line length at 45–75 characters (`max-w-prose` or `max-w-[65ch]`).
- MUST set line-height: 1.5 for body, 1.2–1.3 for headings, 1.0–1.1 for large display.
- SHOULD use one font family in multiple weights. Only add a second font for genuine contrast (display + body).
- SHOULD use fluid typography with `clamp()` for marketing/content pages. Fixed sizes for app UI.
- MUST use `font-display: swap` on custom fonts. NEVER leave users staring at invisible text (FOIT).
- MUST use `rem`/`em` for body text, not `px` — respects user browser font size settings.
- MUST use `tracking-tight` or `tracking-tighter` on large display text (text-3xl and above). Large text has visually loose letter-spacing by default — tightening is standard typographic practice, not a modification.
- NEVER add positive letter-spacing (`tracking-wide`, `tracking-wider`) unless explicitly requested. LLMs love adding tracking; it almost always makes things worse.
- NEVER use monospace fonts for display/hero headings. Monospace has fixed-width characters that create uneven visual spacing at large sizes. Use monospace only for code, technical labels, and small metadata.
- MUST default to sentence case for all headings, labels, tabs, and buttons. Reserve ALL CAPS for micro-meta only (timestamps, status badges, overline labels ≤3 words). Title Case is almost never correct — it signals AI-generated copy.
- NEVER use more than 3 font weights on a single view.
- NEVER disable zoom (`user-scalable=no`, `maximum-scale=1`) — WCAG violation.
- Apply `-webkit-font-smoothing: antialiased` to the root layout on macOS for crisper text.

## Anti-Pattern

```
BAD:  text-[13px], text-[15px], text-[17px]  → too many sizes, too close together
GOOD: text-xs (12), text-sm (14), text-base (16), text-xl (20)  → clear jumps
```
