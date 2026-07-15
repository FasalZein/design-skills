---
name: design-qa
description: Binary pass/fail quality gates for UI code — run before shipping any component, page, or feature. Use when the user asks to QA, audit, review, or harden UI, before merging UI work, or after any design implementation to verify it. Covers anti-slop, accessibility, consistency, interaction states, performance, responsive, and live in-browser verification.
globs: ["**/*.tsx", "**/*.jsx", "**/*.ts", "**/*.js", "**/*.css", "**/*.scss", "**/*.html", "**/*.vue", "**/*.svelte", "**/*.astro", "**/*.mdx"]
---

# Design QA

Structured quality gate for UI code. Run against any component, page, or feature before shipping. Every check is binary — pass or fail. Report ONLY failures. Silence = quality.

## Scanner

```bash
bash "$PI_SKILL_DIR/scripts/design-scan.sh" <target-dir>                  # human output
bash "$PI_SKILL_DIR/scripts/design-scan.sh" <target-dir> --json           # machine output (stdout = pure JSON)
bash "$PI_SKILL_DIR/scripts/design-scan.sh" <target-dir> --critical-only  # gate only Critical findings
bash "$PI_SKILL_DIR/scripts/design-scan.sh" <target-dir> --allowlist FILE # structured exceptions
bash "$PI_SKILL_DIR/scripts/design-scan.sh" <target-dir> --allow-empty    # zero supported files is not an error
```

If `$PI_SKILL_DIR` is unset, resolve the script relative to this SKILL.md's directory.

**Dependencies:** `rg` and `jq` required in every mode. `ast-grep` optional (adds structural TSX/JSX/HTML checks).

**Support tiers:** lexical checks cover `tsx jsx ts js css scss html vue svelte astro mdx`; structural checks are TSX-only (the shipped ast-grep rule set). Symlinked files are not followed.

**Exit contract:**

| Exit | Meaning |
|---|---|
| `0` | Supported files were scanned; no finding broke the active mode |
| `1` | Scan completed; findings broke the active mode (any finding by default; Critical-only under `--critical-only`) |
| `2` | Unreliable: bad arguments, missing dependency, missing target, zero supported files (without `--allow-empty`), tool failure, or invalid JSON |

JSON schema: `status pass|fail`, `target`, `scannedFiles`, `support`, `total/critical/high/medium`, advisory `score`, `categories`, `issues[]` (each: severity, category, file, one-based line, content, fix). On scanner error with `--json`: `{"status":"error","errors":[…]}` and exit 2.

**Allowlist format** (tab-separated, `#` comments): `CATEGORY<TAB>PATH_REGEX<TAB>REASON`. Category exact or `*`. Invalid rows exit 2.

The scanner covers only mechanical facts. Scanner silence says nothing about the judgment checks below — run the gates after the scan, in order, and report failures with line numbers and fixes. Finish with Gate 12 whenever the app can be rendered — the rendered page outranks source-level passes.

---

## Gate 1: Anti-Slop (Critical)

Mechanical rows are scanner-automated; judgment rows apply the intent-and-repetition test — the treatment communicates state, hierarchy, focus, information, or brand meaning, and is bounded to a named role.

| Check | Pass Condition |
|-------|---------------|
| No slop gradients (auto) | Zero purple/violet/indigo → blue/pink/fuchsia gradient combos; zero two-stop dark neutral gradients; zero gradient text on metrics/headings; zero blurred gradient orbs |
| No dead controls (auto) | Every button/link has a real handler or destination — zero `href="#"`, empty onClick, non-persisting toggles |
| Glass is functional | `backdrop-blur` only on overlays over meaningful content, with a readable fallback — never on static cards |
| No fake proof | Zero invented counts ("Trusted by 10,000+"), logo marquees, placeholder identities ("John Doe", "Acme"), round metrics (99.99%), fake terminal/mac-window chrome |
| No template composition | Not centered-hero + identical card grid; not 3-4 equal big-number metric cards; not 3-tier pricing + "Most Popular" pill shipped verbatim; footer mirrors real IA |
| Stack is customized | shadcn/Tailwind tokens, radii, and variants customized to the product — `whitespace-nowrap` on buttons is required, the rest of a verbatim default variant string is the tell |
| No template copy | Zero: Effortlessly, Streamline, Revolutionize, Unlock, AI-powered (non-AI product), "It's not just X, it's Y", "Welcome to our platform", "Built with ❤️" — in rendered copy; identifiers don't count |
| Motion earns its place | Pulse/ping only as skeleton feedback or accessible live-status; reveals differ by content, not one fade-in-up everywhere |
| No side-stripe accents (auto) | Zero colored `border-left` bars on cards/callouts/items — tint or dot instead, never stripe + tint; `blockquote` exempt |
| Kickers are bounded | One brand kicker or micro-meta label passes; the same uppercase-tracked eyebrow repeated across 2+ sections fails; numbered markers only on real sequences |
| Radius matches role | ≥24px on cards/sections/inputs fails outside a declared soft-organic/playful direction |
| Warmth is a system | Warm neutrals pass as a coherent derived scale; a lone `--cream`/`--paper` body token fails |
| Sparklines carry data | Real history + value + period + delta; decorative squiggles fail |
| Illustration is owned | One consistent brand family in a named role; mixed stock/sketchy SVG fails |
| Combination tells | 2+ together fail: nested cards, identical icon-heading cells, ghost-cards (1px border + ≥16px-blur shadow), per-section background hues |

## Gate 2: Typography

| Check | How to Verify |
|-------|--------------|
| Project type scale only | Zero arbitrary font sizes: `text-[*px]`, `text-[*rem]`, `font-size:` outside the scale |
| Tracking within bounds | Display/heading tracking between `-0.03em` and `0`; uppercase micro-labels at most `+0.05em`; body text `0`; zero `tracking-tighter` |
| Font is loadable | Chosen font has a real source and license; `@font-face`/import resolves; stack ends in a generic family |
| Numeric data: tabular-nums | All numbers that align or update — prices, counts, dates, table columns |
| Headings: text-balance | `<h1>`–`<h6>` use `text-balance` or `text-pretty` |
| Line length controlled | Body text capped at 45–75ch (`max-w-prose` or equivalent); CJK content ~40 glyphs with `lang` set |
| Max 3 font weights | More than 3 distinct weights per view = flag |
| Web fonts are woff2 | Owned font assets `.woff2`; `font-synthesis: none`; every used weight has a loaded file |
| Mobile inputs ≥ 16px | Input text ≥16px on mobile; zoom never disabled to compensate |

## Gate 3: Color

| Check | How to Verify |
|-------|--------------|
| No hardcoded colors | Zero hex/`rgb(`/`hsl(`/`oklch(` in component markup; OKLCH lives in `:root` tokens |
| No pure black/white surfaces | `bg-black`, `bg-white`, `#000`, `#fff` on containers/pages = flag |
| No gray on colored bg | `text-gray-*`/`text-muted-*` on colored backgrounds = flag |
| Status colors semantic | green=success, red=error, amber=warning, blue=info — never inverted, never the brand accent |
| Color never sole indicator | Every status pairs with icon, text, or pattern |
| Contrast floors (WCAG 2.x) | ≥4.5:1 body, ≥3:1 large text, ≥3:1 required non-text UI (input borders, meaningful icons, focus rings) — against the actual rendered background, placeholders included. APCA is advisory only, never the pass condition |
| Accents match declared strategy | Restrained/Committed: ≤2 accent colors per view. Full-palette and categorical data-viz: every hue maps to a named role — unnamed extras fail |

## Gate 4: Spacing

| Check | How to Verify |
|-------|--------------|
| 4px grid | All spacing multiples of 4px; zero `p-[*]`/`m-[*]`/`gap-[*]` magic values |
| Hierarchy reads | Section gaps > group gaps > item gaps; consistent within the page |
| Inset ≠ stack monotony | Repeated surfaces distinguish padding-inside from gap-between; not one value everywhere |
| Density consistent | One density mode per surface; grouped controls share heights |
| Block rhythm | Headings bind to what follows (space above > below); labels sit 4–8px from their inputs |
| No triple responsive padding | `p-2 md:p-4 lg:p-6 xl:p-8` = flag; one value per semantic context |
| No dead air | At 1440px: zero empty bands >64px (app/data) / >128px (marketing) within one surface; zero bands >256px anywhere; height from content, not `min-height` + centering |
| Empty states top-anchored | Inside a data region the message sits where the first row would; region collapses to message height |
| Section origin aligned | Heading and its section controls share a baseline; adjacent columns start at the same y |

## Gate 5: Component Reuse

| Check | How to Verify |
|-------|--------------|
| Existing primitives used | Custom `<button>`/`<input>`/`<dialog>` when project equivalents exist = flag |
| No primitive mixing | Imports from multiple UI libraries in same file = flag |
| CVA for variants | Inline ternary chains for 3+ style variants = flag |
| data-slot attributes | Component roots missing `data-slot` = flag (if project convention) |

## Gate 6: Interaction States

| Check | How to Verify |
|-------|--------------|
| Five states present | Every interactive element: default, hover (`@media (hover: hover)`), focus-visible ring (never removed), active, disabled |
| Async lifecycle | Every async action: pending disables re-activation + shows status (`aria-busy`); success/error visible where the action happened |
| Icon-only: aria-label | Every icon-only control |
| Destructive matches reversibility | Reversible → immediate + undo; irreversible/high-stakes → explicit confirmation naming object and scale |
| Errors inline | Adjacent to the trigger, not only in a toast/banner |
| Focus managed | Dialogs set initial focus and restore focus to opener on close |
| aria-expanded | Accordion/collapsible triggers have `aria-expanded` + `aria-controls` |
| Hit areas don't collide | Expanded targets of adjacent controls never overlap |
| Paste not blocked | No `onPaste` prevention |

## Gate 7: Accessibility

| Check | How to Verify |
|-------|--------------|
| Semantic HTML | `<button>` for actions, `<a>` for nav; no `<div onClick>` |
| Heading hierarchy | h1→h2→h3, no skipping, one h1 per page |
| Alt text | Every `<img>` has `alt`; decorative `alt=""` |
| Form labels | Every input has a visible `<label>`, not just placeholder |
| Keyboard nav | Logical tab order, no traps, no `tabIndex > 0` |
| ARIA live regions | Dynamic updates use `aria-live="polite"`/`role="status"` |
| Touch targets | ≥44px mobile primary controls (24px WCAG AA absolute floor) |
| prefers-reduced-motion | All motion >200ms has a reduced path |
| h-dvh not h-screen | Zero `h-screen` |

## Gate 8: Product States & Edge Cases

| Check | How to Verify |
|-------|--------------|
| Four-state contract | Every async data surface designs loading, populated, empty, error |
| Empty states typed | First-use / cleared / no-results / error-caused get distinct copy; next-action CTA present when a real action exists |
| Error recovery | Every error names what happened + how to recover; retry path present |
| Conditional states | Permission-denied, offline, stale/partial designed where reachable |
| Long text handled | `truncate`/`line-clamp-*`/`break-words` on names/titles; truncated material reachable in full |
| Flex/grid overflow | `min-w-0` on flex children with text; `min-w-0 min-h-0` on grid children |
| Formatting | `Intl.NumberFormat`/`Intl.DateTimeFormat`, never concatenation |
| Skeletons match layout | Shapes mirror actual content and reserve its space |
| Data extremes | Survives 0, 1, 1000+ items; 100+ char strings; emoji; RTL |

## Gate 9: Performance

| Check | How to Verify |
|-------|--------------|
| No layout animations | Zero `animate-*`/`transition-*` on width/height/top/left/margin/padding |
| No permanent will-change | Only within animation scope |
| No animated blur | No `backdrop-blur` + transition/animate together |
| Images lazy + reserved | Below-fold `loading="lazy"`; async content has reserved space (zero shift) |
| Lists virtualized | 100+ items |
| Inputs debounced | Search/filter 200–300ms |
| Cleanup on unmount | Effects cancel subscriptions, abort fetches |
| No mount animation on defaults | Default-state `AnimatePresence initial={false}` (deliberate first-load entrances exempt) |
| Content visible without JS animation | Visibility never depends on a class-triggered transition (ships blank in hidden tabs/headless) |
| Hidden-tab timers pause | Timed toasts/auto-dismiss pause while document hidden |
| No console.log | Zero non-dev-gated console output |

## Gate 10: Responsive

| Check | How to Verify |
|-------|--------------|
| Mobile layout works | No horizontal scroll; content reflows |
| No hidden core features | `hidden md:block` on essential functionality = flag |
| Logical CSS properties | `margin-inline-*`/`ps-*` for RTL support |
| No fixed widths on text | `w-24`/`w-[200px]` on text containers = flag |
| Zoom not disabled | No `user-scalable=no`/`maximum-scale=1` |
| Safe areas | Fixed/sticky mobile elements pad with `env(safe-area-inset-*)` |

## Gate 11: Error Resilience

| Check | How to Verify |
|-------|--------------|
| API errors by code | 401→login, 403→permission, 404→not found, 429→rate limit, 500→error surface |
| Error boundaries | Around major sections |
| Optimistic rollback | Failed optimistic updates revert visibly + show error |
| Offline/stale honest | Offline states say what still works; stale data is timestamped |

## Gate 12: Live Verification (agent-browser)

Static gates read source; this gate checks the **rendered page**.

**Prerequisites:** a dev/preview command exists (or a URL is supplied) and `agent-browser` responds. Both present → the gate is mandatory. Either missing → record `Gate 12: N-A — <which prerequisite is missing and why>`. N-A is never a pass; a state that should exist but cannot be exposed is a failing state check.

**Viewports:** 375×812 and 1440×900 always; 768×1024 when the layout has a tablet breakpoint.

**States:** loaded (both required viewports) — then empty, loading, error, long-content, interactive states at one representative viewport each; dark mode and reduced-motion when supported. Repeat a state at a second viewport only when responsive behavior could change its verdict.

**Machine probes (binary):** console/page/network errors = 0 · no horizontal overflow at 375px · one h1, ordered headings in the accessibility snapshot · rendered contrast meets Gate 3 floors · focus ring visible on every interactive element in a tab cycle · primary targets ≥44px at 375px · no dead-air bands (Gate 4 limits) at 1440px · reduced-motion emulation removes positional animation · no blank sections.

**Screenshot review (judgment):** overlap, hierarchy, truncation recovery, empty-state usefulness, dark-mode quality, visible anti-slop regressions — against Gate 1.

Exact commands, probe JavaScript, and evidence schema: **READ [reference/live-verification.md](reference/live-verification.md)** before running this gate.

**Complete when** every required state × viewport has a screenshot + console/error capture recorded, **every machine probe is listed in the report with its measured result** (a probe not listed was not run — the gate is incomplete), all probes pass, and no Critical visual finding remains. Attach screenshot paths and repro steps for every finding. A failure here outranks any static-gate pass — the rendered page is the product.

---

## Report Format

```markdown
## QA Report: [Component/Page Name]

### Critical (must fix before merge)
- **[Gate]: [Check]** — [File:Line] — [Issue and fix]

### High (fix soon)
- **[Gate]: [Check]** — [File:Line] — [Issue and fix]

### Medium (improve when touching this code)
- **[Gate]: [Check]** — [File:Line] — [Issue and fix]
```

**Severity:** Critical = accessibility blockers, dead controls, Gate 1 hard guardrails, Gate 12 machine-probe failures, blank/broken render. High = hardcoded colors, missing required states or recovery, spacing/type system violations, missing loading/rollback. Medium = contextual craft issues and non-blocking polish.

## Quick-Check (6 items for fast PR reviews)

1. No anti-slop patterns (Gate 1)
2. No hardcoded colors (Gate 3)
3. Focus visible on all interactives (Gate 6)
4. Four-state contract on async surfaces (Gate 8)
5. No layout animations (Gate 9)
6. Renders clean at 1440px + 375px with zero console errors (Gate 12; N-A per its rule when no renderable target exists)
