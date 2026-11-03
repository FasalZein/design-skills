#!/usr/bin/env bash
# Fixture tests for evals/retro/index.sh and compliance.sh. Expected values come from spec D22
# and the s2 review (F7, F9-F12), not from script output. Exit 0 = all pass.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
RETRO=$(dirname "$HERE")
FIX="$HERE/fixtures"
FAILS=0
ok() { echo "ok: $*"; }
no() { FAILS=$((FAILS+1)); echo "FAIL: $*"; }
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Column of the row whose title is $1, by header name $2.
col() { awk -F'\t' -v t="$1" -v c="$2" 'NR==1{for(i=1;i<=NF;i++) h[$i]=i; next} $(h["title"])==t {print $(h[c])}' "$TSV"; }
expect() { local got; got=$(col "$1" "$2"); [ "$got" = "$3" ] && ok "$1 $2=$3" || no "$1 $2: want [$3] got [$got]"; }

# F11: relative OUT resolves against the caller's directory, not the sessions directory.
mkdir -p "$WORK/caller"
( cd "$WORK/caller" && PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/index.sh" out/sessions.tsv >"$WORK/index.log" 2>&1 ); st=$?
TSV="$WORK/caller/out/sessions.tsv"
[ "$st" -eq 0 ] && ok "index on valid fixtures exits 0" || { no "index on valid fixtures exit $st"; cat "$WORK/index.log"; }
[ -f "$TSV" ] && ok "F11 relative OUT lands in the caller directory" || no "F11 relative OUT not at caller/out/sessions.tsv"
[ -e "$FIX/good/out" ] && { no "F11 relative OUT created inside the sessions directory"; rm -rf "$FIX/good/out"; }
[ -f "$TSV" ] || TSV=/dev/null

# F7: skill text counts independent of frontmatter field order; a named-section read counts;
# a failed read and a path in call arguments alone do not.
expect "f7 field order" skills_returned "interface-review"
expect "f7 field order" skill_count 1
expect "f7 section read" skills_returned "design-qa"
expect "f7 section read" skill_count 1
expect "f7 concatenated skills" skills_returned "design-craft,laws-of-ux"
# A heading list holds no section; a shell variable in the path names no skill.
expect "f7 heading list" skill_count 0

# F9: pass outcomes come from the report artifact; an unfilled template is not an outcome.
expect "f9 artifact report" passes_applied 1
expect "f9 artifact report" passes_na 1
expect "f9 artifact report" passes "better-writing -> applied: rewrote the empty state; state-machine -> n/a: the part has one state"
expect "f9 artifact report" result DONE
expect "f9 template copy" passes_applied 0
expect "f9 template copy" passes_na 0
expect "f9 template copy" result none

# F10: ask_user counts by tool-call name, direct and inside codemode; prose mentions do not count.
expect "f10 asks" asks 2

# F11: compliance resolves a relative TSV against the caller's directory.
( cd "$WORK/caller" && PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/compliance.sh" 2026-11-03T05 out/sessions.tsv >"$WORK/comp.log" 2>&1 ); st=$?
[ "$st" -eq 0 ] && grep -q '^== sessions since 2026-11-03T05: 7$' "$WORK/comp.log" && ok "F11 compliance reads a relative TSV" || { no "F11 compliance on relative TSV (exit $st)"; cat "$WORK/comp.log"; }

# F12: failures exit nonzero; a valid empty index exits 0.
PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/compliance.sh" 2026-11-03T05 "$WORK/missing.tsv" >/dev/null 2>&1 && no "F12 compliance with a missing TSV exits 0" || ok "F12 compliance with a missing TSV exits nonzero"
PI_SESSIONS_DIR="$FIX/bad" bash "$RETRO/index.sh" "$WORK/bad.tsv" >/dev/null 2>&1 && no "F12 index with PARSE_FAIL exits 0" || ok "F12 index with PARSE_FAIL exits nonzero"
grep -q '^PARSE_FAIL' "$WORK/bad.tsv" 2>/dev/null && ok "F12 PARSE_FAIL row written" || no "F12 PARSE_FAIL row missing"
PI_SESSIONS_DIR="$FIX/bad" bash "$RETRO/compliance.sh" 2026-11-03T05 "$WORK/bad.tsv" >/dev/null 2>&1 && no "F12 compliance on a TSV with PARSE_FAIL exits 0" || ok "F12 compliance on a TSV with PARSE_FAIL exits nonzero"
PI_SESSIONS_DIR="$WORK/no-such-dir" bash "$RETRO/index.sh" "$WORK/x.tsv" >/dev/null 2>&1 && no "F12 index with a missing sessions dir exits 0" || ok "F12 index with a missing sessions dir exits nonzero"
PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/index.sh" /dev/null/x.tsv >/dev/null 2>&1 && no "F12 index with an unwritable OUT exits 0" || ok "F12 index with an unwritable OUT exits nonzero"
mkdir -p "$WORK/empty"
PI_SESSIONS_DIR="$WORK/empty" bash "$RETRO/index.sh" "$WORK/empty.tsv" >/dev/null 2>&1 && ok "F12 valid empty index exits 0" || no "F12 valid empty index exits nonzero"
PI_SESSIONS_DIR="$WORK/empty" bash "$RETRO/compliance.sh" 2026-11-03T05 "$WORK/empty.tsv" >/dev/null 2>&1 && ok "F12 compliance on a valid empty index exits 0" || no "F12 compliance on a valid empty index exits nonzero"

echo "----"
[ "$FAILS" -eq 0 ] && { echo "retro tests: PASS"; exit 0; } || { echo "retro tests: $FAILS failure(s)"; exit 1; }
