#!/usr/bin/env bash
# Fixture tests for evals/score.sh and evals/new-run.sh. Expected values come from spec Acceptance 4,
# the expected files in evals/briefs/ and what each fixture session was built to contain. Exit 0 = all pass.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
EVALS=$(dirname "$HERE")
FIX="$HERE/fixtures/sessions"
FAILS=0
ok() { echo "ok: $*"; }
no() { FAILS=$((FAILS+1)); echo "FAIL: $*"; }
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

PI_SESSIONS_DIR="$FIX" bash "$EVALS/retro/index.sh" "$WORK/sessions.tsv" >/dev/null 2>&1 || no "index.sh on the score fixtures failed"
printf '%s\t%s\t%s\t%s\n' "# run" part model session \
  good component opus "$FIX/score-good.jsonl" \
  bad component sonnet "$FIX/score-bad.jsonl" \
  norep component gpt "$FIX/score-no-report.jsonl" \
  time component gpt "$FIX/score-time-limit.jsonl" > "$WORK/runs.tsv"
bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/runs.tsv" > "$WORK/score.out" 2>&1; st=$?
[ "$st" -eq 0 ] && ok "score exits 0 on scorable runs" || { no "score exit $st"; cat "$WORK/score.out"; }
line() { grep "^$1 " "$WORK/score.out"; }
has() { line "$1" | grep -qF -- "$2" && ok "$1: $2" || no "$1: want [$2] in [$(line "$1")]"; }

# A run that meets every Acceptance 4 item; the ambiguous skill it loaded is listed, not failed.
for item in text=ok unexpected=ok passes=ok static=ok report=ok shots=ok 'ambiguous=[design-taste-frontend]' 'peak_ctx=150000' 'result=DONE'; do has good "$item"; done
# Fired trigger and Verify row without text; a forbidden, an out-of-router and an n/a-pass skill with text;
# a pass without a result; no scanner; a plain agent-browser screenshot.
has bad 'text=FAIL(missing:shadcn,browser-checks)'
has bad 'unexpected=FAIL(better-colors,impeccable,review-animations)'
has bad 'passes=FAIL(missing:break-ui)'
has bad 'static=FAIL(scan=0'
has bad 'shots=FAIL(chrome=0,plain=1,other=0)'
has bad 'report=ok'
# No final RESULT message and no written report.
has norep 'report=FAIL'
has norep 'static=ok(scan=1'
# Stopped by the time limit: the written draft is the report, and its PASSES entries count.
has time 'report=ok'
has time 'passes=FAIL(missing:better-accessibility,state-machine,break-ui,review-animations,interface-review)'
grep -q '^score: 4 runs, 3 with a FAIL item$' "$WORK/score.out" && ok "summary line" || no "summary line missing"

# Input errors exit 1.
printf 'x\tcomponent\tm\t%s\n' "$FIX/score-good.jsonl" > "$WORK/one.tsv"
bash "$EVALS/score.sh" "$WORK/missing.tsv" "$WORK/one.tsv" >/dev/null 2>&1 && no "missing index exits 0" || ok "missing index exits nonzero"
printf 'x\tno-such-part\tm\t%s\n' "$FIX/score-good.jsonl" > "$WORK/badpart.tsv"
bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/badpart.tsv" >/dev/null 2>&1 && no "unknown part exits 0" || ok "unknown part exits nonzero"
# A session missing from the index is a FAIL line, not a crash.
cp "$FIX/score-good.jsonl" "$WORK/other.jsonl"
printf 'lost\tcomponent\tm\t%s\n' "$WORK/other.jsonl" > "$WORK/lost.tsv"
bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/lost.tsv" 2>/dev/null | grep -q '^lost component m FAIL: session not in' && ok "unindexed session reported" || no "unindexed session not reported"

# Every expected file lists each routed skill once (child agents excepted).
ROUTED=$(awk '/^## Routing table/{f=1;next} f&&/^## /{exit} f' "$(dirname "$EVALS")/design-craft/SKILL.md" | grep '^| ' | grep -v '^| Level ' | grep -v '^|---' \
  | grep -v '(child agent)' | cut -d'|' -f4 | sed 's/^ *//; s/ .*//' | sort)
for f in "$EVALS"/briefs/*.expected; do
  listed=$(awk '!/^#/ && NF {print $2}' "$f" | sort)
  gap=$(comm -23 <(echo "$ROUTED") <(echo "$listed") | paste -sd, -)
  dup=$(echo "$listed" | uniq -d | paste -sd, -)
  badkind=$(awk '!/^#/ && NF && $1 !~ /^(pass|must|forbid|allow|ambiguous)$/ {print $1}' "$f" | paste -sd, -)
  [ -z "$gap$dup$badkind" ] && ok "$(basename "$f") covers every routed skill once" || no "$(basename "$f"): missing [$gap] duplicate [$dup] bad kind [$badkind]"
done

# new-run.sh: usage errors exit 1 before touching disk.
EVAL_RUNS_ROOT="$WORK/runs" bash "$EVALS/new-run.sh" bogus r1 5301 >/dev/null 2>&1 && no "new-run accepts an unknown part" || ok "new-run rejects an unknown part"
EVAL_RUNS_ROOT="$WORK/runs" bash "$EVALS/new-run.sh" screen ../escape 5301 >/dev/null 2>&1 && no "new-run accepts a path as run name" || ok "new-run rejects a path as run name"
EVAL_RUNS_ROOT="$WORK/runs" bash "$EVALS/new-run.sh" screen r1 http >/dev/null 2>&1 && no "new-run accepts a non-numeric port" || ok "new-run rejects a non-numeric port"
# An existing run directory is refused and left untouched.
mkdir -p "$WORK/runs/taken" && touch "$WORK/runs/taken/keep"
EVAL_RUNS_ROOT="$WORK/runs" bash "$EVALS/new-run.sh" screen taken 5301 >/dev/null 2>&1 && no "new-run reuses an existing run" || ok "new-run refuses an existing run"
[ -f "$WORK/runs/taken/keep" ] && ok "existing run left untouched" || no "existing run changed"
# Each brief renders with no placeholder left.
for b in "$EVALS"/briefs/*.md; do
  r=$(sed -e "s|{RUN_DIR}|/r|g" -e "s|{PORT}|1|g" -e "s|{RUN_NAME}|n|g" "$b" | grep -o '{[A-Z_]*}' | sort -u | paste -sd, -)
  [ -z "$r" ] && ok "$(basename "$b") renders every placeholder" || no "$(basename "$b") keeps placeholders [$r]"
done

echo "----"
[ "$FAILS" -eq 0 ] && { echo "eval tests: PASS"; exit 0; } || { echo "eval tests: $FAILS failure(s)"; exit 1; }
