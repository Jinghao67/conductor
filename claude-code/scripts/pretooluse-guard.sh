#!/usr/bin/env bash
# PreToolUse guard. Three independent rules, dispatched by role + tool:
#   A. read-firewall      (master only): block broad/external reads -> force subagent delegation
#   B. merge-gate         (master only): block master-snapshot edits during a merge w/o approved report
#   C. branch-write-guard (branch/explainer/dispatch): block writes to Conductor master records
# Emits a JSON permissionDecision (allow|deny|ask). Silent exit 0 == allow / not-applicable.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

[ "$ROLE" = "none" ] && exit 0

PROOT="${CLAUDE_PROJECT_DIR:-$(dirname "$CD_DIR")}"

# Resolve write/read target (Edit/Write/MultiEdit/Read all use file_path).
target_raw="$(cd_tool_input file_path)"
target_abs=""
[ -n "$target_raw" ] && target_abs="$(cd_abspath "$target_raw" 2>/dev/null || true)"

# Path of target relative to the nearest .conductor/, or empty if not inside one.
rel_in_conductor=""
case "$target_abs" in
  */.conductor/*) rel_in_conductor="${target_abs##*/.conductor/}" ;;
esac

# ---------------------------------------------------------------------------
# RULE C: branch-write-guard
# ---------------------------------------------------------------------------
if [ "$ROLE" = "branch" ] || [ "$ROLE" = "explainer" ] || [ "$ROLE" = "dispatch" ]; then
  case "$CD_TOOL" in
    Edit|Write|MultiEdit)
      if [ -n "$rel_in_conductor" ]; then
        case "$rel_in_conductor" in
          branches/"$BRANCH_ID"/*) : ;;                 # own branch dir: allow
          bindings/"$CD_SID".json) : ;;                 # own binding: allow
          *)
            cd_decide deny "Branch sessions cannot write Conductor master records ($rel_in_conductor). Put outcomes in your completion-report via /cd-complete; the master merges only approved reports."
            ;;
        esac
      fi
      ;;
  esac
  exit 0   # branches read freely and write their own work; nothing else to guard
fi

# ---------------------------------------------------------------------------
# Master-only rules
# ---------------------------------------------------------------------------
cd_is_master || exit 0

# Firewall escape hatch: env var OR project flag file -> downgrade deny to ask.
DOWN="deny"
if [ "${CD_FIREWALL_OFF:-}" = "1" ] || [ -f "$CD_DIR/.firewall-off" ]; then
  DOWN="ask"
fi

# RULE B: merge-gate (only when a merge is in flight, marked by .merge-lock)
if [ "$rel_in_conductor" = "master-snapshot.md" ]; then
  case "$CD_TOOL" in
    Edit|Write|MultiEdit)
      if [ -f "$CD_DIR/.merge-lock" ]; then
        mb="$(cat "$CD_DIR/.merge-lock" 2>/dev/null | tr -d '[:space:]')"
        if [ -n "$mb" ] && [ ! -f "$CD_DIR/branches/$mb/report.approved" ]; then
          cd_decide deny "Merge gate: no approved completion-report for $mb. Run /cd-merge (it runs cd-merge-verify, which writes the approval) instead of editing the snapshot directly."
        fi
      fi
      ;;
  esac
  exit 0   # master editing its own snapshot outside a merge is fine
fi

# RULE A: read-firewall
read_allowed() {
  # allow reads of Conductor state and plugin templates
  [ -n "$rel_in_conductor" ] && return 0
  case "$target_abs" in
    "${CLAUDE_PLUGIN_ROOT:-/nonexistent}"/*) return 0 ;;
  esac
  # allow top-level project docs
  local base dir
  base="$(basename "$target_abs" 2>/dev/null || true)"
  dir="$(dirname "$target_abs" 2>/dev/null || true)"
  if [ "$dir" = "$PROOT" ]; then
    case "$base" in CLAUDE.md|README*|*.md) return 0 ;; esac
  fi
  # allow targeted reads (anchor-following): explicit small limit
  local limit; limit="$(cd_tool_input limit)"
  if [ -n "$limit" ] && [ "$limit" -le 80 ] 2>/dev/null; then return 0; fi
  return 1
}

case "$CD_TOOL" in
  Grep|Glob|WebFetch|WebSearch)
    cd_decide "$DOWN" "Master session must delegate broad/external reads. Use the Explore subagent for the codebase, or cd-research for web/papers — only their distilled result (conclusion + anchors) returns to master."
    ;;
  Read)
    if read_allowed; then exit 0; fi
    cd_decide "$DOWN" "Large/untargeted Read in the master session. Delegate to the Explore subagent, or re-Read with offset+limit (<=80 lines) to follow a specific anchor."
    ;;
  Bash)
    cmd="$(cd_tool_input command)"
    if printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_])(rg|grep|egrep|fgrep|ag|find|curl|wget)([^[:alnum:]_]|$)'; then
      cd_decide "$DOWN" "That bash command bulk-reads/fetches into the master context, bypassing the read-firewall. Delegate to the Explore subagent (codebase) or cd-research (web)."
    fi
    ;;
esac

exit 0
