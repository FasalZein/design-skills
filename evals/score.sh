#!/usr/bin/env bash
# Score eval runs against spec Acceptance 4, one line per run.
# Usage: evals/score.sh <sessions.tsv> <runs.tsv>
#   sessions.tsv  the retro index (evals/retro/index.sh output)
#   runs.tsv      one run per line: run<TAB>part<TAB>model<TAB>session file (absolute path); # starts a comment
# Expected loads per part: evals/briefs/<part>.expected (EXPECTED_DIR overrides the folder).
# Per run it reports:
#   text        every "must" skill and every applied pass skill came back as text in a tool result
#   unexpected  no other skill came back: not a forbidden one, not an n/a pass, not one the expected file omits
#   passes      PASSES has a result for every "pass" line of the part's level
#   static      the design-qa scanner (design-scan) ran
#   report      a report exists: the final RESULT message, or a written report with RESULT and PASSES lines
#   shots       screenshots came from agent-browser-chrome, none from plain agent-browser or another tool
#   cost, peak_ctx, result  from the index; ambiguous = expected-file "ambiguous" skills that came back
# Exit 0 when every run is scored (FAIL items included), 1 on unreadable input or an unknown part.
set -o pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
TSV=${1:?usage: score.sh <sessions.tsv> <runs.tsv>}
RUNS=${2:?usage: score.sh <sessions.tsv> <runs.tsv>}
EXPECTED_DIR=${EXPECTED_DIR:-$HERE/briefs}
for f in "$TSV" "$RUNS"; do [ -r "$f" ] || { echo "score: cannot read $f" >&2; exit 1; }; done

# Column of the index row whose file column is a suffix of the session path.
row_for() { awk -F'\t' -v s="$1" 'NR==1{for(i=1;i<=NF;i++) h[$i]=i; next}
  { f=$(h["file"]); sub(/^\.\//,"",f); if (f!="" && (s==f || substr(s, length(s)-length(f))==("/" f))) {print; exit} }' "$TSV"; }
col() { awk -F'\t' -v c="$2" 'NR==1{for(i=1;i<=NF;i++) if($i==c) print i; exit}' "$TSV" | { read -r n; printf '%s\n' "$1" | cut -f"$n"; }; }
# Skills of one kind in an expected file.
kind() { awk -v k="$2" '$1==k {print $2}' "$1"; }
in_list() { case ",$2," in *",$1,"*) return 0;; esac; return 1; }
join() { paste -sd, -; }

FAILED_RUNS=0; N=0
while IFS=$'\t' read -r run part model session; do
  case "$run" in ''|'#'*) continue;; esac
  N=$((N+1))
  exp="$EXPECTED_DIR/$part.expected"
  [ -r "$exp" ] || { echo "score: no expected file for part '$part' ($exp)" >&2; exit 1; }
  [ -r "$session" ] || { echo "score: cannot read session $session" >&2; exit 1; }
  row=$(row_for "$session")
  if [ -z "$row" ]; then echo "$run $part $model FAIL: session not in $TSV"; FAILED_RUNS=$((FAILED_RUNS+1)); continue; fi
  returned=$(col "$row" skills_returned); passes=$(col "$row" passes); result=$(col "$row" result)
  cost=$(col "$row" cost); peak=$(col "$row" peak_ctx)
  # A run stopped before its final RESULT message has no PASSES in the index: read the last written report.
  [ -n "$passes" ] || passes=$(jq -rs '[ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]?
      | select(.type=="toolCall" and .name=="write") | .arguments.content // ""
      | select(test("(^|\n)RESULT:") and test("(^|\n)PASSES:")) ] | last // ""
    | split("\n") as $l | ($l | map(test("^PASSES:")) | index(true)) as $i
    | if $i == null then "" else
        ([ $l[$i] | sub("^PASSES:\\s*";"") ] + ($l[($i+1):] | (map(test("^[A-Z]+:")) | index(true)) as $j | if $j == null then . else .[0:$j] end))
        | map(select(test("\\S"))) | join("; ") end' "$session")

  # Pass outcomes: "<pass> -> applied|n/a: <change>" entries; the pass names its skill.
  applied=""; na=""; missing_pass=""
  for p in $(kind "$exp" pass); do
    st=$(printf '%s\n' "$passes" | tr ';' '\n' | awk -v p="$p" '{split($0,a," -> "); n=a[1]; gsub(/^ +| +$/,"",n)}
      tolower(n) ~ ("(^|[^a-z0-9-])" p "([^a-z0-9-]|$)") { if (match($0, / -> (applied|n\/a):/)) { s=substr($0,RSTART+4,RLENGTH-5); print s; exit } }')
    case "$st" in applied) applied="$applied,$p";; n/a) na="$na,$p";; *) missing_pass="$missing_pass,$p";; esac
  done

  # text: must skills and applied passes came back.
  missing_text=""
  for s in $(kind "$exp" must) $(echo "$applied" | tr ',' ' '); do in_list "$s" "$returned" || missing_text="$missing_text,$s"; done
  # unexpected: anything returned that is not must, applied pass, allow or ambiguous.
  ok_set=",$(kind "$exp" must | join),$(kind "$exp" allow | join),$(kind "$exp" ambiguous | join)$applied,"
  unexpected=""; amb=""
  for s in $(echo "$returned" | tr ',' ' '); do
    in_list "$s" "$(kind "$exp" ambiguous | join)" && amb="$amb,$s"
    in_list "$s" "$ok_set" || unexpected="$unexpected,$s"
  done

  # Checks from the session's own tool calls (bash commands and codemode code), split into shell segments.
  read -r scan tsc chrome plain other report_written < <(jq -rs '
    [ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall") ] as $calls
    | [ $calls[] | select(.name=="bash" or .name=="codemode") | [.arguments | .. | strings] | join("\n")
        | split("\n")[] | splits("&&|\\|\\||;|\\|") ] as $seg
    | def n(re): ([ $seg[] | select(test(re)) ] | length);
    ([ $calls[] | select(.name=="write") | .arguments.content // "" | select(test("(^|\n)RESULT:") and test("(^|\n)PASSES:")) ] | length) as $rw
    | [ n("design-scan"), n("\\btsc\\b|typecheck|npm run build"),
        n("agent-browser-chrome\\b.*\\b(screenshot|batch)\\b"),
        n("(^|[^-\\w/])agent-browser\\s.*\\bscreenshot\\b"),
        n("screencapture|\\.screenshot\\(|playwright\\s+screenshot"), $rw ] | @tsv' "$session")
  [ -n "$scan" ] || { echo "score: cannot parse session $session" >&2; exit 1; }

  item() { if [ -z "$2" ]; then printf ' %s=ok' "$1"; else printf ' %s=FAIL(%s)' "$1" "$2"; fi; }
  pf=""; [ -n "$missing_pass" ] && pf="missing:${missing_pass#,}"
  line="$run $part $model"
  line="$line$(item text "${missing_text:+missing:${missing_text#,}}")"
  line="$line$(item unexpected "${unexpected#,}")"
  line="$line$(item passes "$pf")"
  line="$line$( [ "$scan" -gt 0 ] && printf ' static=ok(scan=%s,tsc=%s)' "$scan" "$tsc" || printf ' static=FAIL(scan=0,tsc=%s)' "$tsc")"
  line="$line$( { [ "$result" != none ] && [ -n "$result" ]; } || [ "$report_written" -gt 0 ] && printf ' report=ok' || printf ' report=FAIL')"
  line="$line$( [ "$chrome" -gt 0 ] && [ "$plain" -eq 0 ] && [ "$other" -eq 0 ] && printf ' shots=ok(chrome=%s)' "$chrome" || printf ' shots=FAIL(chrome=%s,plain=%s,other=%s)' "$chrome" "$plain" "$other")"
  line="$line cost=\$$cost peak_ctx=$peak result=$result ambiguous=[${amb#,}]"
  echo "$line"
  case "$line" in *FAIL*) FAILED_RUNS=$((FAILED_RUNS+1));; esac
done < "$RUNS"
echo "score: $N runs, $FAILED_RUNS with a FAIL item"
