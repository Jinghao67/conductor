#!/usr/bin/env bash
# Shared library for Conductor (Claude Code) hooks.
# Source this at the top of every hook script. It reads stdin ONCE into CD_HOOK_INPUT
# and resolves the session's role. Golden rule: callers must `exit 0` on any internal
# error so a broken registry can never wedge the user's session.

set -uo pipefail

CD_HOOK_INPUT="$(cat 2>/dev/null || true)"

# cd_json <jq-filter> -> raw value or empty string
cd_json() { printf '%s' "$CD_HOOK_INPUT" | jq -r "${1} // empty" 2>/dev/null || true; }

CD_SID="$(cd_json '.session_id')"
CD_CWD="$(cd_json '.cwd')"
CD_EVENT="$(cd_json '.hook_event_name')"
CD_SOURCE="$(cd_json '.source')"
CD_TOOL="$(cd_json '.tool_name')"
CD_TOOL_INPUT="$(printf '%s' "$CD_HOOK_INPUT" | jq -c '.tool_input // {}' 2>/dev/null || echo '{}')"

# cd_tool_input <key> -> value under .tool_input
cd_tool_input() { printf '%s' "$CD_TOOL_INPUT" | jq -r --arg k "$1" '.[$k] // empty' 2>/dev/null || true; }

# Locate the project .conductor dir: prefer CLAUDE_PROJECT_DIR, else walk up from cwd.
cd_find_conductor() {
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "$CLAUDE_PROJECT_DIR/.conductor" ]; then
    printf '%s' "$CLAUDE_PROJECT_DIR/.conductor"; return 0
  fi
  local dir="${CD_CWD:-$PWD}"
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    if [ -d "$dir/.conductor" ]; then printf '%s' "$dir/.conductor"; return 0; fi
    dir="$(dirname "$dir")"
  done
  return 1
}

CD_DIR="$(cd_find_conductor || true)"
CD_REGISTRY=""
[ -n "$CD_DIR" ] && CD_REGISTRY="$CD_DIR/registry.json"

# Resolve role into ROLE / BRANCH_ID.
# ROLE in {none, master, master_candidate, branch, explainer, dispatch, unbound}
ROLE="none"
BRANCH_ID=""
if [ -n "$CD_DIR" ] && [ -f "$CD_REGISTRY" ]; then
  _binding="$CD_DIR/bindings/$CD_SID.json"
  if [ -f "$_binding" ]; then
    ROLE="$(jq -r '.role // "unbound"' "$_binding" 2>/dev/null || echo unbound)"
    BRANCH_ID="$(jq -r '.branch_id // empty' "$_binding" 2>/dev/null || true)"
  else
    _master_sid="$(jq -r '.master.session_id // empty' "$CD_REGISTRY" 2>/dev/null || true)"
    if [ -z "$_master_sid" ]; then ROLE="master_candidate"
    elif [ "$_master_sid" = "$CD_SID" ]; then ROLE="master"
    else ROLE="unbound"
    fi
  fi
fi

cd_is_master() { [ "$ROLE" = "master" ] || [ "$ROLE" = "master_candidate" ]; }

# Resolve a tool file_path to an absolute path (best effort).
cd_abspath() {
  local p="$1"
  [ -z "$p" ] && return 1
  case "$p" in
    /*) printf '%s' "$p" ;;
    *)  printf '%s' "${CD_CWD:-$PWD}/$p" ;;
  esac
}

# Emit a PreToolUse decision as JSON and exit 0.
# cd_decide <allow|deny|ask> [reason]
cd_decide() {
  local decision="$1"; local reason="${2:-}"
  jq -nc --arg d "$decision" --arg r "$reason" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}' 2>/dev/null \
    || printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}' "$decision" "$reason"
  exit 0
}

# Emit SessionStart context injection and exit 0.
# cd_session_context <additionalContext> [sessionTitle]
cd_session_context() {
  local ctx="$1"; local title="${2:-}"
  if [ -n "$title" ]; then
    jq -nc --arg c "$ctx" --arg t "$title" \
      '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c,sessionTitle:$t}}'
  else
    jq -nc --arg c "$ctx" \
      '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
  fi
  exit 0
}
