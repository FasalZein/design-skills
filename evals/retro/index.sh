#!/usr/bin/env bash
# Index design and design-builder child sessions into a TSV, one row per session.
# Usage: evals/retro/index.sh [OUT.tsv]   (default: ~/.pi/artifacts/retro/sessions.tsv)
# Skills count as loaded only when their text came back in a tool result: a frontmatter block
# that holds a "name: <skill>" and a "description:" line, in any order (or the two lines adjacent), or a section of a
# <skill>/SKILL.md read whose result holds a markdown heading. Paths in call arguments alone
# do not count (a read can fail, be cut by the tool-result cap, or name a template).
# Passes come from the report artifact the final RESULT message names; the final message itself
# is the fallback. Exit 1 on unreadable input, a failed write or a PARSE_FAIL row.
set -o pipefail
OUT=${1:-$HOME/.pi/artifacts/retro/sessions.tsv}
case $OUT in /*) ;; *) OUT=$PWD/$OUT;; esac
SESSIONS=${PI_SESSIONS_DIR:-$HOME/.pi/agent/sessions}
mkdir -p "$(dirname "$OUT")" || exit 1
cd "$SESSIONS" || exit 1
LIST=$(mktemp) || exit 1
trap 'rm -f "$LIST"' EXIT
rg -l -m1 '"customType":"pi-subagents_launch_metadata".*"agent":"design(-builder)?"' -g '*.jsonl' . > "$LIST"
[ $? -le 1 ] || { echo "index: session search failed in $SESSIONS" >&2; exit 1; }
printf 'start\tagent\tmodel\tbytes\tturns\tuser_msgs\tpeak_ctx\tout_tok\tcost\tdur_min\terrors\tbrowser_cmds\tskills_returned\tskill_count\tasks\tpasses_applied\tpasses_na\tpasses\tresult\ttitle\tfile\n' > "$OUT" \
  || { echo "index: cannot write $OUT" >&2; exit 1; }
PARSE_FAILS=0
while read -r f; do
  bytes=$(stat -f %z "$f")
  jq -rs --arg f "$f" --arg bytes "$bytes" '
    def calls: [.[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall")];
    def results: [.[] | select(.type=="message" and .message.role=="toolResult")];
    def ok_results: [results[] | select(.message.isError != true)];
    def text_of: [.message.content[]? | select(.type=="text") | .text] | join("\n");
    # A section: a markdown heading followed by a body line (a heading list holds no section).
    def holds_section: split("\n") | map(sub("^[0-9]+[:-]";"")) | (map(test("^#{2,6} \\S")) | index(true)) as $h
      | $h != null and (.[($h+1):] | any(test("\\S") and (test("^#{1,6} ") | not) and (. != "--")));
    # A report line "RESULT: X" with a filled value (a template line holds "|" alternatives).
    def result_of: [ split("\n")[] | select(test("^RESULT:") and (test("\\|") | not)) | capture("^RESULT:\\s*(?<r>[A-Z]+)").r ] | first // "none";
    # PASSES entries "<pass> -> applied: <change>" or "<pass> -> n/a: <fact>", up to the next report field.
    # An empty change or fact is an unfilled entry: the capture requires a non-space first character.
    def passes_of: (split("\n") | (map(test("^PASSES:")) | index(true)) as $i
      | if $i == null then [] else .[$i:] | (.[0] |= sub("^PASSES:\\s*";"")) | .[0:1] + (.[1:] | until(length==0 or (.[0]|test("^[A-Z]+:")); .[1:]) as $rest | .[0:(length - ($rest|length))]) end
      | map(capture("^\\s*(?<pass>[^<>|\\s][^<>|]*?)\\s*->\\s*(?<status>applied|n/a):\\s*(?<change>[^<>|\\s][^<>|]*?)\\s*$")));
    (map(select(.customType=="pi-subagents_launch_metadata"))[0].data) as $m
    | (map(select(.type=="message" and .message.role=="assistant"))) as $a
    | (map(select(.type=="message" and .message.role=="user")) | length) as $u
    | ([ $a[] | .message.usage | ((.input//0)+(.cacheRead//0)+(.cacheWrite//0)) ] | max // 0) as $peak
    | ([ $a[] | .message.usage.output // 0 ] | add // 0) as $out
    | ([ $a[] | .message.usage.cost.total // 0 ] | add // 0) as $cost
    | ([ .[] | .timestamp? // empty | select(type=="string") ]) as $ts
    | ([ .[] | select(.type=="message" and .message.role=="toolResult" and (.message.isError==true)) ] | length) as $err
    | calls as $calls
    | ([ $calls[] | {key: .id, value: (.arguments|tostring)} ] | from_entries) as $argsById
    | ([ $calls[] | (.arguments|tostring) ]) as $c
    | ([ $c[] | scan("agent-browser[a-z-]*") ] | length) as $br
    | ([ $calls[] | select(.name=="ask_user") ] | length
       + ([ $calls[] | select(.name=="codemode") | (.arguments.code // "") | scan("tools\\.ask_user\\s*\\(") ] | length)) as $asks
    # Every pair of adjacent "---" lines, so a body rule cannot hide the next skill'"'"'s frontmatter.
    | ([ results[] | text_of | split("\n") as $l | [range(0; $l|length) | select($l[.]=="---")] as $fx
         | range(0; ($fx|length)-1) as $k | $l[($fx[$k]+1):$fx[$k+1]] | join("\n")
         | select(test("(^|\n)description:")) | capture("(^|\n)name: *(?<n>[A-Za-z0-9._-]+) *(\n|$)")?.n ]) as $fm
    # Also a "name:" line directly followed by "description:" (a fence glued to other output, a cut result).
    | ([ results[] | text_of | split("\n") as $l | range(0; ($l|length)-1) as $i
         | select(($l[$i]|test("^name: *[A-Za-z0-9._-]+ *$")) and ($l[$i+1]|test("^description:")))
         | $l[$i] | sub("^name: *";"") | sub(" *$";"") ]) as $pair
    | ([ ok_results[] | select(text_of | holds_section)
         | ($argsById[.message.toolCallId] // "") | [scan("(?:^|/)([A-Za-z0-9._-]+)/SKILL\\.md") | .[0]] | unique
         | select(length==1) | .[0] ]) as $sec
    | (($fm + $pair + $sec) | unique) as $sk
    | ([ $a[] | .message.content[]? | select(.type=="text") | .text ] | map(select(test("(^|\n)RESULT:"))) | last // "") as $final
    | ($final | capture("(^|\n)ARTIFACT:\\s*(?<p>/[^\n]*?)\\s*(\n|$)")?.p // "") as $art
    | ([ $calls[] | select(.name=="write" and $art != "" and .arguments.path == $art) | .arguments.content ] | last // $final) as $rep
    | ($rep | passes_of) as $ps
    | ($final | result_of) as $res
    | [ ($ts[0] // "")[0:16], $m.agent, ($m.modelRef // $m.model // ""), $bytes, ($a|length), $u, $peak, $out, ($cost*100|round/100),
        (if ($ts|length)>0 then (((($ts|last)|sub("\\.[0-9]+Z$";"Z")|fromdate) - (($ts[0])|sub("\\.[0-9]+Z$";"Z")|fromdate))/60|floor) else 0 end),
        $err, $br, ($sk|join(",")), ($sk|length), $asks,
        ([ $ps[] | select(.status=="applied") ] | length), ([ $ps[] | select(.status=="n/a") ] | length),
        ([ $ps[] | "\(.pass) -> \(.status): \(.change)" ] | join("; ") | gsub("[\t\n]";" ")),
        $res, ($m.title // "" | gsub("[\t\n]";" ")), $f ] | @tsv' "$f" 2>"${ERRLOG:-/dev/null}" \
    || { printf 'PARSE_FAIL\t%s\n' "$f"; PARSE_FAILS=$((PARSE_FAILS+1)); }
done < "$LIST" >> "$OUT" || { echo "index: cannot write $OUT" >&2; exit 1; }
echo "index: $(($(wc -l < "$OUT") - 1)) sessions -> $OUT"
[ "$PARSE_FAILS" -eq 0 ] || { echo "index: $PARSE_FAILS PARSE_FAIL row(s)" >&2; exit 1; }
