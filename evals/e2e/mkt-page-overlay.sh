#!/usr/bin/env bash
# End-to-end receipt for the marketing overlays (review F9): the mkt-page run with the mkt-primitives token layer and
# the approved PricingCard, rendered in Chrome. The stock pricing section does not use PricingCard yet (the mkt-page
# builder wires it in), so this check swaps in a pricing section that maps the plans to PricingCard, the way the
# mkt-page brief tells the builder to use it. Then it runs evals/e2e/mkt-page-pricing.json: three cards, the featured
# badge, the token-layer mono price font, mailto calls to action, the hero "See pricing" jump, and no horizontal
# scroll at 375px, with a screenshot at 1440 and at 375.
# Usage: evals/e2e/mkt-page-overlay.sh <shots-dir> [port]   Needs npm ci in evals/fixture-marketing and agent-browser-chrome.
# Exit 0 = the flow passed. The run copy lives in a temp folder and is deleted at the end.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
SHOTS=${1:?usage: mkt-page-overlay.sh <shots-dir> [port]}; PORT=${2:-5391}
mkdir -p "$SHOTS"; SHOTS=$(cd "$SHOTS" && pwd)
TMP=$(mktemp -d); SESSION="mkt-overlay-$$"; DEV=""
cleanup() { agent-browser-chrome --session "$SESSION" close >/dev/null 2>&1 || true
  [ -n "$DEV" ] && { pkill -P "$DEV" 2>/dev/null || true; kill "$DEV" 2>/dev/null || true; }
  rm -rf "$TMP"; }
trap cleanup EXIT
EVAL_RUNS_ROOT="$TMP" bash "$HERE/../new-run.sh" mkt-page overlay "$PORT" >/dev/null
RUN="$TMP/overlay"
cat > "$RUN/src/sections/pricing.tsx" <<'TSX'
import { PricingCard } from '@/components/pricing-card'
import { plans } from '@/data/landing'

export function Pricing() {
  return (
    <section id="pricing" className="mx-auto max-w-6xl px-6 py-24">
      <h2 className="mb-12 text-center text-3xl font-semibold">Pricing</h2>
      <div className="grid gap-6 md:grid-cols-3">
        {plans.map((plan) => <PricingCard key={plan.id} plan={plan} />)}
      </div>
    </section>
  )
}
TSX
(cd "$RUN" && npm run typecheck >/dev/null) || { echo "mkt-page-overlay: typecheck failed" >&2; exit 1; }
(cd "$RUN" && exec npm run dev -- --port "$PORT" --strictPort >"$TMP/dev.log" 2>&1) & DEV=$!
for _ in $(seq 60); do curl -fsS "http://localhost:$PORT/" >/dev/null 2>&1 && break; sleep 0.5; done
curl -fsS "http://localhost:$PORT/" >/dev/null || { echo "mkt-page-overlay: dev server did not start" >&2; cat "$TMP/dev.log" >&2; exit 1; }
sed -e "s|{URL}|http://localhost:$PORT/|" -e "s|{SHOTS}|$SHOTS|g" "$HERE/mkt-page-pricing.json" \
  | agent-browser-chrome --session "$SESSION" batch --bail
echo "mkt-page-overlay: flow passed; shots in $SHOTS"
