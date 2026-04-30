---
name: design-web
description: Website and landing-page design rules for AI agents. Distinctive heroes, conversion-aware sections, expressive typography, purposeful scroll motion, and anti-slop constraints for marketing surfaces.
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.svelte", "**/*.html", "**/*.css", "**/*.scss"]
---

# Design Web

Use this for websites, landing pages, changelog pages, marketing surfaces, product launches, docs homepages, and open-source homepages.

This skill exists because app UI rules are not enough for web marketing work. Website design needs stronger hero composition, clearer conversion hierarchy, more expressive typography, and richer scroll rhythm — without falling into AI-template slop.

## Stack Assumption

Default to **Tailwind + shadcn-native composition**.

- Use Tailwind utility classes for layout, spacing, typography, and responsive behavior.
- Use shadcn components or primitives as the base layer when the project has them.
- Customize shadcn composition, hierarchy, spacing, and section rhythm so the page does **not** look like a stock shadcn demo.
- Treat shadcn as substrate, not visual identity.
- Prefer class-based styling over large inline style objects unless the project explicitly requires otherwise.
- Use inline `style` only for small CSS variable wiring or truly exceptional one-off values; the page should not be implemented primarily as JS style objects.

---

## 1. The Goal

A strong website should:
- communicate value in the first viewport
- feel intentionally branded, not templated
- guide attention toward one primary CTA
- earn trust with proof, clarity, and hierarchy
- stay responsive and readable on mobile

If the page looks like "generic SaaS landing page #847," it failed.

---

## 2. Anti-Slop Rules (Read First)

### Never default to these
- purple-to-blue gradient hero
- gradient text on main headings
- glass cards everywhere
- three identical feature cards with icon + heading + paragraph
- giant centered blob illustration with no relationship to product
- "Trusted by" row with fake logos and no context
- overuse of Inter, Roboto, Arial, or system-ui as the only design choice
- identical pricing-tier cards with equal emphasis
- decorative mock browser windows used without product meaning
- dark mode neon landing page unless the brand truly demands it

### Better alternatives
- editorial asymmetry
- one dominant visual anchor plus secondary proof
- benefit-led headline with tighter copy
- mixed section rhythms instead of card repetition
- proof embedded near CTA rather than dumped in a logo graveyard
- custom shadcn compositions: bespoke section layouts, differentiated cards, tailored headers, and token-driven styling
- pricing with a clear recommended plan and differentiated information density

---

## 3. Hero Section Rules

The hero is the highest-leverage part of the page.

### Must
- lead with a specific benefit, not a vague slogan
- include exactly one primary CTA above the fold
- support the headline with a concise subhead
- include proof or trust signal near the CTA
- create a memorable composition, not just centered text over a gradient

### Should
- show the product, system, artifact, or outcome in the hero
- use asymmetry, layered composition, or strong editorial spacing
- keep copy scannable in under 5 seconds
- vary layout by brand: calm, technical, editorial, premium, playful, etc.

### Never
- stack headline + paragraph + two buttons + mockup in the same generic template every time
- put three equally weighted CTAs in the hero
- use an all-purpose headline like "Build better experiences faster"

---

## 4. Conversion Hierarchy

A website is a story with momentum.

### Recommended section order
1. Hero
2. Proof / trust / social validation
3. Product value or feature framing
4. Deeper explanation / comparison / examples
5. Pricing or CTA reinforcement
6. FAQ / objections / final CTA

### Rules
- one primary CTA per section
- each section should have one job only
- trust signals must reduce risk, not add clutter
- objections should be answered before the final CTA
- repeat CTA only when intent naturally increases

---

## 5. Typography for Web

Website typography should feel more expressive than app UI.

### Must
- choose a font with intent
- avoid defaulting to Inter/Roboto/Arial unless brand context justifies it
- use a clear display / heading / body hierarchy
- use `text-balance` or `text-pretty` on large headings
- keep body copy measure readable (`max-w-prose` or ~45–75ch)
- use fluid type with `clamp()` for large marketing headings

### Good font directions
- Geist
- DM Sans
- Instrument Sans
- Plus Jakarta Sans
- Outfit
- Sora
- Fraunces
- Newsreader

### Never
- use too many font sizes that are too close together
- use tracking tweaks by default
- mix more than 2 font families on a single page

---

## 6. Color and Theming

- Use semantic tokens or a well-defined CSS variable theme layer.
- Brand color should feel intentional, not sprayed everywhere.
- Accents should guide attention, not decorate random elements.
- Tint neutrals slightly toward the brand hue.
- Avoid pure black / pure white for large areas.
- Contrast must stay readable on mobile and in sunlight.

### For marketing pages
- one dominant accent is usually enough
- gradients are allowed only when they serve the concept and are not default AI gradient slop
- if a page is dark, the content still needs clear focal hierarchy and muted support chrome

---

## 7. Layout and Composition

### Prefer
- asymmetry with control
- varying section densities
- mix of open whitespace and tighter proof clusters
- alternating section compositions as the page scrolls
- product visuals integrated with copy hierarchy

### Avoid
- same padding everywhere
- same-width centered sections repeated top to bottom
- endless card grids
- decorative mockups disconnected from the narrative

### Distinctive composition patterns
- split hero with proof rail
- editorial hero with offset proof badges
- changelog timeline with sticky version index
- open-source homepage with live code panel + contributor proof

---

## 8. Scroll Motion

Web pages should feel alive, but motion must still be useful.

### Good motion targets
- reveal sections as they enter view
- parallax or depth on one key hero element
- directional transitions for timeline / changelog movement
- subtle number or proof counters
- sticky sections that reinforce narrative progression

### Must
- respect `prefers-reduced-motion`
- animate `transform` and `opacity`, not layout properties
- keep motion consistent with the page tone

### Never
- animate everything
- use bounce / elastic motion
- use scroll motion as decoration with no narrative value

---

## 9. Scenario-Specific Page Patterns

### SaaS landing page
- hero should show product value + proof + one primary CTA above the fold
- feature sections should vary in density and layout, not repeat identical cards
- pricing should clearly identify one recommended plan
- use explicit mobile-first wrappers: stacked hero by default, split hero at `lg:`

### Changelog page
- prefer a true timeline, release rail, or chronological structure over blog-card repetition
- version badges, dates, and summaries should scan in one pass
- directional movement should feel chronological
- include release navigation or sticky index when useful
- default to a single-column timeline on mobile, then add side metadata or sticky rails at `lg:`

### Open-source homepage
- show the artifact: code example, CLI snippet, API sample, or live component proof near the top
- pair contributor/community proof with docs or GitHub CTA
- explain why the project exists, not just what it is
- stack code and proof sections by default, then split into columns at `md:` or `lg:`

---

## 10. Common Website Section Rules

### Features
- avoid three identical cards
- vary content density and emphasis
- show outcomes, not just labels

### Testimonials / proof
- use believable proof
- keep quotes short and tied to a real benefit
- logos alone are weaker than logos + context

### Pricing
- clearly differentiate plans
- visually emphasize one recommended plan only
- comparison table should be readable and scannable
- use `tabular-nums` for pricing

### FAQ
- use clear objection-handling questions
- keep answers concise
- accordions should feel calm and readable

### Changelog / timeline
- keep directional consistency
- dates, versions, and summaries should scan quickly
- make releases feel chronological and navigable, not like blog cards

---

## 11. Mobile Rules

- the hero must still communicate value before heavy scrolling
- CTA must stay obvious on narrow screens
- type must remain readable without collapsing into giant centered blobs
- proof, pricing, timeline, and comparison content must reflow cleanly
- no hidden core CTA on mobile
- touch targets must be 44x44px minimum
- major sections must show explicit responsive structure using breakpoint classes (`sm:` / `md:` / `lg:`) or container queries
- default to single-column base layout, then add complexity at larger breakpoints
- every page shell should include visible mobile-first wrappers such as `grid-cols-1`, `md:grid-cols-*`, `lg:grid-cols-*`, stacked CTA groups that split later, or equivalent container-query changes
- changelog timelines should collapse to one rail on mobile
- open-source code/example sections should stack cleanly rather than force wide side-by-side layouts

---

## 12. Web Self-Check

Before finishing:
- [ ] Hero feels specific and non-templated
- [ ] Primary CTA is obvious
- [ ] No AI-slop gradients, glass, or template card grids
- [ ] Typography feels expressive, not default
- [ ] Scroll motion exists if useful, but is restrained
- [ ] Proof is near decision points
- [ ] Pricing / FAQ / timeline sections scan well
- [ ] Mobile layout still feels designed, not compressed
- [ ] Major sections show explicit breakpoint-aware adaptation
- [ ] Changelog and open-source pages use their native content patterns instead of generic marketing cards

---

## 13. Output Rules for Agents

When generating website code:
- do not explain the design — implement it
- do not ship raw palette classes if semantic tokens exist
- do not produce a generic centered hero as the default
- do not forget mobile behavior and reduced motion
- do not leave the hero without proof or a clear CTA
- do not fake responsiveness with desktop-only compositions and no breakpoint logic
- do not render changelog or open-source pages as generic feature-card marketing pages
- do use Tailwind classes and shadcn-native building blocks by default when available
- do customize shadcn compositions enough that the result does not look like a stock template
- do prefer responsive class-based layout over giant inline style objects
- do express mobile adaptation with visible Tailwind breakpoint logic on major sections

A good website should make someone think: "this feels like a product with taste," not "an AI made a landing page again."
