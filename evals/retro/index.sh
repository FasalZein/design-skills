#!/usr/bin/env bash
# Index design and design-builder child sessions into a TSV, one row per session.
# Usage: evals/retro/index.sh [OUT.tsv]   (default: ~/.pi/artifacts/retro/sessions.tsv)
# Skills count as loaded only when their text came back in a tool result: a frontmatter
# "name: <skill>" line directly followed by a "description:" line. Paths in call arguments
# do not count (a read can fail, be cut by the tool-result cap, or name a template).
set -o pipefail
OUT=${1:-$HOME/.pi/artifacts/retro/sessions.tsv}
SESSIONS=${PI_SESSIONS_DIR:-$HOME/.pi/agent/sessions}
mkdir -p "$(dirname "$OUT")"
cd "$SESSIONS" || exit 1
LIST=$(mktemp)
rg -l -m1 '"customType":"pi-subagents_launch_metadata".*"agent":"design(-builder)?"' -g '*.jsonl' . > "$LIST"
printf 'start\tagent\tmodel\tbytes\tturns\tuser_msgs\tpeak_ctx\tout_tok\tcost\tdur_min\terrors\tbrowser_cmds\tskills_returned\tskill_count\tasks\tpasses_applied\tpasses_na\tresult\ttitle\tfile\n' > "$OUT"
while read -r f; do
  bytes=$(stat -f %z "$f")
  jq -rs --arg f "$f" --arg bytes "$bytes" '
    def calls: [.[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall")];
    (map(select(.customType=="pi-subagents_launch_metadata"))[0].data) as $m
    | (map(select(.type=="message" and .message.role=="assistant"))) as $a
    | (map(select(.type=="message" and .message.role=="user")) | length) as $u
    | ([ $a[] | .message.usage | ((.input//0)+(.cacheRead//0)+(.cacheWrite//0)) ] | max // 0) as $peak
    | ([ $a[] | .message.usage.output // 0 ] | add // 0) as $out
    | ([ $a[] | .message.usage.cost.total // 0 ] | add // 0) as $cost
    | ([ .[] | .timestamp? // empty | select(type=="string") ]) as $ts
    | ([ .[] | select(.type=="message" and .message.role=="toolResult" and (.message.isError==true)) ] | length) as $err
    | ([ calls[] | (.arguments|tostring) ]) as $c
    | ([ $c[] | scan("agent-browser[a-z-]*") ] | length) as $br
    | ([ $c[] | scan("ask_user") ] | length) as $asks
    | ([ .[] | select(.type=="message" and .message.role=="toolResult") | .message.content[]? | select(.type=="text") | .text
         | split("\n") as $l | range(0; ($l|length)-1) as $i
         | select(($l[$i]|test("^name: *[A-Za-z0-9._-]+ *$")) and ($l[$i+1]|test("^description:")))
         | $l[$i] | sub("^name: *";"") | sub(" *$";"") ] | unique) as $sk
    | ([ $a[] | .message.content[]? | select(.type=="text") | .text ] | map(select(test("RESULT:"))) | last // "") as $rep
    | ($rep | capture("RESULT:\\s*(?<r>[A-Z]+)")?.r // "none") as $res
    | ([ $rep | scan("-> *applied:") ] | length) as $pa
    | ([ $rep | scan("-> *n/a:") ] | length) as $pn
    | [ ($ts[0] // "")[0:16], $m.agent, ($m.modelRef // $m.model // ""), $bytes, ($a|length), $u, $peak, $out, ($cost*100|round/100),
        (if ($ts|length)>1 then (((($ts|last)|sub("\\.[0-9]+Z$";"Z")|fromdate) - (($ts[0])|sub("\\.[0-9]+Z$";"Z")|fromdate))/60|floor) else 0 end),
        $err, $br, ($sk|join(",")), ($sk|length), $asks, $pa, $pn, $res, ($m.title // "" | gsub("[\t\n]";" ")), $f ] | @tsv' "$f" 2>"${ERRLOG:-/dev/null}" || printf 'PARSE_FAIL\t%s\n' "$f"
done < "$LIST" >> "$OUT"
rm -f "$LIST"
echo "index: $(($(wc -l < "$OUT") - 1)) sessions -> $OUT"
