#!/usr/bin/env bash
# Set up one eval run: copy the fixture to a fresh git repo outside this repository and print the brief.
# Usage: evals/new-run.sh <part> <run-name> <port>
#   part      primitive-set | component | screen   (evals/briefs/<part>.md)
#   run-name  letters, digits, dot, dash, underscore; the run directory name
#   port      the dev-server port the builder must use
# The run directory is $EVAL_RUNS_ROOT/<run-name> (default ~/Dev/AI/Skills/design-skills-eval-runs).
# The component and screen runs get the approved lower-level parts (evals/overlays/) before the
# initial commit, so they build bottom-up on parts that already passed.
# Progress goes to stderr; stdout holds only the rendered brief. Exit 1 on bad input or an existing run.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
PART=${1:-}; NAME=${2:-}; PORT=${3:-}
usage() { echo "usage: new-run.sh <primitive-set|component|screen> <run-name> <port>" >&2; exit 1; }
case $PART in primitive-set) OVERLAYS="";; component) OVERLAYS="primitives";; screen) OVERLAYS="primitives components";; *) usage;; esac
[[ $NAME =~ ^[A-Za-z0-9._-]+$ ]] && [[ $NAME != .* ]] || usage
[[ $PORT =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || usage
ROOT=${EVAL_RUNS_ROOT:-$HOME/Dev/AI/Skills/design-skills-eval-runs}
RUN="$ROOT/$NAME"
FIXTURE="$HERE/fixture"
[ -e "$RUN" ] && { echo "new-run: $RUN exists; pick a new run name" >&2; exit 1; }
[ -d "$FIXTURE/node_modules" ] || { echo "new-run: $FIXTURE/node_modules missing; run npm ci in evals/fixture first" >&2; exit 1; }

mkdir -p "$ROOT"
# APFS clone (cp -c): node_modules costs no disk until a file changes. Plain copy where cloning is unsupported.
cp -cR "$FIXTURE" "$RUN" 2>/dev/null || { rm -rf "$RUN"; cp -R "$FIXTURE" "$RUN"; }
rm -rf "$RUN/dist" "$RUN/node_modules/.tmp" "$RUN/node_modules/.vite"
for o in $OVERLAYS; do cp -R "$HERE/overlays/$o/." "$RUN/"; done

git -C "$RUN" init -q -b main
git -C "$RUN" add -A
git -C "$RUN" -c user.name="design-skills eval" -c user.email="eval@localhost" commit -q -m "Eval fixture for $PART ($NAME)"
echo "new-run: $RUN ($PART, port $PORT, $(git -C "$RUN" rev-parse --short HEAD))" >&2

sed -e "s|{RUN_DIR}|$RUN|g" -e "s|{PORT}|$PORT|g" -e "s|{RUN_NAME}|$NAME|g" "$HERE/briefs/$PART.md"
