#!/usr/bin/env bash
# Set up one eval run: copy a fixture (or an earlier run) to a fresh git repo and print the brief.
# Usage: evals/new-run.sh <part> <run-name> <port> [--from <previous-run-name>]
#   part      app product (evals/fixture/):                primitive-set | component | section | screen | design-app
#             marketing product (evals/fixture-marketing/): mkt-primitive-set | mkt-component | mkt-section | mkt-page | design-marketing
#             The brief is evals/briefs/<part>.md.
#   run-name  letters, digits, dot, dash, underscore; the run directory name
#   port      the dev-server port the run must use
#   --from    Harbor builder parts only (a chain): start from the committed HEAD of that earlier run in the same
#             runs folder, with its node_modules cloned. Without --from, a Harbor run starts from the stock fixture.
# The run directory is $EVAL_RUNS_ROOT/<run-name> (default <repo root>/.eval-runs, which git ignores).
# Marketing overlays (evals/overlays/mkt-*) go in before the initial commit: higher marketing parts build on the
# approved lower-level parts. The design-* parts get the product's DESIGN.md variant with one open part instead.
# Every run gets one initial commit. Delete a run after scoring with evals/clean-run.sh.
# Progress goes to stderr; stdout holds only the rendered brief. Exit 1 on bad input or an existing run.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
PART=${1:-}; NAME=${2:-}; PORT=${3:-}
usage() { echo "usage: new-run.sh <primitive-set|component|section|screen|design-app|mkt-primitive-set|mkt-component|mkt-section|mkt-page|design-marketing> <run-name> <port> [--from <previous-run-name>]" >&2; exit 1; }
FROM=""
if [ $# -gt 3 ]; then
  [ $# -eq 5 ] && [ "$4" = --from ] || usage
  FROM=$5
fi
case $PART in
  primitive-set|component|section|screen) FIX=fixture; OVERLAYS=""; CHAIN=yes;;
  design-app)        FIX=fixture;           OVERLAYS="design-app";;
  mkt-primitive-set) FIX=fixture-marketing; OVERLAYS="";;
  mkt-component|mkt-section) FIX=fixture-marketing; OVERLAYS="mkt-primitives";;
  mkt-page)          FIX=fixture-marketing; OVERLAYS="mkt-primitives mkt-components";;
  design-marketing)  FIX=fixture-marketing; OVERLAYS="design-marketing";;
  *) usage;;
esac
valid_name() { [[ $1 =~ ^[A-Za-z0-9._-]+$ ]] && [[ $1 != .* ]]; }
valid_name "$NAME" || usage
[[ $PORT =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || usage
[ -z "$FROM" ] || { [ "${CHAIN:-}" = yes ] && valid_name "$FROM"; } || usage
ROOT=${EVAL_RUNS_ROOT:-$(dirname "$HERE")/.eval-runs}
RUN="$ROOT/$NAME"
FIXTURE="$HERE/$FIX"
[ -e "$RUN" ] && { echo "new-run: $RUN exists; pick a new run name" >&2; exit 1; }

mkdir -p "$ROOT"
if [ -n "$FROM" ]; then
  PREV="$ROOT/$FROM"
  # The source must be a real run: a directory directly inside the physical runs root, not a symlink,
  # and the root of its own git repository (a plain folder would archive an ancestor repository's HEAD).
  [ -L "$PREV" ] && { echo "new-run: $PREV is a symlink; refusing" >&2; exit 1; }
  [ -d "$PREV" ] || { echo "new-run: $PREV is no run directory" >&2; exit 1; }
  ROOT_REAL=$(cd "$ROOT" && pwd -P); PREV_REAL=$(cd "$PREV" && pwd -P)
  [ "$(dirname "$PREV_REAL")" = "$ROOT_REAL" ] || { echo "new-run: $PREV resolves outside $ROOT_REAL; refusing" >&2; exit 1; }
  [ "$(git -C "$PREV_REAL" rev-parse --show-toplevel 2>/dev/null)" = "$PREV_REAL" ] || { echo "new-run: $PREV_REAL is not its own git repository" >&2; exit 1; }
  PREV=$PREV_REAL
  PREV_SHA=$(git -C "$PREV" rev-parse --short HEAD 2>/dev/null) || { echo "new-run: $PREV is no run with a commit" >&2; exit 1; }
  [ -d "$PREV/node_modules" ] || { echo "new-run: $PREV/node_modules missing" >&2; exit 1; }
  mkdir "$RUN"
  # Only committed work carries over: uncommitted changes and untracked files of the earlier run stay behind.
  git -C "$PREV" archive HEAD | tar -x -C "$RUN"
  # APFS clone (cp -c): node_modules costs no disk until a file changes. Plain copy where cloning is unsupported.
  cp -cR "$PREV/node_modules" "$RUN/node_modules" 2>/dev/null || { rm -rf "$RUN/node_modules"; cp -R "$PREV/node_modules" "$RUN/node_modules"; }
  rm -rf "$RUN/node_modules/.tmp" "$RUN/node_modules/.vite"
  SOURCE="run $FROM at $PREV_SHA"
  START="This run continues a chain: it starts from the committed result of run $FROM (commit $PREV_SHA), so the lower-level parts of this chain are in place. Build on them as they are."
else
  [ -d "$FIXTURE/node_modules" ] || { echo "new-run: $FIXTURE/node_modules missing; run npm ci in evals/$FIX first" >&2; exit 1; }
  cp -cR "$FIXTURE" "$RUN" 2>/dev/null || { rm -rf "$RUN"; cp -R "$FIXTURE" "$RUN"; }
  rm -rf "$RUN/dist" "$RUN/node_modules/.tmp" "$RUN/node_modules/.vite"
  for o in $OVERLAYS; do cp -R "$HERE/overlays/$o/." "$RUN/"; done
  SOURCE=$FIX
  START="This run starts from the stock fixture: no lower-level part of this chain is built yet."
fi

git -C "$RUN" init -q -b main
git -C "$RUN" add -A
git -C "$RUN" -c user.name="design-skills eval" -c user.email="eval@localhost" commit -q -m "Eval fixture for $PART ($NAME) from $SOURCE"
echo "new-run: $RUN ($PART from $SOURCE, port $PORT, $(git -C "$RUN" rev-parse --short HEAD))" >&2

sed -e "s|{RUN_DIR}|$RUN|g" -e "s|{PORT}|$PORT|g" -e "s|{RUN_NAME}|$NAME|g" -e "s|{START}|$START|g" "$HERE/briefs/$PART.md"
