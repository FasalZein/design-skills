#!/usr/bin/env bash
# Fixture tests for evals/score.sh, evals/new-run.sh and evals/clean-run.sh. Expected values come from spec Acceptance 4,
# the expected files in evals/briefs/ and what each fixture session was built to contain. Exit 0 = all pass.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
EVALS=$(dirname "$HERE")
FAILS=0
ok() { echo "ok: $*"; }
no() { FAILS=$((FAILS+1)); echo "FAIL: $*"; }
WORK=$(mktemp -d)
REPO=$(dirname "$EVALS")
TAG="test-$$"
trap 'rm -rf "$WORK" "$REPO/.eval-runs/$TAG"-*' EXIT
# Session fixtures go to one folder; design fixtures name their parent session as __SESS__/<file>.
FIX="$WORK/sess"; mkdir -p "$FIX"
cp "$HERE"/fixtures/sessions/*.jsonl "$FIX/"
for f in "$HERE"/fixtures/design/*.jsonl; do sed "s|__SESS__|$FIX|g" "$f" > "$FIX/$(basename "$f")"; done

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

# Design runs: the design session against its own expected file, its DECISION NEEDED block, and each child
# design-builder session (found by its header's parentSession) against the expected file of its level.
printf '%s\t%s\t%s\t%s\n' dgood design-app opus "$FIX/design-good.jsonl" dbad design-marketing sonnet "$FIX/design-bad.jsonl" > "$WORK/druns.tsv"
PI_SESSIONS_DIR="$FIX" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/druns.tsv" > "$WORK/dscore.out" 2>&1; st=$?
[ "$st" -eq 0 ] && ok "score exits 0 on design runs" || { no "design score exit $st"; cat "$WORK/dscore.out"; }
dline() { grep "^$1 " "$WORK/dscore.out"; }
dhas() { dline "$1" | grep -qF -- "$2" && ok "$1: $2" || no "$1: want [$2] in [$(dline "$1")]"; }
# The good design session names the open part in its block; its second child built that open part.
for item in decision=ok children=2 'open_built=FAIL(dgood/2)' text=ok unexpected=ok passes=ok static=ok report=ok shots=ok; do dhas dgood "$item"; done
# Child 1: a component brief (WORK line), scored against component.expected.
for item in text=ok unexpected=ok passes=ok static=ok shots=ok; do dline dgood/1 | grep -qF -- "$item" && ok "dgood/1: $item" || no "dgood/1: want [$item] in [$(dline dgood/1)]"; done
dline dgood/1 | grep -q '^dgood/1 component ' && ok "child 1 scored as component" || no "child 1 part: [$(dline dgood/1)]"
# Child 2: a component group (WORK line), scored against section.expected.
dline dgood/2 | grep -q '^dgood/2 section ' && ok "child 2 scored as section" || no "child 2 part: [$(dline dgood/2)]"
dhas dgood/2 'static=FAIL(scan=0'
# The bad design session: no block, no children, a builder-only skill, a missing design pass.
for item in 'decision=FAIL(no block)' children=0 open_built=ok 'unexpected=FAIL(better-colors)' 'passes=FAIL(missing:find-animation-opportunities)'; do dhas dbad "$item"; done
grep -q '^score: 4 runs, 3 with a FAIL item$' "$WORK/dscore.out" && ok "design summary line" || no "design summary line: $(tail -1 "$WORK/dscore.out")"

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
  listed=$(awk '!/^#/ && NF && $1 != "open" {print $2}' "$f" | sort)
  gap=$(comm -23 <(echo "$ROUTED") <(echo "$listed") | paste -sd, -)
  dup=$(echo "$listed" | uniq -d | paste -sd, -)
  badkind=$(awk '!/^#/ && NF && $1 !~ /^(pass|must|forbid|allow|ambiguous|open)$/ {print $1}' "$f" | paste -sd, -)
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

# Design expected files name the open part; builder expected files do not.
for f in "$EVALS"/briefs/*.expected; do
  n=$(awk '$1=="open"' "$f" | wc -l | tr -d ' ')
  case $(basename "$f") in design-*) want=1;; *) want=0;; esac
  [ "$n" -eq "$want" ] && ok "$(basename "$f") has $want open line(s)" || no "$(basename "$f") has $n open lines, want $want"
done
# Each design brief's DESIGN.md variant has exactly one open part; each fixture DESIGN.md has none.
for d in "$EVALS"/overlays/design-*/DESIGN.md; do
  grep -c '^Open for the build: ' "$d" | grep -qx 1 && ! grep -q '^Open for the build: none' "$d" && ok "$d has one open part" || no "$d: want one open part"
done
for d in "$EVALS"/fixture/DESIGN.md "$EVALS"/fixture-marketing/DESIGN.md; do
  grep -qx 'Open for the build: none' "$d" && ok "$d closes every decision" || no "$d: want 'Open for the build: none'"
done

# new-run.sh on both products (needs npm ci in each fixture; skipped with a note otherwise).
check_run() { # part fixture-file-that-must-exist expected-text-in-DESIGN.md
  local part=$1 file=$2 design=$3 r="$WORK/runs/$1"
  EVAL_RUNS_ROOT="$WORK/runs" bash "$EVALS/new-run.sh" "$part" "$part" 5301 > "$WORK/$part.brief" 2>/dev/null || { no "new-run $part failed"; return; }
  [ "$(git -C "$r" rev-list --count HEAD)" = 1 ] && ok "new-run $part: one commit" || no "new-run $part: commit count"
  [ -f "$r/$file" ] && ok "new-run $part: $file present" || no "new-run $part: $file missing"
  grep -qF -- "$design" "$r/DESIGN.md" && ok "new-run $part: DESIGN.md [$design]" || no "new-run $part: DESIGN.md lacks [$design]"
  git -C "$r" ls-files | grep -qE '^(node_modules|dist)/' && no "new-run $part: committed node_modules or dist" || ok "new-run $part: no node_modules or dist in git"
  grep -qF "$r/DESIGN.md" "$WORK/$part.brief" && ! grep -q '{[A-Z_]*}' "$WORK/$part.brief" && ok "new-run $part: brief rendered" || no "new-run $part: brief not rendered"
}
if [ -d "$EVALS/fixture/node_modules" ]; then
  check_run section src/components/status-badge.tsx 'Open for the build: none'
  check_run design-app src/App.tsx 'Open for the build: the Docks section'
else echo "skip: evals/fixture/node_modules missing (npm ci --prefix evals/fixture)"; fi
if [ -d "$EVALS/fixture-marketing/node_modules" ]; then
  check_run mkt-primitive-set src/sections/product-demo.tsx 'Open for the build: none'
  check_run mkt-page src/components/pricing-card.tsx 'Open for the build: none'
  grep -q 'IBM Plex Mono' "$WORK/runs/mkt-page/src/index.css" && ok "new-run mkt-page: primitives overlay applied" || no "new-run mkt-page: primitives overlay missing"
  check_run design-marketing src/sections/faq.tsx 'Open for the build: the FAQ section'
  # Default root: <repo root>/.eval-runs; then clean-run.sh saves the run and deletes it.
  bash "$EVALS/new-run.sh" mkt-component "$TAG-nr" 5301 >/dev/null 2>&1 && [ -d "$REPO/.eval-runs/$TAG-nr/.git" ] \
    && ok "new-run default root is <repo>/.eval-runs" || no "new-run default root"
else echo "skip: evals/fixture-marketing/node_modules missing (npm ci --prefix evals/fixture-marketing)"; fi

# clean-run.sh: saves the log and diffs, deletes the run, and refuses anything outside <repo>/.eval-runs.
CR="$EVALS/clean-run.sh"; R="$REPO/.eval-runs/$TAG-cr"
mkdir -p "$R" && git -C "$R" init -q -b main && echo one > "$R/a.txt" && git -C "$R" add -A \
  && git -C "$R" -c user.name=t -c user.email=t@l commit -qm initial && echo two > "$R/a.txt" \
  && git -C "$R" -c user.name=t -c user.email=t@l commit -qam second && echo three > "$R/b.txt"
bash "$CR" "$TAG-cr" "$WORK/art" 2>/dev/null && ok "clean-run exits 0" || no "clean-run failed"
[ ! -e "$R" ] && ok "clean-run deleted the run" || no "clean-run left the run"
grep -q '^+two$' "$WORK/art/run.diff" && grep -q 'second' "$WORK/art/git-log.txt" && ok "clean-run saved diff and log" || no "clean-run diff or log missing"
grep -q '^+three$' "$WORK/art/uncommitted.diff" && ok "clean-run saved uncommitted work" || no "clean-run lost uncommitted work"
mkdir -p "$WORK/outside" && git -C "$WORK/outside" init -q && touch "$WORK/outside/keep"
ln -s "$WORK/outside" "$REPO/.eval-runs/$TAG-link"
mkdir -p "$REPO/.eval-runs/$TAG-plain"
for bad in "../evals" "$WORK/outside" "." ".." "$TAG-missing" "$TAG-link" "$TAG-plain"; do
  bash "$CR" "$bad" "$WORK/art2" >/dev/null 2>&1 && no "clean-run accepted [$bad]" || ok "clean-run refuses [$bad]"
done
[ -f "$WORK/outside/keep" ] && [ -d "$REPO/.eval-runs/$TAG-plain" ] && [ -d "$REPO/evals" ] && ok "refused targets left untouched" || no "a refused target changed"
if [ -d "$REPO/.eval-runs/$TAG-nr" ]; then
  bash "$CR" "$TAG-nr" "$WORK/art3" 2>/dev/null && [ ! -e "$REPO/.eval-runs/$TAG-nr" ] && [ -s "$WORK/art3/git-log.txt" ] \
    && ok "clean-run removes a new-run run" || no "clean-run on a new-run run"
fi
rm -f "$REPO/.eval-runs/$TAG-link"

echo "----"
[ "$FAILS" -eq 0 ] && { echo "eval tests: PASS"; exit 0; } || { echo "eval tests: $FAILS failure(s)"; exit 1; }
