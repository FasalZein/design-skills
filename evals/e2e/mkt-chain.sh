#!/usr/bin/env bash
# Running-app receipt for marketing chain mode: what a lower level commits reaches the next level's run.
# It sets up a mkt-primitive-set run, commits a token in src/index.css and leaves one uncommitted, chains
# mkt-component with --from, starts the chained run's dev server and runs evals/e2e/mkt-chain.json in Chrome: the page
# renders the committed token, not the uncommitted one, with a screenshot at 1440. It also fetches one fixture photo.
# Usage: evals/e2e/mkt-chain.sh <shots-dir> [port]   Needs npm ci in evals/fixture-marketing and agent-browser-chrome.
# Exit 0 = the flow passed. The runs live in a temp folder and are deleted at the end.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
SHOTS=${1:?usage: mkt-chain.sh <shots-dir> [port]}; PORT=${2:-5391}
mkdir -p "$SHOTS"; SHOTS=$(cd "$SHOTS" && pwd)
TMP=$(mktemp -d); SESSION="mkt-chain-$$"; DEV=""
cleanup() { agent-browser-chrome --session "$SESSION" close >/dev/null 2>&1 || true
  [ -n "$DEV" ] && { pkill -P "$DEV" 2>/dev/null || true; kill "$DEV" 2>/dev/null || true; }
  rm -rf "$TMP"; }
trap cleanup EXIT
EVAL_RUNS_ROOT="$TMP" bash "$HERE/../new-run.sh" mkt-primitive-set lower "$PORT" >/dev/null
echo ':root { --chain-proof: committed; }' >> "$TMP/lower/src/index.css"
git -C "$TMP/lower" -c user.name=e2e -c user.email=e2e@localhost commit -qam "lower level built"
echo ':root { --uncommitted-proof: left; }' >> "$TMP/lower/src/index.css"
EVAL_RUNS_ROOT="$TMP" bash "$HERE/../new-run.sh" mkt-component upper "$PORT" --from lower >/dev/null
RUN="$TMP/upper"
(cd "$RUN" && npm run typecheck >/dev/null) || { echo "mkt-chain: typecheck failed" >&2; exit 1; }
(cd "$RUN" && exec npm run dev -- --port "$PORT" --strictPort >"$TMP/dev.log" 2>&1) & DEV=$!
for _ in $(seq 60); do curl -fsS "http://localhost:$PORT/" >/dev/null 2>&1 && break; sleep 0.5; done
curl -fsS "http://localhost:$PORT/" >/dev/null || { echo "mkt-chain: dev server did not start" >&2; cat "$TMP/dev.log" >&2; exit 1; }
curl -fsS -o /dev/null "http://localhost:$PORT/src/assets/photos/modern-loading-dock.jpg" || { echo "mkt-chain: fixture photo not served" >&2; exit 1; }
sed -e "s|{URL}|http://localhost:$PORT/|" -e "s|{SHOTS}|$SHOTS|g" "$HERE/mkt-chain.json" \
  | agent-browser-chrome --session "$SESSION" batch --bail
echo "mkt-chain: flow passed; shots in $SHOTS"
