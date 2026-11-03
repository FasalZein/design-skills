#!/usr/bin/env bash
# Save one scored eval run and delete its directory.
# Usage: evals/clean-run.sh <run-name> <artifact-dir>
#   run-name      a directory directly inside <repo root>/.eval-runs (new-run.sh's default root)
#   artifact-dir  gets git-log.txt (the run's log with file stats), run.diff (initial commit to HEAD)
#                 and, when the run left changes uncommitted, uncommitted.diff and status.txt
# Refuses any run outside <repo root>/.eval-runs: a path, "..", a symlink, the root itself, or a
# directory that is not a git repository. Exit 1 on a refusal or a failed save; nothing is deleted then.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
NAME=${1:-}; OUT=${2:-}
die() { echo "clean-run: $*" >&2; exit 1; }
[ -n "$NAME" ] && [ -n "$OUT" ] || die "usage: clean-run.sh <run-name> <artifact-dir>"
[[ $NAME =~ ^[A-Za-z0-9._-]+$ ]] && [[ $NAME != .* ]] || die "'$NAME' is not a run name inside .eval-runs"
ROOT="$(dirname "$HERE")/.eval-runs"
[ -d "$ROOT" ] || die "$ROOT does not exist"
ROOT_REAL=$(cd "$ROOT" && pwd -P)
RUN="$ROOT/$NAME"
[ -L "$RUN" ] && die "$RUN is a symlink; refusing"
[ -d "$RUN" ] || die "$RUN is not a directory"
RUN_REAL=$(cd "$RUN" && pwd -P)
[ "$(dirname "$RUN_REAL")" = "$ROOT_REAL" ] || die "$RUN resolves outside $ROOT_REAL; refusing"
[ "$(git -C "$RUN_REAL" rev-parse --show-toplevel 2>/dev/null)" = "$RUN_REAL" ] || die "$RUN_REAL is not a run repository"

mkdir -p "$OUT"
OUT_REAL=$(cd "$OUT" && pwd -P)
case "$OUT_REAL/" in "$RUN_REAL"/*) die "artifact dir $OUT_REAL is inside the run";; esac
FIRST=$(git -C "$RUN_REAL" rev-list --max-parents=0 HEAD | tail -1)
git -C "$RUN_REAL" log --stat > "$OUT_REAL/git-log.txt"
git -C "$RUN_REAL" diff "$FIRST" HEAD > "$OUT_REAL/run.diff"
if [ -n "$(git -C "$RUN_REAL" status --porcelain)" ]; then
  git -C "$RUN_REAL" status --short > "$OUT_REAL/status.txt"
  git -C "$RUN_REAL" add -A -N .
  git -C "$RUN_REAL" diff HEAD > "$OUT_REAL/uncommitted.diff"
fi
rm -rf "$RUN_REAL"
echo "clean-run: saved $(wc -l < "$OUT_REAL/run.diff" | tr -d ' ') diff lines to $OUT_REAL; deleted $RUN_REAL" >&2
