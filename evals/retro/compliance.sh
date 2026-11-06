#!/usr/bin/env bash
# Per-session checks and a batch summary for design and design-builder sessions since a start time.
# Usage: evals/retro/compliance.sh [SINCE] [sessions.tsv]   (SINCE like 2026-10-23T13; TSV from index.sh)
# Exit 1 on unreadable input, PARSE_FAIL rows, or applied passes without their own skill text.
set -o pipefail
SINCE=${1:-2026-10-23T13}
TSV=${2:-$HOME/.pi/artifacts/retro/sessions.tsv}
case $TSV in /*) ;; *) TSV=$PWD/$TSV;; esac
SESSIONS=${PI_SESSIONS_DIR:-$HOME/.pi/agent/sessions}
RETRO=$(cd "$(dirname "$0")" && pwd)
[ -f "$TSV" ] && [ -r "$TSV" ] || { echo "compliance: cannot read $TSV" >&2; exit 1; }
cd "$SESSIONS" || exit 1
FAILS=$(grep -c '^PARSE_FAIL' "$TSV")
[ "$FAILS" -eq 0 ] || echo "compliance: $TSV holds $FAILS PARSE_FAIL row(s)" >&2
# Empty fields become "-": read with IFS=tab would merge them.
ROWS=$(awk -F'\t' -v OFS='\t' -v s="$SINCE" 'NR>1 && $1>=s && ($2=="design"||$2=="design-builder") {for(i=1;i<=NF;i++) if($i=="") $i="-"; print}' "$TSV" | sort) || exit 1
echo "== sessions since $SINCE: $(printf '%s\n' "$ROWS" | grep -c .)"
while IFS=$'\t' read -r start agent model _ _ user _ _ _ _ _ _ returned _ asks _ _ _ _ _ f; do
  [ -n "$f" ] || continue
  # Freeze codemode reports beside the session, as in score.sh; never parse JavaScript source.
  report=${f%.jsonl}.report.md
  [ -f "$report" ] || report=/dev/null
  output=$(jq -L "$RETRO" --rawfile frozen "$report" -rs --arg start "$start" --arg agent "$agent" --arg model "${model%%:*}" --arg returned "$returned" --arg user "$user" --arg asks "$asks" '
    include "passes";
    [ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall") | (.arguments|tostring) ] as $c
    | def n(re): ([ $c[] | select(test(re)) ] | length);
    ([ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text | select(test("(SKILLS|LOADED):")) ] | last // "" | capture("(SKILLS|LOADED):(?<s>[^\n]*)")?.s // "-") as $claim
    | ([ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text | select(test("(^|\n)RESULT:")) ] | last // "") as $final
    | ($final | capture("(^|\n)ARTIFACT:\\s*(?<p>/[^\n]*?)\\s*(\n|$)")?.p // "") as $art
    | (if ($final|test("(^|\n)PASSES:")) then $final elif $frozen != "" then $frozen
       else [ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall" and .name=="write" and $art != "" and .arguments.path==$art) | .arguments.content ] | last // $final end) as $rep
    | ($rep | split("\n") | (map(test("^LOADED:")) | index(true)) as $i
       | if $i == null then $claim else .[$i:] | .[0] |= sub("^LOADED:";"")
         | .[0:1] + (.[1:] | until(length==0 or (.[0]|test("^[A-Z]+:")); .[1:]) as $rest | .[0:(length-($rest|length))])
         | map(select(test("\\S"))) | join("; ") end) as $claim
    | ($rep | passes_of | map(.pass |= sub("^[-*]\\s+";""))) as $ps
    # The index supplies the same evidence, including matched reference-file reads. LOADED is not evidence.
    | ($returned | split(",")) as $skills
    | [ $ps[] | select(.status=="applied") | select(.pass as $p | $skills | index($p) | not) ] as $mismatches
    | ([ $ps[] | select(.status=="applied") ] | length | tostring) as $pa
    | ([ $ps[] | select(.status=="n/a") ] | length | tostring) as $pn
    | ([$start, $agent, $model, "scan=\(n("design-scan"))", "shots=\(n("screenshot"))", "chrome=\(n("agent-browser-chrome"))", "plainAB=\(n("(^|[^-])agent-browser (open|screenshot|snapshot|click)"))", "tsc=\(n("tsc|typecheck"))", "followups=\(($user|tonumber) - 1)", "asks=\($asks)", "passes=\($pa) applied/\($pn) n/a", "returned=[\($returned)]", "claimed=[\($claim)]"] | join(" ")),
      ($mismatches[] | "MISMATCH \($start) \($agent) \($model) pass=[\(.pass)] applied without own skill text")' "$f") || FAILS=$((FAILS+1))
  printf '%s\n' "$output"
  if printf '%s\n' "$output" | grep -q '^MISMATCH '; then FAILS=$((FAILS+1)); fi
done <<EOF
$ROWS
EOF
echo "== summary by agent and model (skills = skill texts returned in tool results)"
printf '%s\n' "$ROWS" | awk -F'\t' 'NF>1 {k=$2" "substr($3,1,index($3":",":")-1); n[k]++; c[k]+=$9; if($7>p[k])p[k]=$7; s[k]+=$14; if($14==0)z[k]++; f[k]+=$6-1}
  END {for (k in n) printf "%s: runs=%d cost=$%.2f peak_ctx_max=%d skills_mean=%.1f zero_skill_runs=%d followups=%d\n", k, n[k], c[k], p[k], s[k]/n[k], z[k]+0, f[k]}' | sort
[ "$FAILS" -eq 0 ] || exit 1
