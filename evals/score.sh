#!/usr/bin/env bash
# Score eval runs against spec Acceptance 4, one line per run.
# Usage: evals/score.sh <sessions.tsv> <runs.tsv>
#   sessions.tsv  the retro index (evals/retro/index.sh output)
#   runs.tsv      one run per line: run<TAB>part<TAB>model<TAB>session file (absolute path); # starts a comment
# Expected loads per part: evals/briefs/<part>.expected (EXPECTED_DIR overrides the folder).
# A design-app or design-marketing run scores the design session against its own .expected, then adds:
#   decision    its final message or report file holds a DECISION NEEDED block with a Q1 line, and
#               the block names the open part (the "open" word of the .expected file)
#   children    the number of child design-builder sessions: sessions under PI_SESSIONS_DIR (default
#               ~/.pi/agent/sessions) whose launch metadata names agent design-builder and whose header
#               parentSession has this session's file name (the scored file may be a copy). FAIL when the
#               search fails or finds no builder child.
#   open_built  every child brief has exactly one nonempty Part line, and its included part (the text before
#               "without", "except", "excluding", "but not" and the like) does not name the open part.
#               FAIL without child evidence.
# Each child then gets its own line "<run>/<n> <child part> <model> ...", scored against the builder
# .expected of its level: the child's WORK line, else its brief's "Scope level" line (primitive,
# component group or section, component, screen or page), on the design run's product. A marketing
# section is mkt-section when its surface is illustration or its included part is the demo (builds_demo),
# else mkt-copy-section.
# Per run it reports:
#   text        every "must" skill and every applied pass skill came back as text in a tool result
#   unexpected  no other skill came back: not a forbidden one, not an n/a pass, not one the expected file omits
#   passes      PASSES has a result for every "pass" line of the part's level
#   static      the design-qa scanner (design-scan) ran
#   report      the final RESULT message has a PASSES field (filled or not): it is the report, ok, scored as it is.
#               Else the report file counts (see below): FAIL(final message not the report) when a final RESULT
#               message exists, ok when the run stopped before one (owner decision 31: format apart from routing);
#               passes, text and unexpected are then scored from the file. No file: FAIL(no report).
#   report_file frozen(<path>) or live(<path>): the report file read, printed only when the file is used.
#   shots       screenshots came from agent-browser-chrome or command-local AGENT_BROWSER_ENGINE=chrome
#               agent-browser calls; none from an unqualified public CLI or another tool
#   cost, peak_ctx, result  from the index; ambiguous = expected-file "ambiguous" skills that came back
# The report file of a session: its frozen copy <session without .jsonl>.report.md beside it (the parent copies each
# run's report.md there at scoring time), else the path in the final RESULT message's ARTIFACT line, else the report
# path the brief names ($HOME/.pi/artifacts/design-builder/eval-<run>/report.md, or the design agent's path). The
# scorer reads the file, never the tool call that wrote it.
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

SESSIONS_DIR=${PI_SESSIONS_DIR:-$HOME/.pi/agent/sessions}
FAILED_RUNS=0; N=0
# Score one session against <part>.expected: one line, with EXTRA (set by the caller) before cost.
# Returns 2 on an input error; the caller exits 1.
score_one() {
  local run=$1 part=$2 model=$3 session=$4 exp row returned passes result cost peak
  exp="$EXPECTED_DIR/$part.expected"
  [ -r "$exp" ] || { echo "score: no expected file for part '$part' ($exp)" >&2; return 2; }
  [ -r "$session" ] || { echo "score: cannot read session $session" >&2; return 2; }
  N=$((N+1))
  row=$(row_for "$session")
  if [ -z "$row" ]; then echo "$run $part $model FAIL: session not in $TSV"; FAILED_RUNS=$((FAILED_RUNS+1)); return 0; fi
  returned=$(col "$row" skills_returned); passes=$(col "$row" passes); result=$(col "$row" result)
  cost=$(col "$row" cost); peak=$(col "$row" peak_ctx)
  # Owner decision 31: a final RESULT message with a PASSES field is the report; its index passes count as they are,
  # with no recovery from elsewhere. Without one (or with no final RESULT), the report file counts: its passes, read
  # with the index's own entry check (evals/retro/passes.jq), so an unfilled entry does not count here either.
  fin=$(final_result "$session") || { echo "score: cannot parse session $session" >&2; return 2; }
  rep_item=""; rep_file=""
  if grep -q '^PASSES:' <<< "$fin"; then rep_item=ok
  elif rf=$(report_file "$session"); then
    rep_file=" report_file=${rf%%$'\t'*}(${rf#*$'\t'})"
    if [ -n "$fin" ]; then rep_item="FAIL(final message not the report)"; else rep_item=ok; fi
    passes=$(jq -L "$HERE/retro" -Rrs 'include "passes"; [ passes_of[] | "\(.pass) -> \(.status): \(.change)" ] | join("; ")' "${rf#*$'\t'}")
  else rep_item="FAIL(no report)"; passes=""; fi

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
  read -r scan tsc chrome plain other < <(jq -rs '
    [ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall") ] as $calls
    | [ $calls[] | select(.name=="bash" or .name=="codemode") | [.arguments | .. | strings] | join("\n")
        | split("\n")[] | splits("&&|\\|\\||;|\\|") ] as $seg
    | def n(re): ([ $seg[] | select(test(re)) ] | length);
    # Only command-local assignments count; no environment is inferred across segments or calls.
    def public_chrome: test("(^|[^\\w])AGENT_BROWSER_ENGINE=[\u0022\u0027]?chrome[\u0022\u0027]?\\s+agent-browser\\s.*\\b(screenshot|batch)\\b");
    # Names that hold agent-browser-chrome (a shell assignment or a JS const/let in codemode): ${AB} screenshot is chrome.
    ([ $seg[] | capture("(^|[^\\w$])(?<v>[A-Za-z_]\\w*)\\s*=\\s*[\"\u0027`]?agent-browser-chrome\\b") | .v ] | unique) as $cv
    | (if ($cv | length) > 0 then "\\$\\{?(" + ($cv | join("|")) + ")\\b\\}?\\s.*\\b(screenshot|batch)\\b" else null end) as $cvre
    | [ n("design-scan"), n("\\btsc\\b|typecheck|npm run build"),
        ([ $seg[] | select(test("agent-browser-chrome\\b.*\\b(screenshot|batch)\\b") or public_chrome or ($cvre != null and test($cvre))) ] | length),
        ([ $seg[] | select(test("(^|[^-\\w/])agent-browser\\s.*\\b(screenshot|batch)\\b") and (public_chrome | not)) ] | length),
        n("screencapture|\\.screenshot\\(|playwright\\s+screenshot") ] | @tsv' "$session")
  [ -n "$scan" ] || { echo "score: cannot parse session $session" >&2; return 2; }

  item() { if [ -z "$2" ]; then printf ' %s=ok' "$1"; else printf ' %s=FAIL(%s)' "$1" "$2"; fi; }
  pf=""; [ -n "$missing_pass" ] && pf="missing:${missing_pass#,}"
  line="$run $part $model"
  line="$line$(item text "${missing_text:+missing:${missing_text#,}}")"
  line="$line$(item unexpected "${unexpected#,}")"
  line="$line$(item passes "$pf")"
  line="$line$( [ "$scan" -gt 0 ] && printf ' static=ok(scan=%s,tsc=%s)' "$scan" "$tsc" || printf ' static=FAIL(scan=0,tsc=%s)' "$tsc")"
  line="$line report=$rep_item$rep_file"
  line="$line$( [ "$chrome" -gt 0 ] && [ "$plain" -eq 0 ] && [ "$other" -eq 0 ] && printf ' shots=ok(chrome=%s)' "$chrome" || printf ' shots=FAIL(chrome=%s,plain=%s,other=%s)' "$chrome" "$plain" "$other")"
  line="$line${EXTRA:-} cost=\$$cost peak_ctx=$peak result=$result ambiguous=[${amb#,}]"
  echo "$line"
  case "$line" in *FAIL*) FAILED_RUNS=$((FAILED_RUNS+1));; esac
  return 0
}

# The final RESULT message: the last assistant text with a RESULT line (the index's choice), or nothing.
final_result() { jq -rs '[ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text
  | select(test("(^|\n)RESULT:")) ] | last // ""' "$1"; }
# The report file of session $1 (header comment): prints "frozen<TAB>path" or "live<TAB>path"; exit 1 when none is readable.
# A final ARTIFACT line decides the live path, even when its file is missing; only without one does the brief path count.
report_file() {
  local frozen=${1%.jsonl}.report.md art
  [ -r "$frozen" ] && { printf 'frozen\t%s\n' "$frozen"; return 0; }
  art=$(final_result "$1" | sed -n 's/^ARTIFACT:[[:space:]]*`\{0,1\}\(\/[^`]*[^`[:space:]]\)`\{0,1\}[[:space:]]*$/\1/p' | tail -1)
  [ -n "$art" ] || art=$(brief_text "$1" | grep -oE '(\$HOME|~|/[^[:space:]`"()]*)/\.pi/artifacts/design(-builder)?/eval-[A-Za-z0-9._-]+/report\.md' | head -1 \
    | sed -e "s|^\\\$HOME|$HOME|" -e "s|^~|$HOME|")
  [ -n "$art" ] && [ -r "$art" ] && [ -f "$art" ] || return 1
  printf 'live\t%s\n' "$art"
}
# Text a session ends on: its final assistant text and its report file (decision block, WORK line).
final_text() {
  local rf
  jq -rs '[ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text ] | last // ""' "$1"
  rf=$(report_file "$1") && cat "${rf#*$'\t'}"
  return 0
}
# The brief: the first user message.
brief_text() { jq -rs '[ .[] | select(.type=="message" and .message.role=="user") | .message.content[]? | select(.type=="text") | .text ] | first // ""' "$1"; }
# Design-builder child sessions of $1, oldest first: the header's parentSession names $1 and the launch metadata
# names agent design-builder (scout and researcher children are allowed, not builders). The scorer reads a copy of
# the design session (owner decision 14) while a child keeps the original parentSession path, so the match is on
# the session file name, which pi makes unique. Returns 2 when the search fails (for example no folder) or when any
# candidate file cannot be read or parsed: an unreadable child could hide the open part, so it is no evidence.
children_of() {
  local base list f row rc=0 rows=""
  base=$(basename "$1")
  list=$(rg -l -F -g '*.jsonl' -- "/$base\"" "$SESSIONS_DIR" 2>/dev/null); [ $? -le 1 ] || return 2
  while read -r f; do
    [ -n "$f" ] || continue
    row=$(jq -rs --arg b "$base" --arg f "$f" 'select(.[0].type=="session" and ((.[0].parentSession // "") | split("/") | last) == $b
      and ([ .[] | select(.customType=="pi-subagents_launch_metadata") | .data.agent ][0] == "design-builder"))
      | "\(.[0].timestamp)\t\($f)"' "$f" 2>/dev/null) || { rc=2; continue; }
    [ -z "$row" ] || rows="$rows$row"$'\n'
  done <<< "$list"
  [ -z "$rows" ] || printf '%s' "$rows" | sort | cut -f2
  return $rc
}
# Whether a child brief builds the open part $2: "yes", "no", or "unclear" (no Part line, or more than one).
# Only the included part counts: the Part text is cut at its first exclusion word, so "the Shipments table,
# without the Docks section" is no, while "the Docks section with annotations" and "the open Docks section" are yes.
# An empty or whitespace-only Part is unclear too: it gives no evidence of the assigned part.
builds_open() {
  local inc
  inc=$(included_part "$1") || { echo unclear; return; }
  if grep -qiF -- "$2" <<< "$inc"; then echo yes; else echo no; fi
}
# The included part of a child brief, lowercased: the text of its one Part line, cut at its first exclusion word.
# Exit 1 and print nothing when there is no Part line, more than one, or no letter or digit is left.
included_part() {
  local parts inc
  parts=$(brief_text "$1" | sed 's/\*\*//g' | grep -iE '^[[:space:]*-]*part:')
  [ -n "$parts" ] && [ "$(wc -l <<< "$parts" | tr -d ' ')" -eq 1 ] || return 1
  inc=$(tr 'A-Z' 'a-z' <<< "${parts#*:}" | sed -E 's/(without|except|excluding|but not|not including|apart from|other than)([^a-z].*)?$//')
  [[ $inc =~ [a-z0-9] ]] || return 1
  printf '%s\n' "$inc"
}
# The surface a child brief names: the first word after "Surface:" (else the first field of its WORK line), lowercased.
surface_of() {
  local sf
  sf=$(brief_text "$1" | sed 's/\*\*//g' | grep -ioE 'surface:[[:space:]]*[a-z-]+' | head -1 | sed -E 's/^[^:]*:[[:space:]]*//')
  [ -n "$sf" ] || sf=$(final_text "$1" | sed -n 's/^WORK:[[:space:]]*\([^,]*\),.*/\1/p' | head -1)
  tr 'A-Z' 'a-z' <<< "$sf"
}
# Whether a marketing section child builds the illustration demo: its surface is illustration, or the head of its
# included part (before the first ":", ",", ";", "(", or "with", "that", "which", "and", "linking") names the demo,
# an illustration or a stage. "the hero section with a link to the demo" and "the pricing section, excluding the
# demo" are ordinary sections; "the product-demo section: an animated illustration ..." is the demo.
builds_demo() {
  local head
  [ "$(surface_of "$1")" = illustration ] && return 0
  head=$(included_part "$1" | sed -E 's/[:,;(].*//; s/[[:space:]](with|that|which|and|linking)[[:space:]].*//') || return 1
  grep -qE 'illustration|demo|stage' <<< "$head"
}
# The builder part of a child: its level on the design run's product (prefix "mkt-" for marketing).
child_part() {
  local lvl prefix=$2
  lvl=$(final_text "$1" | sed -n 's/^WORK:[[:space:]]*[^,]*,[[:space:]]*\([^,]*\),.*/\1/p' | head -1)
  [ -n "$lvl" ] || lvl=$(brief_text "$1" | grep -i 'scope level' | head -1 | sed 's/.*[Ss]cope level:[*]*[[:space:]]*//')
  lvl=$(printf '%s' "$lvl" | tr 'A-Z' 'a-z')
  case "$lvl" in
    # On the marketing product, only the illustration demo part takes mkt-section (it requires stageshow);
    # an ordinary page section (hero, features, pricing, footer) takes mkt-copy-section, with its marketing-copy trigger.
    *group*|*section*) if [ -z "$prefix" ]; then echo section
      elif builds_demo "$1"; then echo mkt-section
      else echo mkt-copy-section; fi;;
    primitive*) echo "${prefix}primitive-set";;
    component*) echo "${prefix}component";;
    screen*|page*|flow*) if [ -n "$prefix" ]; then echo "${prefix}page"; else echo screen; fi;;
  esac
}

while IFS=$'\t' read -r run part model session; do
  case "$run" in ''|'#'*) continue;; esac
  EXTRA=""
  case "$part" in
    design-app|design-marketing)
      exp="$EXPECTED_DIR/$part.expected"
      [ -r "$exp" ] && [ -r "$session" ] || { echo "score: cannot read $exp or $session" >&2; exit 1; }
      open=$(kind "$exp" open | head -1)
      if [ "$part" = design-marketing ]; then prefix=mkt-; else prefix=""; fi
      fin=$(final_text "$session")
      # Here-strings, not pipes: under pipefail, grep -q can exit before the
      # writer finishes and turn a match into exit 141 (SIGPIPE).
      blk=$(sed -n '/^DECISION NEEDED/,/^RECOMMEND:/p' <<< "$fin")
      if ! grep -q '^DECISION NEEDED' <<< "$fin"; then dec="FAIL(no block)"
      elif ! grep -q '^Q1:' <<< "$fin"; then dec="FAIL(no Q1)"
      elif ! grep -qiF -- "$open" <<< "$blk"; then dec="FAIL(block names no $open)"
      else dec=ok; fi
      kids=$(children_of "$session"); kst=$?; nk=0; built=""; i=0
      [ -n "$kids" ] && nk=$(printf '%s\n' "$kids" | wc -l | tr -d ' ')
      while read -r k; do
        [ -n "$k" ] || continue; i=$((i+1))
        case $(builds_open "$k" "$open") in yes) built="$built,$run/$i";; unclear) built="$built,$run/$i:part-unclear";; esac
      done <<< "$kids"
      # Missing child evidence is a FAIL: a failed search or no builder child at all cannot show the open part stayed unbuilt.
      if [ "$kst" -ne 0 ]; then nkf="FAIL(child search failed in $SESSIONS_DIR)"; ob="FAIL(no child evidence)"
      elif [ "$nk" -eq 0 ]; then nkf="FAIL(none found)"; ob="FAIL(no child evidence)"
      else nkf=$nk; if [ -z "$built" ]; then ob=ok; else ob="FAIL(${built#,})"; fi; fi
      EXTRA=" decision=$dec children=$nkf open_built=$ob"
      score_one "$run" "$part" "$model" "$session" || exit 1
      EXTRA=""; i=0
      while read -r k; do
        [ -n "$k" ] || continue; i=$((i+1))
        cpart=$(child_part "$k" "$prefix")
        krow=$(row_for "$k"); kmodel="?"; [ -n "$krow" ] && kmodel=$(col "$krow" model)
        if [ -z "$cpart" ]; then N=$((N+1)); FAILED_RUNS=$((FAILED_RUNS+1)); echo "$run/$i ? $kmodel FAIL: level unknown ($k)"; continue; fi
        score_one "$run/$i" "$cpart" "$kmodel" "$k" || exit 1
      done <<< "$kids";;
    *) score_one "$run" "$part" "$model" "$session" || exit 1;;
  esac
done < "$RUNS"
echo "score: $N runs, $FAILED_RUNS with a FAIL item"
