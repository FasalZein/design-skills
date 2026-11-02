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

# 3a. design-craft: every relative markdown link in every design-craft file resolves (surfaces/, ../, siblings)
DC_FILES=$(find "$ROOT/design-craft" -name '*.md' | sort)
for f in $DC_FILES; do
  dir=$(dirname "$f")
  for ref in $(grep -oE '\]\([^)#[:space:]]+\.md(#[A-Za-z0-9-]+)?\)' "$f" | sed 's/^](//; s/)$//' | grep -v '^http'); do
    [ -f "$dir/${ref%%#*}" ] || bad "broken link in ${f#$ROOT/} -> $ref"
  done
done
say "design-craft links checked ($(echo "$DC_FILES" | wc -l | tr -d ' ') files)"

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

# 5. Single tracking authority: floor is -0.03em, no competing -0.04em floor.
# design-craft states the floor in exactly one file (SKILL.md), and design-qa enforces the same value.
grep -rn -- '-0\.04em' "$ROOT"/*/SKILL.md "$ROOT"/*/reference/*.md $DC_FILES >/dev/null 2>&1 && bad "competing -0.04em tracking floor found" || say "tracking floor single-sourced"
TRACK_FILES=$(grep -l -- 'Tracking floor -0.03em' $DC_FILES)
[ "$TRACK_FILES" = "$ROOT/design-craft/SKILL.md" ] || bad "design-craft tracking floor must live in SKILL.md only (found: ${TRACK_FILES:-none})"
[ "$(grep -l -- '-0\.03em' $DC_FILES | wc -l | tr -d ' ')" = 1 ] || bad "-0.03em appears in more than one design-craft file"
grep -q -- '-0.03em' "$ROOT/design-qa/SKILL.md" || bad "design-qa no longer enforces the -0.03em floor design-craft states"

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
BAND_FILES=$(grep -l '≤64px app/data, ≤128px marketing' $DC_FILES)
[ "$BAND_FILES" = "$ROOT/design-craft/SKILL.md" ] || bad "design-craft band limits must live in SKILL.md only (found: ${BAND_FILES:-none}); update Gate 4 + probe together"
grep -q '>64px (app/data) / >128px (marketing)' "$ROOT/design-qa/SKILL.md" || bad "Gate 4 band limits drifted from kernel (64/128)"
grep -q 'marketing ? 256 : 128' "$ROOT/design-qa/reference/live-verification.md" || bad "probe FAIL tier drifted (expect 256/128)"
grep -q 'marketing ? 128 : 64' "$ROOT/design-qa/reference/live-verification.md" || bad "probe JUDGE tier drifted (expect 128/64)"
grep -rn '64/96px' "$ROOT"/*/SKILL.md "$ROOT"/*/reference/*.md $DC_FILES >/dev/null 2>&1 && bad "stale 64/96px band value resurfaced" || say "dead-air numbers consistent"

# 9. design-craft floor lives in the injected SKILL.md; reference/ is gone (spec Acceptance 1)
DC="$ROOT/design-craft/SKILL.md"
for rule in 'Let the UI explain itself' 'Wrap before truncating' 'One card system per screen' 'Height from content' 'Tracking floor -0.03em' '| Reflex | Build instead |'; do
  grep -qF -- "$rule" "$DC" || bad "craft floor rule missing from design-craft/SKILL.md: $rule"
done
[ -e "$ROOT/design-craft/reference" ] && bad "design-craft/reference/ still exists"
[ -e "$ROOT/design-craft/jobs" ] && bad "design-craft/jobs/ still exists (renamed to surfaces/)"
[ "$(ls "$ROOT/design-craft/surfaces" | tr '\n' ' ')" = "app-screen.md illustration.md public-page.md " ] || bad "design-craft/surfaces/ must hold app-screen, illustration and public-page only"
grep -q '^## Project Context Scan$' "$ROOT/design-craft/surfaces/app-screen.md" || bad "heading 'Project Context Scan' missing from surfaces/app-screen.md (design-qa hints point to it)"
grep -q '^## Craft floor$' "$DC" || bad "heading 'Craft floor' missing from design-craft/SKILL.md (design-qa hints point to it)"
say "craft floor in SKILL.md; surfaces/ in place; reference/ and jobs/ gone"

# 10. No backticked slash tokens in design-craft. pi-better-skills injects every skill a loaded body
# names as a backticked /name or /skill:name token, transitively. Name skills as plain words.
# Pattern mirrors pi-better-skills SKILL_REF_PATTERN (src/skill-refs.ts).
SLASH_TOKENS=$(grep -nE '`/(skill:)?[A-Za-z0-9][A-Za-z0-9._-]*`' $DC_FILES)
if [ -n "$SLASH_TOKENS" ]; then bad "backticked slash token in design-craft (injects skills transitively):"; echo "$SLASH_TOKENS"
else say "no backticked slash tokens in design-craft"; fi

# 11. Every routed skill resolves under a D3 root on this machine, or its row is marked (optional).
# Child agents are not skills. Every routed skill also has a row in skills.md (install table).
# Every row is a Pass or a Trigger, names an agent (design | builder | both), and each skill has one row.
TABLE=$(awk '/^## Routing table/{f=1;next} f&&/^## /{exit} f' "$DC" | grep '^| ' | grep -v '^| Level ' | grep -v '^|---')
row_check() { awk -F'|' '{a=$5; gsub(/ /,"",a); k=$3; sub(/^ */,"",k); if (a!="design" && a!="builder" && a!="both") print "agent: " $0; if (k !~ /^(Pass|Trigger): /) print "kind: " $0}'; }
BADROWS=$(echo "$TABLE" | row_check)
[ -z "$BADROWS" ] || { bad "Routing table rows without a valid agent or Pass/Trigger kind:"; echo "$BADROWS"; }
DUPS=$(echo "$TABLE" | cut -d'|' -f4 | sed 's/^ *//; s/ *$//; s/ .*//' | sort | uniq -d)
[ -z "$DUPS" ] || bad "skills with more than one Routing table row: $DUPS"
ROUTES=$(echo "$TABLE" | cut -d'|' -f4 | sed 's/^ *//; s/ *$//' | grep -v '(child agent)')
[ -n "$ROUTES" ] || bad "design-craft Routing table has no skills"
ROUTED=""; N=0
while IFS= read -r cell; do
  name=${cell%% *}; ROUTED="$ROUTED $name"; N=$((N+1))
  found=""; for root in "$HOME/.pi/agent/skills" "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    [ -f "$root/$name/SKILL.md" ] && { found=1; break; }; done
  case "$cell" in *"(optional)"*) ;; *) [ -n "$found" ] || bad "routed skill not installed under a D3 root: $name";; esac
  grep -q "^| $name |" "$ROOT/design-craft/skills.md" || bad "routed skill missing from design-craft/skills.md: $name"
done <<EOF
$ROUTES
EOF
say "routed skills checked ($N)"

# 12. The router names skills only in its Routing table and surface pointers (the rows that link surfaces/);
# direction.md names none. Common English words that are also skill names are not checked.
PROSE=$( { awk '/^## Routing table/{exit} {print}' "$DC" | grep -v '](surfaces/'; cat "$ROOT/design-craft/direction.md"; } )
for name in $ROUTED; do
  case "$name" in prototype|variant|break|animate) continue;; esac
  echo "$PROSE" | grep -qE -- "(^|[^A-Za-z0-9-])$name([^A-Za-z0-9-]|\$)" && bad "design-craft names $name outside the Routing table and surface pointers"
done
say "skill names stay in the Routing table and surface pointers"

echo "----"
if [ "$FAIL" -eq 0 ]; then echo "verify: GREEN"; exit 0; else echo "verify: $FAIL failure(s)"; exit 1; fi
