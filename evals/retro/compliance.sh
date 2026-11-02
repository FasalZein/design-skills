#!/usr/bin/env bash
# Per-session checks and a batch summary for design and design-builder sessions since a start time.
# Usage: evals/retro/compliance.sh [SINCE] [sessions.tsv]   (SINCE like 2026-10-23T13; TSV from index.sh)
set -o pipefail
SINCE=${1:-2026-10-23T13}
TSV=${2:-$HOME/.pi/artifacts/retro/sessions.tsv}
SESSIONS=${PI_SESSIONS_DIR:-$HOME/.pi/agent/sessions}
cd "$SESSIONS" || exit 1
# Empty fields become "-": read with IFS=tab would merge them.
ROWS=$(awk -F'\t' -v OFS='\t' -v s="$SINCE" 'NR>1 && $1>=s && ($2=="design"||$2=="design-builder") {for(i=1;i<=NF;i++) if($i=="") $i="-"; print}' "$TSV" | sort)
echo "== sessions since $SINCE: $(printf '%s\n' "$ROWS" | grep -c .)"
printf '%s\n' "$ROWS" | while IFS=$'\t' read -r start agent model _ _ user _ _ _ _ _ _ returned _ asks pa pn _ _ f; do
  [ -n "$f" ] || continue
  jq -rs --arg start "$start" --arg agent "$agent" --arg model "${model%%:*}" --arg returned "$returned" --arg user "$user" --arg asks "$asks" --arg pa "$pa" --arg pn "$pn" '
    [ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall") | (.arguments|tostring) ] as $c
    | def n(re): ([ $c[] | select(test(re)) ] | length);
    ([ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text | select(test("(SKILLS|LOADED):")) ] | last // "" | capture("(SKILLS|LOADED):(?<s>[^\n]*)")?.s // "-") as $claim
    | [$start, $agent, $model, "scan=\(n("design-scan"))", "shots=\(n("screenshot"))", "chrome=\(n("agent-browser-chrome"))", "plainAB=\(n("(^|[^-])agent-browser (open|screenshot|snapshot|click)"))", "tsc=\(n("tsc|typecheck"))", "followups=\(($user|tonumber) - 1)", "asks=\($asks)", "passes=\($pa) applied/\($pn) n/a", "returned=[\($returned)]", "claimed=[\($claim|.[0:200])]"] | join(" ")' "$f"
done
echo "== summary by agent and model (skills = skill texts returned in tool results)"
printf '%s\n' "$ROWS" | awk -F'\t' 'NF>1 {k=$2" "substr($3,1,index($3":",":")-1); n[k]++; c[k]+=$9; if($7>p[k])p[k]=$7; s[k]+=$14; if($14==0)z[k]++; f[k]+=$6-1}
  END {for (k in n) printf "%s: runs=%d cost=$%.2f peak_ctx_max=%d skills_mean=%.1f zero_skill_runs=%d followups=%d\n", k, n[k], c[k], p[k], s[k]/n[k], z[k]+0, f[k]}' | sort
