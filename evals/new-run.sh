#!/usr/bin/env bash
# Set up one eval run: copy a fixture to a fresh git repo and print the brief.
# Usage: evals/new-run.sh <part> <run-name> <port>
#   part      app product (evals/fixture/):                primitive-set | component | section | screen | design-app
#             marketing product (evals/fixture-marketing/): mkt-primitive-set | mkt-component | mkt-section | mkt-page | design-marketing
#             The brief is evals/briefs/<part>.md.
#   run-name  letters, digits, dot, dash, underscore; the run directory name
#   port      the dev-server port the run must use
# The run directory is $EVAL_RUNS_ROOT/<run-name> (default <repo root>/.eval-runs, which git ignores).
# Bottom-up overlays (evals/overlays/) go in before the initial commit: higher parts build on the approved
# lower-level parts. The design-* parts get the product's DESIGN.md variant with one open part instead.
# Delete a run after scoring with evals/clean-run.sh.
# Progress goes to stderr; stdout holds only the rendered brief. Exit 1 on bad input or an existing run.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
PART=${1:-}; NAME=${2:-}; PORT=${3:-}
usage() { echo "usage: new-run.sh <primitive-set|component|section|screen|design-app|mkt-primitive-set|mkt-component|mkt-section|mkt-page|design-marketing> <run-name> <port>" >&2; exit 1; }
case $PART in
  primitive-set)     FIX=fixture;           OVERLAYS="";;
  component)         FIX=fixture;           OVERLAYS="primitives";;
  section|screen)    FIX=fixture;           OVERLAYS="primitives components";;
  design-app)        FIX=fixture;           OVERLAYS="design-app";;
  mkt-primitive-set) FIX=fixture-marketing; OVERLAYS="";;
  mkt-component|mkt-section) FIX=fixture-marketing; OVERLAYS="mkt-primitives";;
  mkt-page)          FIX=fixture-marketing; OVERLAYS="mkt-primitives mkt-components";;
  design-marketing)  FIX=fixture-marketing; OVERLAYS="design-marketing";;
  *) usage;;
esac
[[ $NAME =~ ^[A-Za-z0-9._-]+$ ]] && [[ $NAME != .* ]] || usage
[[ $PORT =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || usage
ROOT=${EVAL_RUNS_ROOT:-$(dirname "$HERE")/.eval-runs}
RUN="$ROOT/$NAME"
FIXTURE="$HERE/$FIX"
[ -e "$RUN" ] && { echo "new-run: $RUN exists; pick a new run name" >&2; exit 1; }
[ -d "$FIXTURE/node_modules" ] || { echo "new-run: $FIXTURE/node_modules missing; run npm ci in evals/$FIX first" >&2; exit 1; }

mkdir -p "$ROOT"
# APFS clone (cp -c): node_modules costs no disk until a file changes. Plain copy where cloning is unsupported.
cp -cR "$FIXTURE" "$RUN" 2>/dev/null || { rm -rf "$RUN"; cp -R "$FIXTURE" "$RUN"; }
rm -rf "$RUN/dist" "$RUN/node_modules/.tmp" "$RUN/node_modules/.vite"
for o in $OVERLAYS; do cp -R "$HERE/overlays/$o/." "$RUN/"; done

git -C "$RUN" init -q -b main
git -C "$RUN" add -A
git -C "$RUN" -c user.name="design-skills eval" -c user.email="eval@localhost" commit -q -m "Eval fixture for $PART ($NAME)"
echo "new-run: $RUN ($PART on $FIX, port $PORT, $(git -C "$RUN" rev-parse --short HEAD))" >&2

sed -e "s|{RUN_DIR}|$RUN|g" -e "s|{PORT}|$PORT|g" -e "s|{RUN_NAME}|$NAME|g" "$HERE/briefs/$PART.md"
