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
for item in 'decision=FAIL(no block)' 'children=FAIL(none found)' 'open_built=FAIL(no child evidence)' 'unexpected=FAIL(better-colors)' 'passes=FAIL(missing:find-animation-opportunities)'; do dhas dbad "$item"; done
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
  r=$(sed -e "s|{RUN_DIR}|/r|g" -e "s|{PORT}|1|g" -e "s|{RUN_NAME}|n|g" -e "s|{START}|s|g" "$b" | grep -o '{[A-Z_]*}' | sort -u | paste -sd, -)
  [ -z "$r" ] && ok "$(basename "$b") renders every placeholder" || no "$(basename "$b") keeps placeholders [$r]"
done

# Design expected files name the open part; builder expected files do not.
for f in "$EVALS"/briefs/*.expected; do
  n=$(awk '$1=="open"' "$f" | wc -l | tr -d ' ')
  case $(basename "$f") in design-*) want=1;; *) want=0;; esac
  [ "$n" -eq "$want" ] && ok "$(basename "$f") has $want open line(s)" || no "$(basename "$f") has $n open lines, want $want"
done
# design-md routes for the design agent only (spec D24): builders never run it, and the design briefs ship a DESIGN.md.
for f in "$EVALS"/briefs/*.expected; do
  awk '$1=="forbid" && $2=="design-md"' "$f" | grep -q . && ok "$(basename "$f") forbids design-md" || no "$(basename "$f") must forbid design-md"
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
  check_run section src/components/app-sidebar.tsx 'Open for the build: none'
  [ ! -e "$WORK/runs/section/src/components/status-badge.tsx" ] && ok "new-run section: no old-direction overlay" || no "new-run section: old status-badge overlay present"
  grep -q "newEta: '10:40'" "$WORK/runs/section/src/data/shipments.ts" && ok "new-run section: newEta in the data" || no "new-run section: newEta missing"
  grep -qF 'starts from the stock fixture' "$WORK/section.brief" && ok "new-run section: brief names the fixture start" || no "new-run section: start line"
  check_run design-app src/App.tsx 'Open for the build: the Docks section'
  ! grep -q '^- Docks board: label column\|^- Board bar:' "$WORK/runs/design-app/DESIGN.md" && ok "new-run design-app: the Docks form lines are open" || no "new-run design-app: Docks form still decided"

  # Chain mode: a run starts from the committed HEAD of an earlier run; uncommitted work stays behind.
  CH="$WORK/runs"
  EVAL_RUNS_ROOT="$CH" bash "$EVALS/new-run.sh" primitive-set chain-p 5301 >/dev/null 2>&1 || no "chain: first run failed"
  echo ':root { --chain-mark: 1; }' >> "$CH/chain-p/src/index.css"
  git -C "$CH/chain-p" -c user.name=t -c user.email=t@l commit -qam "primitives built"
  echo 'scratch' > "$CH/chain-p/uncommitted.txt"; echo '// dirty' >> "$CH/chain-p/src/App.tsx"
  EVAL_RUNS_ROOT="$CH" bash "$EVALS/new-run.sh" component chain-c 5302 --from chain-p > "$WORK/chain-c.brief" 2>/dev/null && ok "chain: --from exits 0" || no "chain: --from failed"
  [ "$(git -C "$CH/chain-c" rev-list --count HEAD 2>/dev/null)" = 1 ] && ok "chain: one new initial commit" || no "chain: commit count"
  grep -q -- '--chain-mark' "$CH/chain-c/src/index.css" 2>/dev/null && ok "chain: committed work carried over" || no "chain: committed work missing"
  [ ! -e "$CH/chain-c/uncommitted.txt" ] && ! grep -q '// dirty' "$CH/chain-c/src/App.tsx" && ok "chain: uncommitted work left behind" || no "chain: uncommitted work copied"
  [ -d "$CH/chain-c/node_modules/@fontsource/barlow" ] && ok "chain: node_modules cloned" || no "chain: node_modules missing"
  [ -z "$(git -C "$CH/chain-c" status --porcelain)" ] && ok "chain: clean tree after setup" || no "chain: dirty tree after setup"
  git -C "$CH/chain-c" ls-files | grep -qE '^(node_modules|dist)/' && no "chain: committed node_modules" || ok "chain: no node_modules in git"
  sha=$(git -C "$CH/chain-p" rev-parse --short HEAD)
  grep -qF "result of run chain-p (commit $sha)" "$WORK/chain-c.brief" && ! grep -q '{[A-Z_]*}' "$WORK/chain-c.brief" && ok "chain: brief names the previous run" || no "chain: brief start line"
  EVAL_RUNS_ROOT="$CH" bash "$EVALS/new-run.sh" section chain-x 5303 --from no-such-run >/dev/null 2>&1 && no "chain: missing previous run accepted" || ok "chain: missing previous run refused"
  [ ! -e "$CH/chain-x" ] && ok "chain: refused run leaves no directory" || no "chain: refused run left a directory"
  EVAL_RUNS_ROOT="$CH" bash "$EVALS/new-run.sh" design-app chain-d 5303 --from chain-p >/dev/null 2>&1 && no "chain: --from on design-app accepted" || ok "chain: --from only on Harbor builder parts"
  EVAL_RUNS_ROOT="$CH" bash "$EVALS/new-run.sh" section chain-y 5303 --frm chain-p >/dev/null 2>&1 && no "chain: bad flag accepted" || ok "chain: bad flag refused"
  EVAL_RUNS_ROOT="$CH" bash "$EVALS/new-run.sh" section chain-y 5303 --from ../chain-p >/dev/null 2>&1 && no "chain: path as previous run accepted" || ok "chain: path as previous run refused"
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

# Harbor briefs follow the approved DESIGN.md (Hi-vis): each names its chain start and the decisions its Done checks.
brief_has() { grep -qF -- "$2" "$EVALS/briefs/$1.md" && ok "$1 brief: $2" || no "$1 brief lacks [$2]"; }
for b in primitive-set component section screen; do brief_has "$b" '{START}'; done
for s in 'Geist' '44px' 'de-DE' '"48.210,50 €"' '.dark' 'Barlow Condensed' 'Newsreader' '--radius: 0' 'prefers-reduced-motion'; do brief_has primitive-set "$s"; done
for s in 'StatusBadge' 'B3 Action first' 'Day line' '"<n> of 4 doors free"' 'At gate'; do brief_has component "$s"; done
for s in 'Overview' '"No door" lane' 'Now line' '06:00 to 16:00' 'booked <time>' 'FLIP' 'door list'; do brief_has section "$s"; done
for s in 'count tabs' 'door select' 'top bar' 'booked 08:00' "Couldn't change the door. Try again." '1440, 1024 and 375'; do brief_has screen "$s"; done
for d in "$EVALS"/fixture/DESIGN.md; do grep -q '^Direction: Hi-vis' "$d" && ok "fixture DESIGN.md is the approved Hi-vis direction" || no "fixture DESIGN.md is not Hi-vis"; done
for p in @fontsource/barlow @fontsource/barlow-condensed @fontsource-variable/newsreader; do
  jq -e --arg p "$p" '.dependencies[$p]' "$EVALS/fixture/package.json" >/dev/null && ok "fixture depends on $p" || no "fixture lacks $p"
done

# clean-run.sh: saves the log and diffs, deletes the run, and refuses anything outside <repo>/.eval-runs.
CR="$EVALS/clean-run.sh"; R="$REPO/.eval-runs/$TAG-cr"
mkdir -p "$R" && git -C "$R" init -q -b main && echo one > "$R/a.txt" && git -C "$R" add -A \
  && git -C "$R" -c user.name=t -c user.email=t@l commit -qm initial && echo two > "$R/a.txt" \
  && printf 'PNG\000\001\377bin' > "$R/img.bin" && git -C "$R" add img.bin \
  && git -C "$R" -c user.name=t -c user.email=t@l commit -qam second && echo three > "$R/b.txt" \
  && printf 'GIF\000\002\376new' > "$R/new.bin" && cp "$R/img.bin" "$WORK/img.orig" && cp "$R/new.bin" "$WORK/new.orig"
bash "$CR" "$TAG-cr" "$WORK/art" 2>/dev/null && ok "clean-run exits 0" || no "clean-run failed"
[ ! -e "$R" ] && ok "clean-run deleted the run" || no "clean-run left the run"
grep -q '^+two$' "$WORK/art/run.diff" && grep -q 'second' "$WORK/art/git-log.txt" && ok "clean-run saved diff and log" || no "clean-run diff or log missing"
grep -q '^+three$' "$WORK/art/uncommitted.diff" && ok "clean-run saved uncommitted work" || no "clean-run lost uncommitted work"
# F2: the saved patches restore binary files, committed and uncommitted, on the initial commit's content.
RS="$WORK/restore"; mkdir -p "$RS" && git -C "$RS" init -q && echo one > "$RS/a.txt"
git -C "$RS" apply --binary "$WORK/art/run.diff" 2>/dev/null && cmp -s "$RS/img.bin" "$WORK/img.orig" && ok "F2 run.diff restores the committed binary" || no "F2 run.diff does not restore the committed binary"
git -C "$RS" apply --binary "$WORK/art/uncommitted.diff" 2>/dev/null && cmp -s "$RS/new.bin" "$WORK/new.orig" && ok "F2 uncommitted.diff restores the uncommitted binary" || no "F2 uncommitted.diff does not restore the uncommitted binary"
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

# s11 review regressions (batch-review-post-gates.md F1-F8).
# F3: the scorer reads a copy of the design session (owner decision 14); children keep the original parentSession path.
mkdir -p "$WORK/copied" && cp "$FIX/design-good.jsonl" "$WORK/copied/design-good.jsonl"
printf '%s\t%s\t%s\t%s\n' cgood design-app opus "$WORK/copied/design-good.jsonl" > "$WORK/cruns.tsv"
PI_SESSIONS_DIR="$FIX" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/cruns.tsv" > "$WORK/cscore.out" 2>&1
grep '^cgood ' "$WORK/cscore.out" | grep -qF 'children=2 open_built=FAIL(cgood/2)' && ok "F3 children of a copied session found" || no "F3 copied session: [$(grep '^cgood ' "$WORK/cscore.out")]"
# F3: a failed child search is a FAIL, not children=0 / open_built=ok.
PI_SESSIONS_DIR="$WORK/no-such-dir" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/druns.tsv" > "$WORK/nscore.out" 2>&1
grep '^dgood ' "$WORK/nscore.out" | grep -qF 'children=FAIL(' && grep '^dgood ' "$WORK/nscore.out" | grep -qF 'open_built=FAIL(' \
  && ok "F3 failed child discovery reported as FAIL" || no "F3 failed discovery: [$(grep '^dgood ' "$WORK/nscore.out")]"
# F4: the scout child of design-good is not a builder: not counted, not scored (dgood children=2 above), no third line.
grep -q '^dgood/3 ' "$WORK/dscore.out" && no "F4 scout child scored as a builder: [$(grep '^dgood/3 ' "$WORK/dscore.out")]" || ok "F4 scout child not scored"
# F5: an ordinary marketing section uses the copy profile; only the illustration demo part uses mkt-section (stageshow).
printf '%s\t%s\t%s\t%s\n' dmkt design-marketing opus "$FIX/design-mkt.jsonl" > "$WORK/mruns.tsv"
PI_SESSIONS_DIR="$FIX" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/mruns.tsv" > "$WORK/mscore.out" 2>&1
grep -q '^dmkt/1 mkt-copy-section ' "$WORK/mscore.out" && ok "F5 hero section scored as mkt-copy-section" || no "F5 hero: [$(grep '^dmkt/1 ' "$WORK/mscore.out")]"
grep -q '^dmkt/2 mkt-section ' "$WORK/mscore.out" && ok "F5 demo illustration scored as mkt-section" || no "F5 demo: [$(grep '^dmkt/2 ' "$WORK/mscore.out")]"
awk '$1=="must" && $2=="copywriting"' "$EVALS/briefs/mkt-copy-section.expected" 2>/dev/null | grep -q . && ! awk '$1=="must" && $2=="stageshow"' "$EVALS/briefs/mkt-copy-section.expected" | grep -q . \
  && ok "F5 mkt-copy-section keeps the marketing-copy trigger, no stageshow must" || no "F5 mkt-copy-section.expected profile"
# F6: the included part, not its exclusions, decides open_built; a missing Part line does not pass.
open_built_for() { # $1 Part line text (empty = no Part line, unless $2 is "line") -> the dgood-copy open_built item
  local d="$WORK/f6-$RANDOM"; mkdir -p "$d"; cp "$FIX/design-good.jsonl" "$d/design-good.jsonl"
  local t=$'# Build: x\n\n'; { [ -n "$1" ] || [ "${2:-}" = line ]; } && t+="- **Part:**$1"$'\n'; t+="- **Scope level:** section."
  jq -c --arg p "$d/design-good.jsonl" --arg t "$t" \
    'if .type=="session" then .parentSession=$p elif (.type=="message" and .message.role=="user") then .message.content[0].text=$t else . end' "$FIX/child-open.jsonl" > "$d/child-f6.jsonl"
  printf '%s\t%s\t%s\t%s\n' f6 design-app opus "$d/design-good.jsonl" > "$d/runs.tsv"
  PI_SESSIONS_DIR="$d" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$d/runs.tsv" 2>&1 | grep '^f6 ' | grep -o 'open_built=[^ ]*'
}
for p in " the Docks section with annotations." " the open Docks section." " the Docks section of the Overview screen."; do
  got=$(open_built_for "$p"); case $got in open_built=FAIL*) ok "F6 [$p] -> $got";; *) no "F6 [$p] -> [$got], want FAIL";; esac
done
got=$(open_built_for " the Shipments table, without the Docks section."); [ "$got" = open_built=ok ] && ok "F6 exclusion only -> ok" || no "F6 exclusion only -> [$got]"
got=$(open_built_for ""); case $got in open_built=FAIL*) ok "F6 no Part line -> $got";; *) no "F6 no Part line -> [$got], want FAIL";; esac
# Round 2: an empty or whitespace-only Part value is no evidence of the assigned part.
for p in "" "   "; do got=$(open_built_for "$p" line); case $got in open_built=FAIL*) ok "F6 empty Part [$p] -> $got";; *) no "F6 empty Part [$p] -> [$got], want FAIL";; esac; done
# Round 2 (F3): a malformed matching child is a failed search, even when a valid sibling parses.
d="$WORK/f3b"; mkdir -p "$d"; cp "$FIX/design-good.jsonl" "$d/design-good.jsonl"
# The broken child sits between two valid siblings, so it is not the last file the search reads in any order rg uses here.
sed "s|\"parentSession\":\"[^\"]*\"|\"parentSession\":\"$d/design-good.jsonl\"|" "$FIX/child-component.jsonl" > "$d/child-a-valid.jsonl"
cp "$d/child-a-valid.jsonl" "$d/child-z-valid.jsonl"
{ head -2 "$d/child-a-valid.jsonl"; echo '{"type":"message", broken'; } > "$d/child-m-broken.jsonl"
printf '%s\t%s\t%s\t%s\n' f3b design-app opus "$d/design-good.jsonl" > "$d/runs.tsv"
got=$(PI_SESSIONS_DIR="$d" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$d/runs.tsv" 2>&1 | grep '^f3b ')
case $got in *"children=FAIL("*"open_built=FAIL("*) ok "F3 malformed child plus valid sibling -> children FAIL";; *) no "F3 malformed child hidden: [$got]";; esac
# Round 2 (F5): the profile comes from the included part and its surface, not any mention of the demo.
mkt_part_for() { # $1 Part text, $2 Surface -> the child part the scorer picks
  local d="$WORK/f5-$RANDOM"; mkdir -p "$d"; cp "$FIX/design-mkt.jsonl" "$d/design-mkt.jsonl"
  local t="# Build: x"$'\n\n'"- **Part:** $1"$'\n'"- **Scope level:** component group (a section of a page). **Surface:** $2. **Mode:** headless."
  jq -c --arg p "$d/design-mkt.jsonl" --arg t "$t" \
    'if .type=="session" then .parentSession=$p elif (.type=="message" and .message.role=="user") then .message.content[0].text=$t else . end' "$FIX/child-mkt-hero.jsonl" > "$d/child.jsonl"
  printf '%s\t%s\t%s\t%s\n' f5 design-marketing opus "$d/design-mkt.jsonl" > "$d/runs.tsv"
  PI_SESSIONS_DIR="$d" bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$d/runs.tsv" 2>&1 | awk '$1=="f5/1" {print $2}'
}
for p in "the hero section with a link to the demo." "the pricing section, excluding the demo."; do
  got=$(mkt_part_for "$p" public-page); [ "$got" = mkt-copy-section ] && ok "F5 [$p] -> $got" || no "F5 [$p] -> [$got], want mkt-copy-section"
done
got=$(mkt_part_for "the product-demo section: an animated illustration of the Harbor timetable in the empty slot #demo." "public-page, with the product-demo slot as an illustration")
[ "$got" = mkt-section ] && ok "F5 demo part -> $got" || no "F5 demo part -> [$got], want mkt-section"
got=$(mkt_part_for "the timetable stage." "illustration"); [ "$got" = mkt-section ] && ok "F5 illustration surface -> $got" || no "F5 illustration surface -> [$got], want mkt-section"
# F7: the written-report fallback rejects an n/a entry with no fact, like the index.
mkdir -p "$WORK/f7" && sed 's/better-writing -> applied: empty copy/better-writing -> n\/a: /' "$FIX/score-time-limit.jsonl" > "$WORK/f7/score-time-limit.jsonl"
printf 'f7\tcomponent\tgpt\t%s\n' "$WORK/f7/score-time-limit.jsonl" > "$WORK/f7/runs.tsv"
bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/f7/runs.tsv" 2>&1 | grep '^f7 ' | grep -o 'passes=[^ ]*' | grep -q 'better-writing' \
  && ok "F7 empty n/a fact counts as missing" || no "F7 empty n/a fact accepted: [$(bash "$EVALS/score.sh" "$WORK/sessions.tsv" "$WORK/f7/runs.tsv" 2>&1 | grep '^f7 ')]"
# F8: the design-marketing Done keeps the existing FAQ section and does not ask to remove it.
grep -q 'nowhere in the code' "$EVALS/briefs/design-marketing.md" && no "F8 design-marketing Done still demands the FAQ be gone" || ok "F8 no removal demand"
brief_has design-marketing 'the existing FAQ section stays as it is'
# F1: --from refuses a symlinked source and a source that is not its own repository root, before creating the run.
F1="$WORK/f1runs"; mkdir -p "$F1" "$WORK/f1ext/node_modules" && git -C "$WORK/f1ext" init -q && echo x > "$WORK/f1ext/x" \
  && git -C "$WORK/f1ext" add x && git -C "$WORK/f1ext" -c user.name=t -c user.email=t@l commit -qm x && ln -s "$WORK/f1ext" "$F1/lnk"
EVAL_RUNS_ROOT="$F1" bash "$EVALS/new-run.sh" component f1a 5301 --from lnk >/dev/null 2>&1 && no "F1 symlinked --from source accepted" || ok "F1 symlinked --from source refused"
[ ! -e "$F1/f1a" ] && ok "F1 symlink refusal left no run" || no "F1 symlink refusal left $F1/f1a"
git -C "$F1" init -q && touch "$F1/.keep" && git -C "$F1" add .keep && git -C "$F1" -c user.name=t -c user.email=t@l commit -qm root && mkdir -p "$F1/sub/node_modules"
EVAL_RUNS_ROOT="$F1" bash "$EVALS/new-run.sh" component f1b 5301 --from sub >/dev/null 2>&1 && no "F1 non-root --from source accepted" || ok "F1 non-root --from source refused"
[ ! -e "$F1/f1b" ] && ok "F1 non-root refusal left no run" || no "F1 non-root refusal left $F1/f1b"

echo "----"
[ "$FAILS" -eq 0 ] && { echo "eval tests: PASS"; exit 0; } || { echo "eval tests: $FAILS failure(s)"; exit 1; }
