#!/usr/bin/env bash
# Live tests for the probe files in scripts/probes/, run with agent-browser-chrome.
# Exit 0 = all pass, 1 = a test failed, 2 = no browser.
# Render probes: fixture name tests/render/<probe>-<tier>.html sets the expected tier (pass | judge | fail).
#   In a fail fixture, the probe must report exactly one FAIL row per element marked data-expect="fail".
#   JUDGE rows print only with DQ_JUDGE=1; the test checks both forms.
# Machine probes: each must evaluate to a value on a fixture page (smoke test; no expected tier).
set -u -o pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
PROBES="$HERE/../scripts/probes"
FIX="$HERE/render"
command -v agent-browser-chrome >/dev/null || { echo "agent-browser-chrome not found"; exit 2; }
command -v jq >/dev/null || { echo "jq not found"; exit 2; }
SESSION="design-qa-probes-$$"
ab() { agent-browser-chrome --session "$SESSION" "$@"; }
trap 'ab close >/dev/null 2>&1' EXIT
PASS=0; FAIL=0
ko() { FAIL=$((FAIL+1)); echo "FAIL $*"; }

ab set viewport 1440 900 >/dev/null || { echo "could not start browser session $SESSION"; exit 2; }
for page in "$FIX"/*.html; do
  file=$(basename "$page" .html); probe=${file%-*}; want=$(printf '%s' "${file##*-}" | tr '[:lower:]' '[:upper:]')
  js="$PROBES/$probe.js"; [ -f "$js" ] || { ko "$file: no probe file scripts/probes/$probe.js"; continue; }
  ab open "file://$page" >/dev/null || { ko "$file: open failed"; continue; }
  out=$(ab eval --stdin < "$js") || { ko "$file: eval failed: $out"; continue; }
  full=$({ printf 'DQ_JUDGE=1;\n'; cat "$js"; } | ab eval --stdin) || { ko "$file: eval with DQ_JUDGE failed"; continue; }
  got=$(printf '%s' "$out" | jq -r .tier)
  rows=$(printf '%s' "$out" | jq '.fail|length')
  marked=$(ab eval 'document.querySelectorAll("[data-expect=fail]").length')
  # tier matches counts; FAIL rows always present; judge rows only with the switch
  shape=$(printf '%s\n%s' "$out" "$full" | jq -s '
    (.[0] | .counts.fail == (.fail|length) and (has("judge")|not)
       and .tier == (if .counts.fail > 0 then "FAIL" elif .counts.judge > 0 then "JUDGE" else "PASS" end))
    and (.[1] | (.judge|length) == .counts.judge)')
  if [ "$got" = "$want" ] && [ "$rows" = "$marked" ] && [ "$shape" = "true" ]; then
    PASS=$((PASS+1)); echo "ok   $file: $got (counts $(printf '%s' "$out" | jq -c .counts))"
  else ko "$file: want $want with $marked fail rows, got $got with $rows (output shape ok: $shape)"; printf '%s\n' "$full" | jq -c .; fi
done

ab open "file://$FIX/clip-pass.html" >/dev/null
for js in "$PROBES"/*.js; do
  head -1 "$js" | grep -q 'machine probe' || continue
  name=$(basename "$js" .js)
  out=$(ab eval --stdin < "$js") && [ -n "$out" ] && printf '%s' "$out" | jq -e . >/dev/null 2>&1 \
    && { PASS=$((PASS+1)); echo "ok   machine probe $name evaluates: $(printf '%s' "$out" | jq -c . | cut -c1-80)"; } \
    || ko "machine probe $name: $out"
done
echo "----"
echo "probe tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
