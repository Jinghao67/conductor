#!/usr/bin/env bash
# PostToolUse sync. Keeps derived state consistent after writes. Hooks write the
# filesystem directly (not via tools), so this is the privileged path for state
# transitions a branch session is not allowed to make through tools. Never blocks.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

[ "$ROLE" = "none" ] && exit 0
[ -f "$CD_REGISTRY" ] || exit 0

target_raw="$(cd_tool_input file_path)"
target_abs=""
[ -n "$target_raw" ] && target_abs="$(cd_abspath "$target_raw" 2>/dev/null || true)"
rel=""
case "$target_abs" in */.conductor/*) rel="${target_abs##*/.conductor/}" ;; esac
[ -n "$rel" ] || exit 0

render() { python3 "$SCRIPT_DIR/registry.py" render-branch-map "$CD_DIR" >/dev/null 2>&1 || true; }

set_state() {
  local bid="$1" st="$2" tmp
  tmp="$(mktemp 2>/dev/null)" || return 0
  if jq --arg b "$bid" --arg s "$st" '(.branches[$b].status) = $s' "$CD_REGISTRY" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$CD_REGISTRY" 2>/dev/null || rm -f "$tmp"
  else
    rm -f "$tmp"
  fi
}

case "$rel" in
  registry.json)
    render
    ;;
  master-snapshot.md)
    # If a merge just landed, flip the branch to merged and clear the lock.
    if cd_is_master && [ -f "$CD_DIR/.merge-lock" ]; then
      mb="$(cat "$CD_DIR/.merge-lock" 2>/dev/null | tr -d '[:space:]')"
      if [ -n "$mb" ] && [ -f "$CD_DIR/branches/$mb/report.approved" ]; then
        set_state "$mb" merged
        rm -f "$CD_DIR/.merge-lock"
        render
      fi
    fi
    ;;
  branches/*/completion-report.md)
    # The branch wrote its report (via /cd-complete, i.e. user-confirmed). The branch
    # cannot edit registry.json through tools, so the hook performs the transition.
    bid="${rel#branches/}"; bid="${bid%/completion-report.md}"
    if [ -n "$bid" ]; then
      set_state "$bid" report_ready
      render
    fi
    ;;
esac

exit 0
