#!/usr/bin/env bash
# Index design and design-builder child sessions into a TSV, one row per session.
# Usage: evals/retro/index.sh [OUT.tsv]   (default: ~/.pi/artifacts/retro/sessions.tsv)
# Skills count as loaded only when their text came back in a tool result: a frontmatter block
# that holds a "name: <skill>" and a "description:" line, in any order (or the two lines adjacent), or a section of a
# <skill>/SKILL.md read whose result holds a markdown heading, or a read of one file under
# skills/<skill>/references/ whose returned lines match that file on disk. Paths in call arguments alone
# do not count (a read can fail, be cut by the tool-result cap, or name a template).
# Passes come from the report artifact the final RESULT message names; the final message itself
# is the fallback. Exit 1 on unreadable input, a failed write or a PARSE_FAIL row.
set -o pipefail
OUT=${1:-$HOME/.pi/artifacts/retro/sessions.tsv}
case $OUT in /*) ;; *) OUT=$PWD/$OUT;; esac
SESSIONS=${PI_SESSIONS_DIR:-$HOME/.pi/agent/sessions}
RETRO=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$(dirname "$OUT")" || exit 1
cd "$SESSIONS" || exit 1
LIST=$(mktemp) || exit 1
trap 'rm -f "$LIST"' EXIT
rg -l -m1 '"customType":"pi-subagents_launch_metadata".*"agent":"design(-builder)?"' -g '*.jsonl' . > "$LIST"
[ $? -le 1 ] || { echo "index: session search failed in $SESSIONS" >&2; exit 1; }
# rg walks folders in parallel, so its file order changes between runs. Sort for a stable row order.
sort -o "$LIST" "$LIST"
printf 'start\tagent\tmodel\tbytes\tturns\tuser_msgs\tpeak_ctx\tout_tok\tcost\tdur_min\terrors\tbrowser_cmds\tskills_returned\tskill_count\tasks\tpasses_applied\tpasses_na\tpasses\tresult\ttitle\tfile\n' > "$OUT" \
  || { echo "index: cannot write $OUT" >&2; exit 1; }
PARSE_FAILS=0
# A reference read counts when at least 3 of its returned lines (8 or more characters; first 40) are lines of
# the file, and they are at least half of those lines: tool notes and a cut last line do not break a match.
REF_MIN_LINES=3
ref_skills() { # session file -> comma list of skills whose reference file content came back
  local skill path text n m found=""
  while IFS=$'\t' read -r skill path text; do
    path=${path/#\~/$HOME}
    [ -f "$path" ] || continue
    n=0; m=0
    while IFS= read -r line; do
      n=$((n+1)); grep -qxF -- "$line" "$path" && m=$((m+1))
    done < <(printf '%s' "$text" | base64 -D | sed 's/\r$//' | awk 'length($0) >= 8' | head -40)
    [ "$m" -ge "$REF_MIN_LINES" ] && [ $((m*2)) -ge "$n" ] && found="$found,$skill"
  done < <(jq -rs '
    ([ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall")
       | {key: .id, value: (.arguments|tostring)} ] | from_entries) as $args
    | .[] | select(.type=="message" and .message.role=="toolResult" and .message.isError != true)
    | ([ ($args[.message.toolCallId] // "") | scan("((?:~|/)[^\"\\\\\\s]*/skills/([A-Za-z0-9._-]+)/references/[A-Za-z0-9._/-]+\\.md)") ] | unique_by(.[0])) as $p
    | select(($p|length)==1)
    | [ $p[0][1], $p[0][0], ([.message.content[]? | select(.type=="text") | .text] | join("\n") | @base64) ] | @tsv' "$1" 2>/dev/null)
  printf '%s' "${found#,}"
}
while read -r f; do
  bytes=$(stat -f %z "$f")
  refs=$(ref_skills "$f")
  jq -L "$RETRO" -rs --arg f "$f" --arg bytes "$bytes" --arg refs "$refs" '
    include "passes";
    def calls: [.[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall")];
    def results: [.[] | select(.type=="message" and .message.role=="toolResult")];
    def ok_results: [results[] | select(.message.isError != true)];
    def text_of: [.message.content[]? | select(.type=="text") | .text] | join("\n");
    # A section: a markdown heading followed by a body line (a heading list holds no section).
    def holds_section: split("\n") | map(sub("^[0-9]+[:-]";"")) | (map(test("^#{2,6} \\S")) | index(true)) as $h
      | $h != null and (.[($h+1):] | any(test("\\S") and (test("^#{1,6} ") | not) and (. != "--")));
    # A report line "RESULT: X" with a filled value (a template line holds "|" alternatives).
    def result_of: [ split("\n")[] | select(test("^RESULT:") and (test("\\|") | not)) | capture("^RESULT:\\s*(?<r>[A-Z]+)").r ] | first // "none";
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
    | (($fm + $pair + $sec + ($refs | split(",") | map(select(. != "")))) | unique) as $sk
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
