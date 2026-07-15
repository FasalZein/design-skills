#!/usr/bin/env bash
# Contract tests for design-scan.sh. Exit 0 = all pass.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SCAN="$HERE/../scripts/design-scan.sh"
FIX="$HERE/fixtures"
PASS=0; FAIL=0

t() { # t "name" expected_exit cmd...
  local name="$1" want="$2"; shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: $name (want exit $want, got $got)"; fi
}

# --- exit contract ---
t "missing target exits 2"        2 bash "$SCAN" /nonexistent-dir-xyz
t "no target arg exits 2"         2 bash "$SCAN"
t "unknown option exits 2"        2 bash "$SCAN" "$FIX/clean" --bogus
t "two targets exits 2"           2 bash "$SCAN" "$FIX/clean" "$FIX/violations"
EMPTY=$(mktemp -d); touch "$EMPTY/readme.txt"
t "zero supported files exits 2"  2 bash "$SCAN" "$EMPTY"
t "--allow-empty exits 0"         0 bash "$SCAN" "$EMPTY" --allow-empty
rm -rf "$EMPTY"
t "clean fixtures exit 0"         0 bash "$SCAN" "$FIX/clean"
t "violations exit 1"             1 bash "$SCAN" "$FIX/violations"
t "missing rg exits 2"            2 env PATH=/usr/bin:/bin bash "$SCAN" "$FIX/violations"

# --- JSON validity, including hostile paths ---
OUT=$(bash "$SCAN" "$FIX/violations" --json 2>/dev/null)
if printf '%s' "$OUT" | jq -e '.status=="fail" and .scannedFiles>0 and (.issues|length)==.total' >/dev/null 2>&1; then
  PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: violations JSON invalid or inconsistent"; fi
HOSTILE=$(mktemp -d)/'we"ird	dir'; mkdir -p "$HOSTILE"
printf '<a href="#">x</a>\t<span style="color:#fff">tab\ttab</span>\n' > "$HOSTILE/bad.html"
OUT=$(bash "$SCAN" "$HOSTILE" --json 2>/dev/null); RC=$?
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | jq -e '.total>=1' >/dev/null 2>&1; then
  PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: hostile path/content JSON (exit $RC)"; fi
rm -rf "$(dirname "$HOSTILE")"

# --- per-category detection on violations ---
CATS=$(bash "$SCAN" "$FIX/violations" --json 2>/dev/null | jq -r '.categories | keys | join(" ")')
for want in SLOP_GRADIENT GRADIENT_TEXT GRADIENT_ORB DEAD_CONTROL DIV_ONCLICK TABINDEX_POSITIVE \
            ZOOM_DISABLED PASTE_BLOCKED H_SCREEN HARDCODED_COLOR ARBITRARY_VALUE TRACKING_TIGHTER \
            LAYOUT_ANIM TRANSITION_ALL WILL_CHANGE CONSOLE_LOG; do
  case " $CATS " in *" $want "*) PASS=$((PASS+1)) ;; *) FAIL=$((FAIL+1)); echo "FAIL: category $want not detected" ;; esac
done

# --- per-format coverage: every violation fixture file yields >=1 finding ---
for f in Bad.tsx bad.css bad.html bad.vue bad.svelte bad.astro; do
  N=$(bash "$SCAN" "$FIX/violations" --json 2>/dev/null | jq --arg f "$f" '[.issues[] | select(.file==$f)] | length')
  if [ "${N:-0}" -ge 1 ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: no findings in $f"; fi
done

# --- false-positive boundary: clean fixtures produce zero findings ---
N=$(bash "$SCAN" "$FIX/clean" --json 2>/dev/null | jq '.total')
if [ "$N" = "0" ]; then PASS=$((PASS+1)); else
  FAIL=$((FAIL+1)); echo "FAIL: clean fixtures produced $N findings:"
  bash "$SCAN" "$FIX/clean" --json 2>/dev/null | jq -c '.issues[]'; fi

# --- critical-only gates only criticals ---
ONLY=$(mktemp -d); printf '.x { transition: all 1s; }\n' > "$ONLY/style.css"
t "medium-only under --critical-only exits 0" 0 bash "$SCAN" "$ONLY" --critical-only
t "medium-only default exits 1"               1 bash "$SCAN" "$ONLY"
rm -rf "$ONLY"

# --- allowlist ---
AL=$(mktemp)
printf 'DEAD_CONTROL\t.*\ttest placeholder links\n' > "$AL"
LEFT=$(bash "$SCAN" "$FIX/violations" --json --allowlist "$AL" 2>/dev/null | jq '[.issues[] | select(.category=="DEAD_CONTROL")] | length')
if [ "$LEFT" = "0" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: allowlist did not suppress DEAD_CONTROL"; fi
ONE=$(mktemp -d); printf '<a href="#">only finding</a>\n' > "$ONE/x.html"
t "allowlist suppressing final finding exits 0" 0 bash "$SCAN" "$ONE" --allowlist "$AL"
t "allowlist FILE form parses"                  0 bash "$SCAN" "$ONE" --allowlist="$AL"
printf 'BADROW-no-tabs\n' > "$AL"
t "malformed allowlist exits 2"                 2 bash "$SCAN" "$ONE" --allowlist "$AL"
rm -rf "$ONE" "$AL"

echo "----"
echo "design-scan tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
