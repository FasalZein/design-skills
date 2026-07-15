#!/usr/bin/env bash
# design-scan — mechanical anti-slop / design-system scanner.
# Exit: 0 = scanned & passed · 1 = findings broke the active mode · 2 = could not produce reliable evidence.
# Contract details: ../SKILL.md "Scanner".
set -u

JSON=0; CRITICAL_ONLY=0; ALLOW_EMPTY=0; ALLOWLIST=""; TARGET=""

die() {
  if [ "$JSON" -eq 1 ]; then
    if command -v jq >/dev/null 2>&1; then
      jq -n --arg e "$1" '{status:"error",errors:[$e]}'
    else
      msg=${1//\\/\\\\}; msg=${msg//\"/\\\"}
      printf '{"status":"error","errors":["%s"]}\n' "$msg"
    fi
  fi
  echo "design-scan error: $1" >&2
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON=1 ;;
    --critical-only) CRITICAL_ONLY=1 ;;
    --allow-empty) ALLOW_EMPTY=1 ;;
    --allowlist=*) ALLOWLIST="${1#--allowlist=}" ;;
    --allowlist) shift; [ $# -gt 0 ] || die "--allowlist requires a file"; ALLOWLIST="$1" ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *) [ -n "$TARGET" ] && die "multiple targets given: '$TARGET' and '$1'"; TARGET="$1" ;;
  esac
  shift
done

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"
command -v jq >/dev/null 2>&1 || die "jq is required"
[ -n "$TARGET" ] || die "no target directory given"
[ -e "$TARGET" ] || die "target does not exist: $TARGET"

GLOBS=(-g '*.tsx' -g '*.jsx' -g '*.ts' -g '*.js' -g '*.css' -g '*.scss' -g '*.html' -g '*.vue' -g '*.svelte' -g '*.astro' -g '*.mdx'
       -g '!node_modules' -g '!dist' -g '!build' -g '!.next')

TMP=$(mktemp -d) || die "mktemp failed"
trap 'rm -rf "$TMP"' EXIT

# NUL-delimited count via temp file: bash $() strips NUL bytes, and newline-delimited
# counting miscounts newline-containing filenames. Symlinks are not followed (policy).
rg --files -0 "${GLOBS[@]}" "$TARGET" > "$TMP/files0" 2>/dev/null; RC=$?
[ "$RC" -ge 2 ] && die "rg --files failed (exit $RC)"
SCANNED=$(tr -cd '\0' < "$TMP/files0" | wc -c | tr -d ' ')
if [ "$SCANNED" -eq 0 ] && [ "$ALLOW_EMPTY" -eq 0 ]; then
  die "no supported files under $TARGET (use --allow-empty to accept)"
fi
FINDINGS="$TMP/findings.jsonl"; : > "$FINDINGS"

# run_check CATEGORY SEVERITY FIX EXCLUDE_RE [rg-args...]
run_check() {
  local cat="$1" sev="$2" fix="$3" excl="$4"; shift 4
  local out rc
  out=$(rg --json -a "${GLOBS[@]}" "$@" "$TARGET" 2>"$TMP/rg.err"); rc=$?
  if [ "$rc" -ge 2 ]; then die "check $cat failed: $(head -1 "$TMP/rg.err")"; fi
  [ "$rc" -eq 1 ] && return 0
  # Literal (non-regex) prefix strip: target paths may contain regex metacharacters like [slug].
  printf '%s' "$out" | jq -c --arg cat "$cat" --arg sev "$sev" --arg fix "$fix" --arg excl "$excl" --arg tgt "$TARGET" '
    select(.type=="match")
    | {category:$cat, severity:$sev, fix:$fix,
       file:(.data.path.text | if startswith($tgt) then .[($tgt|length):] | ltrimstr("/") else . end),
       line:.data.line_number,
       content:(.data.lines.text | gsub("[\\n\\t]";" ") | .[0:200] | sub("^\\s+";""))}
    | select(($excl == "") or ((.content | test($excl)) | not))
  ' >> "$FINDINGS" 2>"$TMP/jq.err" || die "jq normalization failed for $cat"
  [ -s "$TMP/jq.err" ] && die "jq normalization error for $cat: $(head -1 "$TMP/jq.err")"
  return 0
}

# ---- Critical: Gate 1 hard guardrails + accessibility blockers (mechanical subset) ----
# Multiline gaps use [^"'<>] so a match never crosses an attribute or element boundary
# (from-purple on one element + to-pink on another is NOT one gradient).
run_check SLOP_GRADIENT critical \
  "The AI gradient family. One flat committed surface, real media, or a tonal treatment from your own scale." "" \
  -U \
  -e 'from-(purple|violet|indigo)-[0-9]+[^"'\''<>]{0,160}to-(pink|fuchsia|rose|blue|cyan)-[0-9]+' \
  -e 'from-(slate|zinc|neutral|gray)-[89]00[^"'\''<>]{0,160}to-(slate|zinc|neutral|gray)-[89]00'

run_check GRADIENT_TEXT critical \
  "Solid color; emphasis via weight/size." "" \
  -U \
  -e 'bg-clip-text[^"'\''<>]{0,160}text-transparent' -e 'text-transparent[^"'\''<>]{0,160}bg-clip-text'

run_check GRADIENT_ORB critical \
  "Remove decorative blurred gradient blobs; use neutral surface variation for depth." "" \
  -U \
  -e 'blur-(2xl|3xl)[^"'\''<>]{0,160}(bg-gradient-to|from-[a-z]+-[0-9]{3})' \
  -e '(bg-gradient-to|from-[a-z]+-[0-9]{3})[^"'\''<>]{0,160}blur-(2xl|3xl)'

run_check DEAD_CONTROL critical \
  "Wire a real handler/destination or remove the control." "" \
  -e 'href="#?"' -e "href='#?'" -e 'javascript:void' \
  -e 'on[A-Z][a-zA-Z]*=\{\s*\(\s*\)\s*=>\s*\{\s*\}\s*\}'

run_check DIV_ONCLICK critical \
  "Use <button> for actions, <a> for navigation." "" \
  -U \
  -e '<(div|span)[^>]{0,300}\bonClick' -e '<(div|span)[^>]{0,300}\bonclick=' \
  -e '<(div|span)[^>]{0,300}@click' -e '<(div|span)[^>]{0,300}\bon:click'

run_check SIDE_STRIPE critical \
  "The signature LLM tell. Tinted surface OR a leading dot/chip - one cue; category color goes in a filled dot/label, never an edge bar." \
  'blockquote' \
  -e 'border-(left|inline-start):\s*[2-9]px\s+solid\s+(var\(|#|oklch\(|rgba?\(|hsla?\()' \
  -e '\bborder-s-[1-9][^"'\''<>]{0,80}border-(red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|primary|accent)' \
  -e 'border-l-[1-9][^"'\''<>]{0,80}border-(red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|primary|accent|warning|success|destructive|info)' \
  -e 'border-(red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|primary|accent|warning|success|destructive|info)(-[0-9]+)?[^"'\''<>]{0,80}border-l-[1-9]'

run_check SECTION_BORDER high \
  "Marketing scope: landing pages are one continuous canvas - boundaries from spacing/density, not rules. App-shell seams are legal: allowlist them." "" \
  -U \
  -e '<(section|footer)[^>]{0,200}\bborder-[tby]\b' \
  -e '(^|[,{ ])(section|footer)\s*(,[^{]*)?\{[^}]*border-(top|bottom|block(-(start|end))?)\s*:\s*[0-9]' \
  -e '\.[a-z-]*section[a-z-]*[^{]*\{[^}]*border-(top|bottom|block(-(start|end))?)\s*:\s*[0-9]'

run_check TABINDEX_POSITIVE critical \
  "Fix DOM order instead; tabIndex > 0 breaks natural tab flow." "" \
  -e 'tabIndex=\{?[1-9]' -e 'tabindex="[1-9]'

run_check ZOOM_DISABLED critical \
  "Never disable zoom; fix mobile input font-size (>=16px) instead." "" \
  -e 'user-scalable\s*=\s*no' -e 'maximum-scale\s*=\s*1(\.0*)?(["'\'',> ]|$)'

run_check PASTE_BLOCKED critical \
  "Never block paste in inputs." "" \
  -e 'onPaste=\{[^}]{0,60}preventDefault' -e "addEventListener\\(['\"]paste['\"].{0,80}preventDefault"

# ---- High: system violations ----
run_check H_SCREEN high \
  "Use h-dvh (dynamic viewport) — h-screen breaks on iOS Safari." "" \
  -e '[^-a-z](min-)?h-screen\b' -e '^(min-)?h-screen\b' -e 'height:\s*100vh'

run_check HARDCODED_COLOR high \
  "Move to a semantic token in :root; components use var(--token) / token classes only." \
  '--[a-zA-Z0-9-]+\s*:\s*[^;}]*(#[0-9a-fA-F]|rgba?\(|hsla?\(|oklch\()' \
  -e '\b(bg|text|border|from|to|via|fill|stroke|ring|shadow|outline)-\[(#|rgb|hsl|oklch)' \
  -e '(color|background(-color)?|border(-color)?|fill|stroke|box-shadow|outline)\s*:\s*[^;]*(#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\(|oklch\()'

run_check ARBITRARY_VALUE high \
  "Use the spacing/type scale (4px grid); arbitrary px values break the system." "" \
  -e '\b[pm][trblxy]?-\[[0-9]' -e '\bgap-\[[0-9]' -e '\bspace-[xy]-\[[0-9]' \
  -e '\btext-\[[0-9]+(\.[0-9]+)?(px|rem)' -e '\b[wh]-\[[0-9]{2,}(\.[0-9]+)?px' -e '\bz-\[[0-9]{3}'

run_check TRACKING_TIGHTER high \
  "Tracking floor is -0.03em; below 30px use 0. Exact ladder: design-craft type kernel." "" \
  -e '\btracking-tighter\b' -e 'letter-spacing:\s*-(0\.0(3[1-9]|[4-9])|0\.[1-9]|[1-9])'

run_check LAYOUT_ANIM high \
  "Animate opacity/transform only; layout properties jank. Use FLIP or grid-rows for size changes." "" \
  -e 'transition(-property)?\s*:\s*[^;]*\b(width|height|top|left|margin|padding)\b' \
  -e '\btransition-\[(width|height|top|left|margin|padding)'

# ---- Medium: polish ----
run_check TRANSITION_ALL medium \
  "Specify exact properties: transition-colors / transition-transform / transition-opacity." "" \
  -e '\btransition-all\b' -e 'transition:\s*all\b'

run_check CONSOLE_LOG medium \
  "Remove or gate behind a dev-environment check." \
  'import\.meta\.env|process\.env|NODE_ENV' \
  -e 'console\.(log|warn)\('

# ---- Optional structural checks (ast-grep) ----
SG_BIN=""
for c in ast-grep sg; do
  if command -v "$c" >/dev/null 2>&1 && "$c" --version 2>/dev/null | grep -qi 'ast-grep'; then SG_BIN="$c"; break; fi
done
if [ -n "$SG_BIN" ] && [ -d "$(dirname "$0")/../rules" ]; then
  SG_OUT=$("$SG_BIN" scan --config "$(dirname "$0")/../sgconfig.yml" --json "$TARGET" 2>"$TMP/sg.err") \
    || die "ast-grep scan failed: $(head -1 "$TMP/sg.err")"
  # Structural rules map onto the same canonical categories as their lexical peers so dedup merges them.
  printf '%s' "$SG_OUT" | jq -c --arg tgt "$TARGET" '
    .[]? | {category:(if .ruleId == "div-with-onclick" then "DIV_ONCLICK"
                      else ("SG_" + (.ruleId | ascii_upcase | gsub("-";"_"))) end),
      severity:"critical",
      fix:(.message // "structural rule"),
      file:(.file | if startswith($tgt) then .[($tgt|length):] | ltrimstr("/") else . end),
      line:((.range.start.line // 0) + 1),
      content:((.text // "") | gsub("[\\n\\t]";" ") | .[0:200])}
  ' >> "$FINDINGS" || die "ast-grep output is not valid JSON"
fi

# ---- Dedup ----
jq -cs 'unique_by(.category, .file, .line) | .[]' "$FINDINGS" > "$TMP/dedup.jsonl" || die "dedup failed"
mv "$TMP/dedup.jsonl" "$FINDINGS"

# ---- Allowlist ----
if [ -n "$ALLOWLIST" ]; then
  [ -f "$ALLOWLIST" ] || die "allowlist file not found: $ALLOWLIST"
  RULES="$TMP/allow.json"; : > "$RULES"
  lineno=0
  while IFS= read -r row || [ -n "$row" ]; do
    lineno=$((lineno+1))
    case "$row" in ''|'#'*) continue ;; esac
    cat_=$(printf '%s' "$row" | awk -F'\t' '{print $1}')
    re_=$(printf '%s' "$row" | awk -F'\t' '{print $2}')
    reason_=$(printf '%s' "$row" | awk -F'\t' '{print $3}')
    { [ -n "$cat_" ] && [ -n "$re_" ] && [ -n "$reason_" ]; } || die "allowlist line $lineno: need CATEGORY<TAB>PATH_REGEX<TAB>REASON"
    jq -ne --arg re "$re_" '("x" | test($re)) or true' >/dev/null 2>&1 || die "allowlist line $lineno: invalid regex: $re_"
    jq -nc --arg cat "$cat_" --arg re "$re_" '{cat:$cat,re:$re}' >> "$RULES"
  done < "$ALLOWLIST"
  jq -cs --slurpfile rules "$RULES" '
    map(select(. as $f
      | ([ $rules[] | . as $r | select(($r.cat == "*" or $r.cat == $f.category) and ($f.file | test($r.re))) ] | length) == 0)) | .[]
  ' "$FINDINGS" > "$TMP/filtered.jsonl" 2>/dev/null || die "allowlist contains an invalid regex"
  mv "$TMP/filtered.jsonl" "$FINDINGS"
fi

# ---- Report ----
DOC=$(jq -s --arg target "$TARGET" --argjson scanned "$SCANNED" --argjson crit_only "$CRITICAL_ONLY" '
  ( if $crit_only == 1 then map(select(.severity == "critical")) else . end ) as $issues
  | ($issues | map(select(.severity=="critical")) | length) as $c
  | ($issues | map(select(.severity=="high")) | length) as $h
  | ($issues | map(select(.severity=="medium")) | length) as $m
  | { status: (if ($issues|length) > 0 then "fail" else "pass" end),
      target: $target, scannedFiles: $scanned,
      support: {lexical:["tsx","jsx","ts","js","css","scss","html","vue","svelte","astro","mdx"], structural:"ast-grep optional (tsx/jsx/html)"},
      total: ($issues|length), critical: $c, high: $h, medium: $m,
      score: ([0, (100 - 10*$c - 3*$h - $m)] | max),
      categories: ($issues | group_by(.category) | map({key: .[0].category, value: length}) | from_entries),
      issues: $issues }
' "$FINDINGS") || die "report assembly failed"
printf '%s' "$DOC" | jq -e . >/dev/null 2>&1 || die "generated JSON failed validation"

if [ "$JSON" -eq 1 ]; then
  printf '%s\n' "$DOC"
else
  printf '%s' "$DOC" | jq -r '
    "design-scan: " + .target + " — " + (.scannedFiles|tostring) + " files, "
      + (.total|tostring) + " findings (score " + (.score|tostring) + ", advisory)",
    ( .issues | group_by(.severity) | sort_by(.[0].severity) | .[] |
      "\n[" + (.[0].severity | ascii_upcase) + "]",
      ( .[] | "  " + .category + "  " + .file + ":" + (.line|tostring) + "\n    " + .content + "\n    fix: " + .fix ) )
  '
fi

TOTAL=$(printf '%s' "$DOC" | jq -r '.total')
[ "$TOTAL" -gt 0 ] && exit 1
exit 0
