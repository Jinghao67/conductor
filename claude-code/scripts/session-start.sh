#!/usr/bin/env bash
# SessionStart hook: inject role-appropriate context, enforcing isolation.
#   master    -> master-snapshot + Today View
#   branch    -> ONLY its brief (never master/siblings)
#   explainer -> non-authoritative sidecar note
#   unbound   -> guidance (esp. after /clear)
# Never blocks; emits additionalContext + sessionTitle or stays silent.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

[ "$ROLE" = "none" ] && exit 0

project="$(jq -r '.project // "project"' "$CD_REGISTRY" 2>/dev/null || echo project)"

read_file() { [ -f "$1" ] && cat "$1" 2>/dev/null || true; }

case "$ROLE" in
  master|master_candidate)
    snap="$(read_file "$CD_DIR/master-snapshot.md")"
    today="$(sed -n '/## Today View/,/## Wave Plan/p' "$CD_DIR/branch-map.md" 2>/dev/null || true)"
    ctx="You are the Conductor MASTER session (control room). Hold only goals, constraints, the branch map, confirmed decisions, risks, and approved summaries. Do NOT read raw branch history; branches return through completion reports. Broad/external reads are firewalled here — delegate them to the Explore subagent (codebase) or cd-research (web/papers).

=== MASTER SNAPSHOT ===
${snap:-（empty — run /cd-status or record the goal）}

=== TODAY VIEW ===
${today:-（no branches yet — /cd-branch to create one）}"
    cd_session_context "$ctx" "[CD-MAIN][master] $project"
    ;;

  branch)
    brief="$(read_file "$CD_DIR/branches/$BRANCH_ID/brief.md")"
    stale="$(jq -r --arg b "$BRANCH_ID" '.branches[$b].stale // false' "$CD_REGISTRY" 2>/dev/null || echo false)"
    title="$(jq -r --arg b "$BRANCH_ID" '.branches[$b].stable_title // empty' "$CD_REGISTRY" 2>/dev/null || true)"
    banner=""
    [ "$stale" = "true" ] && banner="⚠ YOUR BRIEF MAY BE STALE — the master snapshot advanced since this brief was written. Ask the master to refresh before relying on assumptions.

"
    ctx="${banner}You are Conductor branch ${BRANCH_ID}. Your ONLY context is the brief below. You cannot see the master session or sibling branches. Do not assume access to master history. Decisions you make here are not globally binding until confirmed in the master session. When done, the USER confirms completion, then run /cd-complete.

=== BRANCH BRIEF ===
${brief:-（brief missing — ask the master to (re)create it）}"
    cd_session_context "$ctx" "${title:-[$BRANCH_ID] branch}"
    ;;

  explainer)
    ctx="You are the Conductor EXPLAINER sidecar ([CD-E01]). This is a deliberately dirty learning zone for questions, tutorials, and long explanations. You may read across sessions on demand to answer, but your output is NON-AUTHORITATIVE and does NOT merge into the master session by default. Label sources (L0 confirmed snapshot … L3 raw branch history) when it matters."
    cd_session_context "$ctx" "[CD-E01][sidecar][explainer] Dirty questions"
    ;;

  unbound)
    if [ "$CD_SOURCE" = "clear" ]; then
      ctx="Conductor: this session is UNBOUND after /clear (its session id changed). If this is the master control room, run /cd-init to re-adopt the existing registry. If this is branch CD-XXX, run /cd-bind CD-XXX to re-attach (your brief will be re-injected)."
    else
      ctx="Conductor: this session is not bound to a role in this project. Run /cd-init if it should be the master, or /cd-bind <branch-id> if it is a branch. Until then, Conductor enforcement is inactive for this session."
    fi
    cd_session_context "$ctx"
    ;;

  *)
    exit 0
    ;;
esac
