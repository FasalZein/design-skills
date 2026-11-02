#!/usr/bin/env bash
# Live tests for the render probes. Runs every probe block from reference/live-verification.md
# against its fixtures in tests/render/ with agent-browser-chrome. Exit 0 = all pass, 2 = no browser.
# Fixture name <probe>-<tier>.html sets the expected tier (pass | judge | fail).
# In a fail fixture, the probe must report exactly one FAIL row per element marked data-expect="fail".
set -u -o pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
DOC="$HERE/../reference/live-verification.md"
FIX="$HERE/render"
command -v agent-browser-chrome >/dev/null || { echo "agent-browser-chrome not found"; exit 2; }
SESSION="design-qa-probes-$$"
ab() { agent-browser-chrome --session "$SESSION" "$@"; }
trap 'ab close >/dev/null 2>&1' EXIT
PASS=0; FAIL=0
probe_js() { awk -v m="<!-- probe:$1 -->" '$0==m{f=1;next} f&&/^```js/{c=1;next} c&&/^```/{exit} c' "$DOC"; }

ab set viewport 1440 900 >/dev/null || { echo "could not start browser session $SESSION"; exit 2; }
for page in "$FIX"/*.html; do
  file=$(basename "$page" .html); probe=${file%-*}; want=$(printf '%s' "${file##*-}" | tr '[:lower:]' '[:upper:]')
  js=$(probe_js "$probe"); [ -n "$js" ] || { FAIL=$((FAIL+1)); echo "FAIL $file: no probe:$probe block in live-verification.md"; continue; }
  ab open "file://$page" >/dev/null || { FAIL=$((FAIL+1)); echo "FAIL $file: open failed"; continue; }
  out=$(printf '%s' "$js" | ab eval --stdin) || { FAIL=$((FAIL+1)); echo "FAIL $file: eval failed: $out"; continue; }
  got=$(printf '%s' "$out" | jq -r 'if (.fail|length)>0 then "FAIL" elif (.judge|length)>0 then "JUDGE" else "PASS" end')
  rows=$(printf '%s' "$out" | jq '.fail|length')
  marked=$(ab eval 'document.querySelectorAll("[data-expect=fail]").length')
  if [ "$got" = "$want" ] && [ "$rows" = "$marked" ]; then PASS=$((PASS+1)); echo "ok   $file: $got (fail rows $rows)"
  else FAIL=$((FAIL+1)); echo "FAIL $file: want $want with $marked fail rows, got $got with $rows"; printf '%s\n' "$out" | jq -c .; fi
done
echo "----"
echo "render probe tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
