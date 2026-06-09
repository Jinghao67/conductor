---
description: Bind THIS session to a branch (run inside the branch's own session).
argument-hint: "<branch-id>"
allowed-tools: ["Bash", "Read"]
---

Binding result (runs before you act):
!`SID="${CLAUDE_SESSION_ID}"; B="$ARGUMENTS"; D=".conductor"; if [ ! -f "$D/branches/$B/brief.md" ]; then echo "No brief for $B — create it from the master with /cd-branch first."; else printf '{"session_id":"%s","role":"branch","branch_id":"%s"}\n' "$SID" "$B" > "$D/bindings/$SID.json"; tmp="$(mktemp)"; jq --arg b "$B" --arg s "$SID" '(.branches[$b].bound_session_id)=$s | (.branches[$b].status)="active"' "$D/registry.json" > "$tmp" 2>/dev/null && mv "$tmp" "$D/registry.json"; echo "bound this session to $B (role=branch)"; fi`

Your brief (your ONLY context — you cannot see the master session or sibling branches):
!`cat ".conductor/branches/$ARGUMENTS/brief.md" 2>/dev/null`

**If the binding result above did NOT print `bound this session to $ARGUMENTS`** (e.g. it was empty or showed an error), bind manually now: write `.conductor/bindings/${CLAUDE_SESSION_ID}.json` with content `{"session_id":"${CLAUDE_SESSION_ID}","role":"branch","branch_id":"$ARGUMENTS"}`, then set `.branches["$ARGUMENTS"].status` to `active` and `.bound_session_id` to `${CLAUDE_SESSION_ID}` in `.conductor/registry.json`. (This session is still unbound, so these writes are allowed.)

You are now branch **`$ARGUMENTS`**. Work directly with the user here. Reads are not firewalled in a branch — get as dirty as you need. Decisions you make are not globally binding until the master confirms them; record any cross-branch decisions to surface in your completion report. When the user confirms the work is done, run `/cd-complete`.
