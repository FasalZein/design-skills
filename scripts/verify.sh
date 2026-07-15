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

# 4. No harness-generated blocks committed
grep -rl 'skill_context' "$ROOT"/*/SKILL.md >/dev/null 2>&1 && bad "skill_context block committed in a SKILL.md" || say "no skill_context blocks"

# 5. Single tracking authority: floor is -0.03em, no competing -0.04em floor
grep -rn -- '-0\.04em' "$ROOT"/*/SKILL.md "$ROOT"/*/reference/*.md >/dev/null 2>&1 && bad "competing -0.04em tracking floor found" || say "tracking floor single-sourced"

# 6. Removed decisions stay removed
grep -rn 'JetBrains Sans' "$ROOT" --include='*.md' >/dev/null 2>&1 && bad "JetBrains Sans reference resurfaced" || say "font availability rule holds"
grep -n 'MUST use .AlertDialog' "$ROOT/design-qa/SKILL.md" >/dev/null 2>&1 && bad "AlertDialog mandate resurfaced" || true

# 7. laws-of-ux stands alone (no cross-skill file pointers; skill-name mention in frontmatter description is fine)
grep -nE '(design-craft|design-qa)/|reference/[a-z-]+\.md' "$ROOT/laws-of-ux/SKILL.md" >/dev/null 2>&1 && bad "laws-of-ux points into another skill's files" || say "laws-of-ux is self-contained"

# 8. Gate count consistency
grep -q 'Gate 12' "$ROOT/design-qa/SKILL.md" || bad "design-qa missing Gate 12"
if grep -qn '11 gates' "$ROOT/README.md" 2>/dev/null; then bad "README says 11 gates"; else say "gate count consistent"; fi

# 9. design-craft kernels present (color formula + spine inline, tracking table inline)
grep -q '137' "$ROOT/design-craft/SKILL.md" || bad "color hue formula missing from kernel"
grep -q '0.99, 0.96, 0.90' "$ROOT/design-craft/SKILL.md" || bad "lightness spine missing from kernel"
grep -q -- '-0.02em' "$ROOT/design-craft/SKILL.md" || bad "tracking table missing from kernel"
say "kernels inline"

echo "----"
if [ "$FAIL" -eq 0 ]; then echo "verify: GREEN"; exit 0; else echo "verify: $FAIL failure(s)"; exit 1; fi
