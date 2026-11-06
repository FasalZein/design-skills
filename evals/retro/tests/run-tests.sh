#!/usr/bin/env bash
# Fixture tests for evals/retro/index.sh and compliance.sh. Expected values come from spec D22
# and the s2 review (F7, F9-F12), not from script output. Exit 0 = all pass.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
RETRO=$(dirname "$HERE")
FIX="$HERE/fixtures"
FAILS=0
ok() { echo "ok: $*"; }
no() { FAILS=$((FAILS+1)); echo "FAIL: $*"; }
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Column of the row whose title is $1, by header name $2.
col() { awk -F'\t' -v t="$1" -v c="$2" 'NR==1{for(i=1;i<=NF;i++) h[$i]=i; next} $(h["title"])==t {print $(h[c])}' "$TSV"; }
expect() { local got; got=$(col "$1" "$2"); [ "$got" = "$3" ] && ok "$1 $2=$3" || no "$1 $2: want [$3] got [$got]"; }

# F11: relative OUT resolves against the caller's directory, not the sessions directory.
mkdir -p "$WORK/caller"
( cd "$WORK/caller" && PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/index.sh" out/sessions.tsv >"$WORK/index.log" 2>&1 ); st=$?
TSV="$WORK/caller/out/sessions.tsv"
[ "$st" -eq 0 ] && ok "index on valid fixtures exits 0" || { no "index on valid fixtures exit $st"; cat "$WORK/index.log"; }
[ -f "$TSV" ] && ok "F11 relative OUT lands in the caller directory" || no "F11 relative OUT not at caller/out/sessions.tsv"
[ -e "$FIX/good/out" ] && { no "F11 relative OUT created inside the sessions directory"; rm -rf "$FIX/good/out"; }
[ -f "$TSV" ] || TSV=/dev/null

# F7: skill text counts independent of frontmatter field order; a named-section read counts;
# a failed read and a path in call arguments alone do not.
expect "f7 field order" skills_returned "interface-review"
expect "f7 field order" skill_count 1
expect "f7 section read" skills_returned "design-qa"
expect "f7 section read" skill_count 1
expect "f7 concatenated skills" skills_returned "design-craft,laws-of-ux"
# A heading list holds no section; a shell variable in the path names no skill.
expect "f7 heading list" skill_count 0

# F9: pass outcomes come from the report artifact; an unfilled template is not an outcome.
expect "f9 artifact report" passes_applied 1
expect "f9 artifact report" passes_na 1
expect "f9 artifact report" passes "better-writing -> applied: rewrote the empty state; state-machine -> n/a: the part has one state"
expect "f9 artifact report" result DONE
expect "f9 template copy" passes_applied 0
expect "f9 template copy" passes_na 0
expect "f9 template copy" result none

# F10: ask_user counts by tool-call name, direct and inside codemode; prose mentions do not count.
expect "f10 asks" asks 2

# F11: compliance resolves a relative TSV against the caller's directory.
( cd "$WORK/caller" && PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/compliance.sh" 2026-11-03T05 out/sessions.tsv >"$WORK/comp.log" 2>&1 ); st=$?
# f9 claims better-writing without loading it: relative-path resolution succeeds, compliance fails.
[ "$st" -eq 1 ] && grep -qF 'pass=[better-writing]' "$WORK/comp.log" && grep -q '^== sessions since 2026-11-03T05: 7$' "$WORK/comp.log" && ok "F11 compliance reads a relative TSV" || { no "F11 compliance on relative TSV (exit $st)"; cat "$WORK/comp.log"; }

# F12: failures exit nonzero; a valid empty index exits 0.
PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/compliance.sh" 2026-11-03T05 "$WORK/missing.tsv" >/dev/null 2>&1 && no "F12 compliance with a missing TSV exits 0" || ok "F12 compliance with a missing TSV exits nonzero"
PI_SESSIONS_DIR="$FIX/bad" bash "$RETRO/index.sh" "$WORK/bad.tsv" >/dev/null 2>&1 && no "F12 index with PARSE_FAIL exits 0" || ok "F12 index with PARSE_FAIL exits nonzero"
grep -q '^PARSE_FAIL' "$WORK/bad.tsv" 2>/dev/null && ok "F12 PARSE_FAIL row written" || no "F12 PARSE_FAIL row missing"
PI_SESSIONS_DIR="$FIX/bad" bash "$RETRO/compliance.sh" 2026-11-03T05 "$WORK/bad.tsv" >/dev/null 2>&1 && no "F12 compliance on a TSV with PARSE_FAIL exits 0" || ok "F12 compliance on a TSV with PARSE_FAIL exits nonzero"
PI_SESSIONS_DIR="$WORK/no-such-dir" bash "$RETRO/index.sh" "$WORK/x.tsv" >/dev/null 2>&1 && no "F12 index with a missing sessions dir exits 0" || ok "F12 index with a missing sessions dir exits nonzero"
PI_SESSIONS_DIR="$FIX/good" bash "$RETRO/index.sh" /dev/null/x.tsv >/dev/null 2>&1 && no "F12 index with an unwritable OUT exits 0" || ok "F12 index with an unwritable OUT exits nonzero"
mkdir -p "$WORK/empty"
PI_SESSIONS_DIR="$WORK/empty" bash "$RETRO/index.sh" "$WORK/empty.tsv" >/dev/null 2>&1 && ok "F12 valid empty index exits 0" || no "F12 valid empty index exits nonzero"
PI_SESSIONS_DIR="$WORK/empty" bash "$RETRO/compliance.sh" 2026-11-03T05 "$WORK/empty.tsv" >/dev/null 2>&1 && ok "F12 compliance on a valid empty index exits 0" || no "F12 compliance on a valid empty index exits nonzero"

# Every column of the README "What they count" contract, on fixtures/columns (hardener gate, 2026-11-03).
# c1 exercises each counted signal; c2 is a minimal run with a numeric timestamp entry; c3 is a worker session;
# c4 has no assistant turn; c7 is a single entry without title;
# c5 holds tool results that are no skill load (no heading, no description, a heading list, two skill paths,
# a "description:" line before an unfenced "name:" line, a frontmatter without name, a result without its call);
# c6 holds a 40-line frontmatter block.
COLS="$FIX/columns"
PI_SESSIONS_DIR="$COLS" bash "$RETRO/index.sh" "$WORK/cols.tsv" >"$WORK/cols.log" 2>&1 && ok "index on column fixtures exits 0" || { no "index on column fixtures"; cat "$WORK/cols.log"; }
grep -q '^index: 6 sessions -> ' "$WORK/cols.log" && ok "only design and design-builder sessions are indexed" || no "index session count: $(cat "$WORK/cols.log")"
TSV="$WORK/cols.tsv"
C1="c1 columns"   # the title's tab becomes a space
expect "$C1" start 2026-11-04T06:00
expect "$C1" agent design-builder
expect "$C1" model m/ref:high
expect "$C1" bytes "$(wc -c < "$COLS/c1-columns.jsonl" | tr -d ' ')"
expect "$C1" turns 11
expect "$C1" user_msgs 3
expect "$C1" peak_ctx 2010
expect "$C1" out_tok 39
expect "$C1" cost 0.58
expect "$C1" dur_min 42
expect "$C1" errors 2
expect "$C1" browser_cmds 3
expect "$C1" skills_returned "alpha,beta,gamma"
expect "$C1" skill_count 3
expect "$C1" asks 3
expect "$C1" passes_applied 2
expect "$C1" passes_na 1
expect "$C1" passes "copy -> applied: shorter labels; motion -> n/a: no animation; layout -> applied: tighter grid"
expect "$C1" result PARTIAL
expect "$C1" file ./c1-columns.jsonl
expect "c2 minimal" model m/ref
expect "c2 minimal" turns 1
expect "c2 minimal" peak_ctx 500
expect "c2 minimal" cost 0.25
expect "c2 minimal" dur_min 0
expect "c2 minimal" errors 0
expect "c2 minimal" skill_count 0
expect "c2 minimal" passes ""
expect "c2 minimal" result DONE
expect "c4 old" start 2026-11-02T09:00
expect "c4 old" agent design
expect "c4 old" model ""
expect "c4 old" turns 0
expect "c4 old" peak_ctx 0
expect "c4 old" out_tok 0
expect "c4 old" cost 0
expect "c4 old" dur_min 0
expect "c4 old" result none
expect "c5 not loaded" skills_returned ""
expect "c5 not loaded" skill_count 0
expect "c5 not loaded" out_tok 0
expect "c5 not loaded" peak_ctx 5
expect "c5 not loaded" result DONE
expect "c6 long frontmatter" skills_returned omega
expect "" start 2026-11-01T10:00
expect "" dur_min 0
expect "" result none

# README "What they count", fixtures/edges (retro index fixes, 2026-11-03): an entry with an empty change or fact
# is an unfilled entry, not an outcome; a frontmatter block counts at any length.
PI_SESSIONS_DIR="$FIX/edges" bash "$RETRO/index.sh" "$WORK/edges.tsv" >"$WORK/edges.log" 2>&1 && ok "index on edge fixtures exits 0" || { no "index on edge fixtures"; cat "$WORK/edges.log"; }
TSV="$WORK/edges.tsv"
expect "e1 empty pass" passes_applied 1
expect "e1 empty pass" passes_na 0
expect "e1 empty pass" passes "copy -> applied: shorter labels"
# h-opus-2-comp retro candidate 1: the first entry sits on the PASSES: line, and a change may hold < and > (HTML
# tags, arrows); only a placeholder that starts with "<" is unfilled.
expect "e3 passes on the PASSES line" passes_applied 2
expect "e3 passes on the PASSES line" passes_na 1
expect "e3 passes on the PASSES line" passes 'better-accessibility -> applied: the Day line is a <ul aria-label="Today"> with aria-busy while loading; break-ui -> applied: 1,234 rows -> no overflow at 375; review-animations -> n/a: no motion in either part'
# Parent decision after owner decision 31 (h-opus-3-docks "break-ui -> applied (+ fix):"): a qualifier between the
# status and the colon keeps the status; the entry is normalized, and a qualified entry with no change stays unfilled.
expect "e4 status qualifier" passes_applied 2
expect "e4 status qualifier" passes_na 1
expect "e4 status qualifier" passes "break-ui -> applied: slots past 16:00 are cut at the edge; review-animations -> n/a: the part has no animation; state-machine -> applied: one state prop"
expect "e2 60-line frontmatter" skills_returned psi
expect "e2 60-line frontmatter" skill_count 1
# A session whose only timestamp cannot be parsed is unreadable input: a PARSE_FAIL row and exit 1, not dur_min 0.
PI_SESSIONS_DIR="$FIX/bad-timestamp" bash "$RETRO/index.sh" "$WORK/badts.tsv" >/dev/null 2>&1 && no "index with one unparseable timestamp exits 0" || ok "index with one unparseable timestamp exits nonzero"
grep -q '^PARSE_FAIL	\./t1-one-bad-timestamp\.jsonl$' "$WORK/badts.tsv" 2>/dev/null && ok "one unparseable timestamp writes a PARSE_FAIL row" || no "one unparseable timestamp: no PARSE_FAIL row ($(tail -n +2 "$WORK/badts.tsv" 2>/dev/null))"
TSV="$WORK/cols.tsv"

# compliance: SINCE and agent filters, per-session checks, and the per agent+model summary.
awk -F'\t' -v OFS='\t' '{print} $20=="c2 minimal" {$2="worker"; print}' "$TSV" > "$WORK/cols-worker.tsv"
cmp_out() { # cmp_out name since; expected output on stdin
  local want; want=$(cat)
  local got; got=$(PI_SESSIONS_DIR="$COLS" bash "$RETRO/compliance.sh" "$2" "$WORK/cols-worker.tsv" 2>&1)
  [ "$got" = "$want" ] && ok "$1" || { no "$1"; diff <(printf '%s\n' "$want") <(printf '%s\n' "$got"); }
}
cmp_out "compliance per-session lines and summary" 2026-11-04T06 <<'EOF'
== sessions since 2026-11-04T06: 2
2026-11-04T06:00 design-builder m/ref scan=1 shots=1 chrome=1 plainAB=1 tsc=1 followups=2 asks=3 passes=2 applied/1 n/a returned=[alpha,beta,gamma] claimed=[ alpha, beta]
MISMATCH 2026-11-04T06:00 design-builder m/ref pass=[copy] applied without own skill text
MISMATCH 2026-11-04T06:00 design-builder m/ref pass=[layout] applied without own skill text
2026-11-04T06:30 design-builder m/ref scan=0 shots=0 chrome=0 plainAB=0 tsc=0 followups=0 asks=0 passes=0 applied/0 n/a returned=[-] claimed=[-]
== summary by agent and model (skills = skill texts returned in tool results)
design-builder m/ref: runs=2 cost=$0.83 peak_ctx_max=2010 skills_mean=1.5 zero_skill_runs=1 followups=2
EOF
cmp_out "compliance SINCE includes a session that starts at SINCE" 2026-11-04T06:30 <<'EOF'
== sessions since 2026-11-04T06:30: 1
2026-11-04T06:30 design-builder m/ref scan=0 shots=0 chrome=0 plainAB=0 tsc=0 followups=0 asks=0 passes=0 applied/0 n/a returned=[-] claimed=[-]
== summary by agent and model (skills = skill texts returned in tool results)
design-builder m/ref: runs=1 cost=$0.25 peak_ctx_max=500 skills_mean=0.0 zero_skill_runs=1 followups=0
EOF
# The first TSV line is the header, even when it reads like a design row.
tail -n +2 "$WORK/cols-worker.tsv" > "$WORK/cols-noheader.tsv"
PI_SESSIONS_DIR="$COLS" bash "$RETRO/compliance.sh" 2026-11-04T06 "$WORK/cols-noheader.tsv" 2>&1 | grep -q '^== sessions since 2026-11-04T06: 1$' && ok "compliance skips the TSV header line" || no "compliance header line read as a session"
# An unreadable session file exits 1, also when the TSV already holds a PARSE_FAIL row.
awk -F'\t' -v OFS='\t' 'NR==1 || $20=="c2 minimal" {if (NR>1) $21="./missing.jsonl"; print}' "$TSV" > "$WORK/cols-missing.tsv"
PI_SESSIONS_DIR="$COLS" bash "$RETRO/compliance.sh" 2026-11-04T06 "$WORK/cols-missing.tsv" >/dev/null 2>&1 && no "compliance with a missing session file exits 0" || ok "compliance with a missing session file exits nonzero"
{ cat "$WORK/cols-missing.tsv"; printf 'PARSE_FAIL\t./broken.jsonl\n'; } > "$WORK/cols-missing-pf.tsv"
PI_SESSIONS_DIR="$COLS" bash "$RETRO/compliance.sh" 2026-11-04T06 "$WORK/cols-missing-pf.tsv" >/dev/null 2>&1 && no "compliance with a PARSE_FAIL row and a missing session file exits 0" || ok "compliance with a PARSE_FAIL row and a missing session file exits nonzero"
# Input errors name their cause on stderr.
mkdir -p "$WORK/tsvdir"
PI_SESSIONS_DIR="$COLS" bash "$RETRO/compliance.sh" 2026-11-04T06 "$WORK/tsvdir" 2>&1 >/dev/null | grep -q "^compliance: cannot read $WORK/tsvdir$" && ok "compliance rejects a TSV path that is a folder" || no "compliance accepted a folder as TSV"
PI_SESSIONS_DIR="$WORK/no-such-dir" bash "$RETRO/compliance.sh" 2026-11-04T06 "$TSV" >/dev/null 2>&1 && no "compliance with a missing sessions dir exits 0" || ok "compliance with a missing sessions dir exits nonzero"
PI_SESSIONS_DIR="$FIX/bad" bash "$RETRO/index.sh" "$WORK/bad2.tsv" 2>&1 >/dev/null | grep -q '^index: 1 PARSE_FAIL row(s)$' && ok "index names the PARSE_FAIL count" || no "index PARSE_FAIL message"
mkdir -p "$WORK/ro" && chmod 555 "$WORK/ro"
PI_SESSIONS_DIR="$COLS" bash "$RETRO/index.sh" "$WORK/ro/x.tsv" 2>&1 >/dev/null | grep -q "^index: cannot write $WORK/ro/x.tsv$" && ok "index reports an unwritable OUT" || no "index unwritable OUT message"
chmod 755 "$WORK/ro"
mkdir -p "$WORK/unread" && cp "$COLS/c2-minimal.jsonl" "$WORK/unread/" && printf '{}\n' > "$WORK/unread/locked.jsonl" && chmod 000 "$WORK/unread/locked.jsonl"
PI_SESSIONS_DIR="$WORK/unread" bash "$RETRO/index.sh" "$WORK/unread.tsv" 2>&1 >/dev/null | grep -q '^index: session search failed in ' && ok "index fails on an unreadable session file" || no "index ignored an unreadable session file"
chmod 644 "$WORK/unread/locked.jsonl"

# A skill's reference file counts as a load of that skill when the returned text matches the file on disk
# (owner decision 22, 2026-11-03); the path in call arguments alone still never counts (D22).
mkdir -p "$WORK/refs"
for f in "$FIX"/refs/*.jsonl; do sed "s|__REFS__|$FIX/refs-skills|g" "$f" > "$WORK/refs/$(basename "$f")"; done
PI_SESSIONS_DIR="$WORK/refs" bash "$RETRO/index.sh" "$WORK/refs.tsv" >"$WORK/refs.log" 2>&1 && ok "index on reference fixtures exits 0" || { no "index on reference fixtures"; cat "$WORK/refs.log"; }
TSV="$WORK/refs.tsv"
expect "r1 reference read" skills_returned demo-taste
expect "r1 reference read" skill_count 1
expect "r3 partial reference read" skills_returned demo-taste
# A failed read, text that is not the file's, a missing file, and a references/ folder outside a skills/ folder.
expect "r2 reference not loaded" skills_returned ""
expect "r2 reference not loaded" skill_count 0

# D35: multiline fields, bullet entries, and one mismatch per unsupported applied pass.
PI_SESSIONS_DIR="$FIX/compliance" bash "$RETRO/index.sh" "$WORK/compliance.tsv" >/dev/null 2>&1
PI_SESSIONS_DIR="$FIX/compliance" bash "$RETRO/compliance.sh" 2026-11-06 "$WORK/compliance.tsv" >"$WORK/mismatch.log" 2>&1; st=$?
[ "$st" -eq 1 ] && ok "D35 applied without own skill text exits 1" || no "D35 unsupported applied passes exit $st"
[ "$(grep -c '^MISMATCH ' "$WORK/mismatch.log")" -eq 2 ] && ok "D35 one mismatch per unsupported entry" || no "D35 mismatch count"
grep -qF 'pass=[laws-of-ux]' "$WORK/mismatch.log" && grep -qF 'pass=[States]' "$WORK/mismatch.log" && ok "D35 skill and concern names both checked" || no "D35 missing skill or concern mismatch"
grep -qF 'claimed=[- states -> state-machine; - look -> demo-taste]' "$WORK/mismatch.log" && ok "D35 LOADED block on its own line" || no "D35 multiline LOADED lost"

# A frozen report recovers a codemode-written report; a matching reference read covers only its own skill.
for f in "$WORK"/refs/*.jsonl; do
  printf 'RESULT: DONE\nLOADED:\n- look -> demo-taste\nPASSES:\n- demo-taste -> applied: tuned the layout\n- state-machine -> n/a: one state\nVERIFY: scanner exit 0\n' > "${f%.jsonl}.report.md"
done
PI_SESSIONS_DIR="$WORK/refs" bash "$RETRO/compliance.sh" 2026-11-03 "$WORK/refs.tsv" >"$WORK/refs-comp.log" 2>&1; st=$?
[ "$st" -eq 1 ] && [ "$(grep -c '^MISMATCH ' "$WORK/refs-comp.log")" -eq 1 ] && ok "D35 reference text covers its own pass; failed reference read does not" || no "D35 reference evidence mismatch"
# Keep only the two sessions whose reference text came back, to prove the success exit too.
awk -F'\t' 'NR==1 || $14==1' "$WORK/refs.tsv" > "$WORK/refs-ok.tsv"
PI_SESSIONS_DIR="$WORK/refs" bash "$RETRO/compliance.sh" 2026-11-03 "$WORK/refs-ok.tsv" >"$WORK/refs-ok.log" 2>&1 && ok "D35 evidenced applied and n/a passes exit 0" || no "D35 evidenced passes rejected"
grep -q 'passes=1 applied/1 n/a' "$WORK/refs-ok.log" && ok "D35 frozen report supplies PASSES" || no "D35 frozen report not read"

echo "----"
[ "$FAILS" -eq 0 ] && { echo "retro tests: PASS"; exit 0; } || { echo "retro tests: $FAILS failure(s)"; exit 1; }
