#!/usr/bin/env bash
# PreCompact hook: before the master's context is compacted, warn if the master
# snapshot looks stale, so distilled state survives compaction. A hook has no model,
# so it cannot author the snapshot — it only nudges. Re-injection happens on the
# subsequent SessionStart (source=compact). Never blocks.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

cd_is_master || exit 0
[ -f "$CD_REGISTRY" ] || exit 0

snap="$CD_DIR/master-snapshot.md"
stale=0
if [ ! -f "$snap" ]; then
  stale=1
elif [ "$CD_REGISTRY" -nt "$snap" ]; then
  stale=1
elif grep -q 'TODO\|（empty\|<fill' "$snap" 2>/dev/null; then
  stale=1
fi

if [ "$stale" = "1" ]; then
  jq -nc '{systemMessage:"Conductor: the master snapshot may be stale before compaction. Run /cd-status and update master-snapshot.md so the distilled state survives the compaction."}' 2>/dev/null \
    || printf '{"systemMessage":"Conductor: master snapshot may be stale; run /cd-status before compaction."}'
fi

exit 0
