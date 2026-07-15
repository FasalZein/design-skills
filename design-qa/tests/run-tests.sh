#!/usr/bin/env bash
# Contract tests for design-scan.sh. Exit 0 = all pass.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SCAN="$HERE/../scripts/design-scan.sh"
FIX="$HERE/fixtures"
PASS=0; FAIL=0

ok()  { PASS=$((PASS+1)); }
ko()  { FAIL=$((FAIL+1)); echo "FAIL: $*"; }
t() { # t "name" expected_exit cmd...
  local name="$1" want="$2"; shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  [ "$got" -eq "$want" ] && ok || ko "$name (want exit $want, got $got)"
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

# --- regex-metacharacter target path ([slug]) must still find violations ---
SLUG=$(mktemp -d)/'[slug]'; mkdir -p "$SLUG"
printf '<a href="#">bad</a>\n' > "$SLUG/a.html"
OUT=$(bash "$SCAN" "$SLUG" --json 2>/dev/null); RC=$?
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | jq -e '.total>=1 and (.issues[0].file=="a.html")' >/dev/null 2>&1; then
  ok; else ko "[slug] target path (exit $RC): $(printf '%s' "$OUT" | jq -c '{total,issues}' 2>/dev/null)"; fi
rm -rf "$(dirname "$SLUG")"

# --- JSON validity + schema, including hostile paths ---
OUT=$(bash "$SCAN" "$FIX/violations" --json 2>/dev/null)
printf '%s' "$OUT" | jq -e '.status=="fail" and .scannedFiles>0 and (.issues|length)==.total' >/dev/null 2>&1 \
  && ok || ko "violations JSON invalid or inconsistent"
printf '%s' "$OUT" | jq -e '(.issues|length) as $n | ([.issues[] | select((.line|type=="number") and .line>=1 and .severity!=null and .category!=null and .file!=null and .fix!=null)] | length) == $n' >/dev/null 2>&1 \
  && ok || ko "issue schema broken (line must be >=1; all fields present)"
HOSTILE=$(mktemp -d)/'we"ird	dir'; mkdir -p "$HOSTILE"
printf '<a href="#">x</a>\t<span style="color:#fff">tab\ttab</span>\n' > "$HOSTILE/bad.html"
OUT=$(bash "$SCAN" "$HOSTILE" --json 2>/dev/null); RC=$?
{ [ "$RC" -eq 1 ] && printf '%s' "$OUT" | jq -e '.total>=1' >/dev/null 2>&1; } \
  && ok || ko "hostile path/content JSON (exit $RC)"
rm -rf "$(dirname "$HOSTILE")"

# --- per-category detection on violations ---
CATS=$(bash "$SCAN" "$FIX/violations" --json 2>/dev/null | jq -r '.categories | keys | join(" ")')
for want in SLOP_GRADIENT GRADIENT_TEXT GRADIENT_ORB DEAD_CONTROL DIV_ONCLICK TABINDEX_POSITIVE SIDE_STRIPE SECTION_BORDER NAMED_COLOR \
            ZOOM_DISABLED PASTE_BLOCKED H_SCREEN HARDCODED_COLOR ARBITRARY_VALUE TRACKING_TIGHTER \
            LAYOUT_ANIM TRANSITION_ALL CONSOLE_LOG; do
  case " $CATS " in *" $want "*) ok ;; *) ko "category $want not detected" ;; esac
done

# --- documented-pattern matrix (each previously-escaping representation) ---
J=$(bash "$SCAN" "$FIX/violations" --json 2>/dev/null)
probe() { printf '%s' "$J" | jq -e --arg f "$2" --arg c "$1" '[.issues[] | select(.file==$f and .category==$c)] | length >= 1' >/dev/null 2>&1 && ok || ko "$1 not found in $2"; }
probe SLOP_GRADIENT   Bad2.tsx    # purple -> blue
probe GRADIENT_TEXT   Bad2.tsx    # multiline class attr
probe DEAD_CONTROL    Bad2.tsx    # empty handler + href=""
probe DIV_ONCLICK     bad.jsx     # multiline JSX
probe DIV_ONCLICK     bad2.html   # multiline HTML onclick
probe ZOOM_DISABLED   bad2.html   # single-quoted meta
probe TRACKING_TIGHTER bad.scss   # letter-spacing:-0.1em
probe HARDCODED_COLOR bad.css     # hex sharing a line with var(--)
probe SIDE_STRIPE     bad.css     # css left-stripe
probe SIDE_STRIPE     Bad2.tsx    # tailwind border-l-4 + border-amber-500
probe SECTION_BORDER  bad.css     # section { border-top }
probe SECTION_BORDER  bad2.html   # <section class="border-t">
probe NAMED_COLOR     bad.html    # bg-purple-500
probe NAMED_COLOR     Bad2.tsx    # hover:/md:/dark:/data-[]: variants
probe SIDE_STRIPE     bad.scss    # border-inline-start + .25rem + longhand + inset shadow
probe SIDE_STRIPE     Bad2.tsx    # style={{borderLeft}}
probe SECTION_BORDER  bad.scss    # .services-section border-block-start
probe ARBITRARY_VALUE bad.html    # w-[5px]
probe ARBITRARY_VALUE Bad2.tsx    # text-[1.125rem], w-[50px]
probe LAYOUT_ANIM     Bad2.tsx    # transition-[height]
probe CONSOLE_LOG     bad.ts
probe PASTE_BLOCKED   bad.js
probe DEAD_CONTROL    bad.mdx

# --- per-format coverage: every violation fixture file yields >=1 finding ---
for f in Bad.tsx Bad2.tsx bad.jsx bad.ts bad.js bad.css bad.scss bad.html bad2.html bad.vue bad.svelte bad.astro bad.mdx; do
  N=$(printf '%s' "$J" | jq --arg f "$f" '[.issues[] | select(.file==$f)] | length')
  [ "${N:-0}" -ge 1 ] && ok || ko "no findings in $f"
done

# --- false-positive boundary: clean fixtures produce zero findings ---
N=$(bash "$SCAN" "$FIX/clean" --json 2>/dev/null | jq '.total')
if [ "$N" = "0" ]; then ok; else
  ko "clean fixtures produced $N findings:"
  bash "$SCAN" "$FIX/clean" --json 2>/dev/null | jq -c '.issues[]'; fi

# --- dedup: one <div onClick> defect = one finding even with ast-grep installed ---
D=$(mktemp -d); printf 'export const x = <div onClick={() => go()}>x</div>;\n' > "$D/a.tsx"
N=$(bash "$SCAN" "$D" --json 2>/dev/null | jq '[.issues[] | select(.file=="a.tsx" and .line==1)] | length')
[ "$N" = "1" ] && ok || ko "div onClick counted $N times (want 1; lexical+structural must dedup)"
rm -rf "$D"

# --- ast-grep impostor that crashes => exit 2, never silent pass ---
D=$(mktemp -d); BIN=$(mktemp -d); printf 'export const x = 1;\n' > "$D/a.tsx"
cat > "$BIN/ast-grep" <<'SH'
#!/usr/bin/env bash
[ "${1:-}" = "--version" ] && { echo "ast-grep 99.0"; exit 0; }
exit 47
SH
chmod +x "$BIN/ast-grep"
t "crashing ast-grep exits 2" 2 env PATH="$BIN:$PATH" bash "$SCAN" "$D"
rm -rf "$D" "$BIN"

# --- NUL byte in a supported file: violation after the NUL is still found ---
D=$(mktemp -d); printf 'ok\0<a href="#">bad</a>\n' > "$D/bad.tsx"
OUT=$(bash "$SCAN" "$D" --json 2>/dev/null); RC=$?
{ [ "$RC" -eq 1 ] && printf '%s' "$OUT" | jq -e '.total>=1' >/dev/null 2>&1; } \
  && ok || ko "NUL-containing file passed silently (exit $RC)"
rm -rf "$D"

# --- newline in filename: counted once ---
D=$(mktemp -d); printf 'export const ok = 1;\n' > "$D/one
file.ts"
N=$(bash "$SCAN" "$D" --allow-empty --json 2>/dev/null | jq '.scannedFiles')
[ "$N" = "1" ] && ok || ko "newline filename counted as $N files (want 1)"
rm -rf "$D"

# --- symlink policy: not followed (documented) ---
D=$(mktemp -d); printf '<a href="#">bad</a>\n' > "$D/outside.html"
mkdir "$D/scope"; printf 'export const ok = 1;\n' > "$D/scope/good.ts"; ln -s "$D/outside.html" "$D/scope/link.html"
OUT=$(bash "$SCAN" "$D/scope" --json 2>/dev/null); RC=$?
{ [ "$RC" -eq 0 ] && printf '%s' "$OUT" | jq -e '.total==0 and .scannedFiles==1' >/dev/null 2>&1; } \
  && ok || ko "symlink policy changed (exit $RC): $(printf '%s' "$OUT" | jq -c '{scannedFiles,total}' 2>/dev/null)"
rm -rf "$D"

# --- --json without jq still emits parseable error JSON ---
# (macOS ships /usr/bin/jq, so build a PATH with everything except jq)
D=$(mktemp -d); BIN=$(mktemp -d); ln -s "$(command -v rg)" "$BIN/rg" 2>/dev/null
for tool in bash sh mktemp tr wc sed awk head grep rm env; do
  p=$(command -v "$tool") && ln -s "$p" "$BIN/$tool" 2>/dev/null
done
printf 'export const ok = 1;\n' > "$D/a.ts"
OUT=$(env PATH="$BIN" bash "$SCAN" "$D" --json 2>/dev/null); RC=$?
{ [ "$RC" -eq 2 ] && printf '%s' "$OUT" | jq -e '.status=="error"' >/dev/null 2>&1; } \
  && ok || ko "jq-missing --json error output (exit $RC, stdout: ${OUT:-empty})"
rm -rf "$D" "$BIN"

# --- severity contract: SIDE_STRIPE critical, SECTION_BORDER high ---
SEV=$(printf '%s' "$J" | jq -r '[.issues[] | select(.category=="SIDE_STRIPE") | .severity] | unique | join(",")')
[ "$SEV" = "critical" ] && ok || ko "SIDE_STRIPE severity is '$SEV' (want critical)"
SEV=$(printf '%s' "$J" | jq -r '[.issues[] | select(.category=="SECTION_BORDER") | .severity] | unique | join(",")')
[ "$SEV" = "high" ] && ok || ko "SECTION_BORDER severity is '$SEV' (want high)"
CO=$(bash "$SCAN" "$FIX/violations" --json --critical-only 2>/dev/null | jq -r '(.categories // {}) | keys | join(",")')
case "$CO" in *SIDE_STRIPE*) ok ;; *) ko "--critical-only lost SIDE_STRIPE" ;; esac
case "$CO" in *SECTION_BORDER*) ko "--critical-only includes high-severity SECTION_BORDER" ;; *) ok ;; esac

# --- machine-readable support + error schema ---
printf '%s' "$J" | jq -e '.support.structural | test("TSX-only")' >/dev/null 2>&1 && ok || ko "support.structural stale"
ERR=$(bash "$SCAN" /nonexistent-dir-xyz --json 2>/dev/null)
printf '%s' "$ERR" | jq -e '.status=="error" and (.errors|type=="array")' >/dev/null 2>&1 && ok || ko "error JSON shape (.errors must be array)"

# --- critical-only gates only criticals ---
ONLY=$(mktemp -d); printf '.x { transition: all 1s; }\n' > "$ONLY/style.css"
t "medium-only under --critical-only exits 0" 0 bash "$SCAN" "$ONLY" --critical-only
t "medium-only default exits 1"               1 bash "$SCAN" "$ONLY"
rm -rf "$ONLY"

# --- allowlist ---
AL=$(mktemp)
printf 'DEAD_CONTROL\t.*\ttest placeholder links\n' > "$AL"
LEFT=$(bash "$SCAN" "$FIX/violations" --json --allowlist "$AL" 2>/dev/null | jq '[.issues[] | select(.category=="DEAD_CONTROL")] | length')
[ "$LEFT" = "0" ] && ok || ko "allowlist did not suppress DEAD_CONTROL"
ONE=$(mktemp -d); printf '<a href="#">only finding</a>\n' > "$ONE/x.html"
t "allowlist suppressing final finding exits 0" 0 bash "$SCAN" "$ONE" --allowlist "$AL"
t "allowlist FILE form parses"                  0 bash "$SCAN" "$ONE" --allowlist="$AL"
printf 'BADROW-no-tabs\n' > "$AL"
t "malformed allowlist exits 2"                 2 bash "$SCAN" "$ONE" --allowlist "$AL"
rm -rf "$ONE" "$AL"

echo "----"
echo "design-scan tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
