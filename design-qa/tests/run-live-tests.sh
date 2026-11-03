#!/usr/bin/env bash
# Live tests for the probe files in scripts/probes/, run with agent-browser-chrome.
# Exit 0 = all pass, 1 = a test failed, 2 = no browser.
# Render probes: fixture name tests/render/<probe>-<tier>[-<case>].html sets the expected tier (pass | judge | fail).
#   Row identity: the FAIL rows must be exactly the keys in data-fail attributes, and the JUDGE rows exactly
#   the keys in data-judge attributes. A row key is its t field, or "a | b" for a pair row.
#   JUDGE rows print only with DQ_JUDGE=1; the test checks both forms.
#   Reason: an element with data-why also needs its row's why field to equal that text.
# Stage scope: on a fixture with a .ss-stage, the other render probes and targets.js must report nothing.
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
  file=$(basename "$page" .html); IFS=- read -r probe tier _ <<<"$file"; want=$(printf '%s' "$tier" | tr '[:lower:]' '[:upper:]')
  js="$PROBES/$probe.js"; [ -f "$js" ] || { ko "$file: no probe file scripts/probes/$probe.js"; continue; }
  ab open "file://$page" >/dev/null || { ko "$file: open failed"; continue; }
  out=$(ab eval --stdin < "$js") || { ko "$file: eval failed: $out"; continue; }
  full=$({ printf 'DQ_JUDGE=1;\n'; cat "$js"; } | ab eval --stdin) || { ko "$file: eval with DQ_JUDGE failed"; continue; }
  got=$(printf '%s' "$out" | jq -r .tier)
  marked=$(ab eval '(() => { const k = a => [...document.querySelectorAll("[" + a + "]")].map(e => e.getAttribute(a)); return {fail: k("data-fail"), judge: k("data-judge")}; })()')
  # every reported row has a matching key, and every key a matching row
  ids=$(printf '%s' "$full" | jq -c '{fail: [.fail[] | .t // "\(.a) | \(.b)"] | sort, judge: [.judge[] | .t // "\(.a) | \(.b)"] | sort}')
  same=$(printf '%s\n%s' "$marked" "$ids" | jq -s '(.[0].fail|sort) == .[1].fail and (.[0].judge|sort) == .[1].judge')
  whys=$(ab eval '[...document.querySelectorAll("[data-why]")].map(e => ({k: e.getAttribute("data-fail") ?? e.getAttribute("data-judge"), why: e.getAttribute("data-why")}))')
  [ "$same" = true ] && same=$(printf '%s\n%s' "$whys" "$full" | jq -s '(.[1].fail + (.[1].judge // [])) as $rows | [.[0][] | . as $w | any($rows[]; (.t // "\(.a) | \(.b)") == $w.k and .why == $w.why)] | all')
  # tier matches counts; FAIL rows always present; judge rows only with the switch
  shape=$(printf '%s\n%s' "$out" "$full" | jq -s '
    (.[0] | .counts.fail == (.fail|length) and (has("judge")|not)
       and .tier == (if .counts.fail > 0 then "FAIL" elif .counts.judge > 0 then "JUDGE" else "PASS" end))
    and (.[1] | (.judge|length) == .counts.judge)')
  if [ "$got" = "$want" ] && [ "$same" = "true" ] && [ "$shape" = "true" ]; then
    PASS=$((PASS+1)); echo "ok   $file: $got (counts $(printf '%s' "$out" | jq -c .counts))"
  else ko "$file: want $want with rows $(printf '%s' "$marked" | jq -c .), got $got with rows $ids (output shape ok: $shape)"; fi
  [ "$(ab eval 'document.querySelectorAll(".ss-stage").length')" = 0 ] && continue
  for other in clip wrap overlap align targets; do [ "$other" = "$probe" ] && continue
    o=$({ printf 'DQ_JUDGE=1;\n'; cat "$PROBES/$other.js"; } | ab eval --stdin)
    if printf '%s' "$o" | jq -e '(.fail | length) == 0 and ((.judge // []) | length) == 0' >/dev/null; then
      PASS=$((PASS+1)); echo "ok   $file: $other reports nothing inside the stage"
    else ko "$file: $other reports stage content: $(printf '%s' "$o" | jq -c .)"; fi
  done
done

ab open "file://$FIX/clip-pass.html" >/dev/null
for js in "$PROBES"/*.js; do
  head -1 "$js" | grep -q 'machine probe' || continue
  name=$(basename "$js" .js)
  out=$(ab eval --stdin < "$js") && [ -n "$out" ] && printf '%s' "$out" | jq -e . >/dev/null 2>&1 \
    && { PASS=$((PASS+1)); echo "ok   machine probe $name evaluates: $(printf '%s' "$out" | jq -c . | cut -c1-80)"; } \
    || ko "machine probe $name: $out"
done
# contrast rows: text floors 4.5 and 3 (24px, or 18.66px bold), placeholder colour, translucent background over white,
# and control borders at 3:1. Expected ratios are WCAG values worked out by hand (tolerance 0.02).
ab open "file://$HERE/machine/contrast.html" >/dev/null
out=$(ab eval --stdin < "$PROBES/contrast.js")
want='[{"t":"Gray body text","r":4.48,"need":4.5},{"t":"Large light heading","r":2.32,"need":3},
  {"t":"Regular 19px fails","r":3.54,"need":4.5},{"t":"White on half black","r":4.0,"need":4.5},
  {"t":"Email address","r":2.32,"need":4.5},{"t":"border:email","r":1.36,"need":3}]'
if printf '%s\n%s' "$out" "$want" | jq -se '.[0] as $g | .[1] as $w | ($g | length) == ($w | length)
    and ([range(0; $w | length) | ($g[.].r - $w[.].r) as $d | $g[.].t == $w[.].t and $g[.].need == $w[.].need
      and (if $d < 0 then -$d else $d end) <= 0.02] | all)' >/dev/null; then
  PASS=$((PASS+1)); echo "ok   contrast rows match the WCAG ratios"
else ko "contrast rows: want $(printf '%s' "$want" | jq -c .), got $(printf '%s' "$out" | jq -c .)"; fi
# landing rules: section-level seams (border, hr, thin wide pseudo-element line) counted per tag.class; a sticky bar,
# a list row and a narrow box are skipped. Transitions: background changes between wide bands in document order.
ab open "file://$HERE/machine/landing.html" >/dev/null
out=$(ab eval --stdin < "$PROBES/landing.js")
want='{"rules":{"HEADER.top":1,"HR.rule":2,"SECTION.faq":1},"transitions":3}'
if printf '%s\n%s' "$out" "$want" | jq -se '.[0] == .[1]' >/dev/null; then
  PASS=$((PASS+1)); echo "ok   landing seams and transitions match"
else ko "landing: want $want, got $(printf '%s' "$out" | jq -c .)"; fi
echo "----"
echo "probe tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
