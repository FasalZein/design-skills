#!/usr/bin/env bash
# Repository verify: scanner syntax + contract tests + skill consistency. Exit 0 = green.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
FAIL=0
say() { echo "verify: $*"; }
bad() { FAIL=$((FAIL+1)); echo "verify FAIL: $*"; }

# 1. Scanner shell syntax
bash -n "$ROOT/design-qa/scripts/design-scan.sh" && say "scanner syntax ok" || bad "scanner syntax error"

# 2. Scanner contract tests
if bash "$ROOT/design-qa/tests/run-tests.sh" >/dev/null 2>&1; then say "scanner contract tests pass"; else
  bad "scanner contract tests failing"; bash "$ROOT/design-qa/tests/run-tests.sh" | tail -20; fi

# 3. Every relative markdown link in skill files resolves
for f in "$ROOT"/*/SKILL.md "$ROOT"/*/reference/*.md; do
  [ -f "$f" ] || continue
  dir=$(dirname "$f")
  for link in $(grep -oE '\]\((\./)?(reference/|scripts/)?[A-Za-z0-9._-]+\.md\)' "$f" | sed 's/^](//; s/)$//'); do
    [ -f "$dir/$link" ] || bad "broken link in ${f#$ROOT/} -> $link"
  done
done
say "markdown links checked"

# 3b. build-design-library: every relative link and #anchor across SKILL.md, references/, templates/ resolves
slug() { tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 -]//g; s/ /-/g'; }
for f in "$ROOT"/build-design-library/SKILL.md "$ROOT"/build-design-library/references/*.md "$ROOT"/build-design-library/templates/*.md; do
  dir=$(dirname "$f")
  for ref in $(grep -oE '\]\([^)#[:space:]]*(#[A-Za-z0-9-]+)?\)' "$f" | sed 's/^](//; s/)$//' | grep -v '^http'); do
    path=${ref%%#*}; anchor=${ref#*#}; [ "$anchor" = "$ref" ] && anchor=""
    target="$dir/$path"; [ -z "$path" ] && target="$f"
    [ -f "$target" ] || { bad "broken link in ${f#$ROOT/} -> $ref"; continue; }
    [ -z "$anchor" ] && continue
    grep -E '^#+ ' "$target" | sed -E 's/^#+ //' | slug | grep -qx "$anchor" || bad "missing anchor in ${f#$ROOT/} -> $ref"
  done
done
say "build-design-library links and anchors checked"

# 4. No harness-generated blocks committed
grep -rl 'skill_context' "$ROOT"/*/SKILL.md >/dev/null 2>&1 && bad "skill_context block committed in a SKILL.md" || say "no skill_context blocks"

# 5. Single tracking authority: floor is -0.03em, no competing -0.04em floor
grep -rn -- '-0\.04em' "$ROOT"/*/SKILL.md "$ROOT"/*/reference/*.md >/dev/null 2>&1 && bad "competing -0.04em tracking floor found" || say "tracking floor single-sourced"

# 6. Removed decisions stay removed
grep -rn 'JetBrains Sans' "$ROOT" --include='*.md' >/dev/null 2>&1 && bad "JetBrains Sans reference resurfaced" || say "font availability rule holds"
grep -n 'MUST use .AlertDialog' "$ROOT/design-qa/SKILL.md" >/dev/null 2>&1 && bad "AlertDialog mandate resurfaced" || true

# 7. laws-of-ux stands alone (no cross-skill file pointers; skill-name mention in frontmatter description is fine)
grep -nE '(design-craft|design-qa)/|reference/[a-z-]+\.md' "$ROOT/laws-of-ux/SKILL.md" >/dev/null 2>&1 && bad "laws-of-ux points into another skill's files" || say "laws-of-ux is self-contained"

# 8. Gate count consistency: derive from design-qa, compare against every README claim
GATES=$(grep -oE '^## Gate [0-9]+' "$ROOT/design-qa/SKILL.md" | awk '{print $3}' | sort -n | tail -1)
[ -n "$GATES" ] || bad "could not derive gate count from design-qa/SKILL.md"
CLAIMS=$(grep -oE '[0-9]+(-gate| gates)' "$ROOT/README.md" | grep -oE '^[0-9]+' | sort -u)
for c in $CLAIMS; do [ "$c" = "$GATES" ] || bad "README claims $c gates; design-qa defines $GATES"; done
say "gate count consistent ($GATES gates)"

# 8b. Gate 12 viewport constants match between SKILL and runbook
for vp in '375' '1440'; do
  grep -q "$vp" "$ROOT/design-qa/SKILL.md" || bad "viewport $vp missing from design-qa/SKILL.md"
  grep -q "$vp" "$ROOT/design-qa/reference/live-verification.md" || bad "viewport $vp missing from live-verification.md"
done
say "viewport constants consistent"

# 8c. Dead-air band numbers agree across kernel, Gate 4, and the Gate 12 probe
grep -q '≤64px app/data, ≤128px marketing' "$ROOT/design-craft/reference/app-ui.md" || bad "kernel band limits changed — update Gate 4 + probe together"
grep -q '>64px (app/data) / >128px (marketing)' "$ROOT/design-qa/SKILL.md" || bad "Gate 4 band limits drifted from kernel (64/128)"
grep -q 'marketing ? 256 : 128' "$ROOT/design-qa/reference/live-verification.md" || bad "probe FAIL tier drifted (expect 256/128)"
grep -q 'marketing ? 128 : 64' "$ROOT/design-qa/reference/live-verification.md" || bad "probe JUDGE tier drifted (expect 128/64)"
grep -rn '64/96px' "$ROOT"/*/SKILL.md "$ROOT"/*/reference/*.md >/dev/null 2>&1 && bad "stale 64/96px band value resurfaced" || say "dead-air numbers consistent"

# 9. design-craft kernels present in the app-UI rules file (color formula + spine, tracking table)
APP_UI="$ROOT/design-craft/reference/app-ui.md"
grep -q '137' "$APP_UI" || bad "color hue formula missing from kernel"
grep -q '0.99, 0.96, 0.90' "$APP_UI" || bad "lightness spine missing from kernel"
grep -q -- '-0.02em' "$APP_UI" || bad "tracking table missing from kernel"
grep -q '](reference/app-ui.md)' "$ROOT/design-craft/SKILL.md" || bad "design-craft router does not point to reference/app-ui.md"
say "kernels in design-craft/reference/app-ui.md"

# 10. No backticked slash tokens in design-craft. pi-better-skills injects every skill a loaded body
# names as a backticked /name or /skill:name token, transitively. Name skills as plain words.
# Pattern mirrors pi-better-skills SKILL_REF_PATTERN (src/skill-refs.ts).
SLASH_TOKENS=$(grep -nE '`/(skill:)?[A-Za-z0-9][A-Za-z0-9._-]*`' "$ROOT/design-craft/SKILL.md" "$ROOT"/design-craft/reference/*.md)
if [ -n "$SLASH_TOKENS" ]; then bad "backticked slash token in design-craft (injects skills transitively):"; echo "$SLASH_TOKENS"
else say "no backticked slash tokens in design-craft"; fi

# 11. Every SKILL.md path in the design-craft Skill map exists on this machine (installed skills).
MAP_PATHS=$(awk '/^## Skill map/{f=1;next} f&&/^## /{exit} f' "$ROOT/design-craft/SKILL.md" | grep -oE '~/[^ |]+/SKILL\.md')
[ -n "$MAP_PATHS" ] || bad "design-craft Skill map has no SKILL.md paths"
for p in $MAP_PATHS; do [ -f "$HOME/${p#\~/}" ] || bad "Skill map path missing: $p"; done
say "skill map paths checked ($(echo "$MAP_PATHS" | wc -l | tr -d ' '))"

echo "----"
if [ "$FAIL" -eq 0 ]; then echo "verify: GREEN"; exit 0; else echo "verify: $FAIL failure(s)"; exit 1; fi
