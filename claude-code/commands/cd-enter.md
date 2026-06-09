---
description: Show a branch brief and how to start that branch in its own session.
argument-hint: "<branch-id>"
allowed-tools: ["Read"]
---

Brief for `$ARGUMENTS` (this is exactly what the branch session will receive):
!`cat ".conductor/branches/$ARGUMENTS/brief.md" 2>/dev/null || echo "No brief for $ARGUMENTS — run /cd-branch first."`

To start this branch as a **separate session you drive directly** (this keeps the master clean — the master never sees this branch's working history, only its final completion report):

1. Open a new terminal tab/window in this project directory and run `claude`.
2. In that new session, run: `/cd-bind $ARGUMENTS`
   - This binds the session to `$ARGUMENTS`; its SessionStart will then inject **only** the brief above, and the read-firewall will not apply (a branch is allowed to be dirty).
3. Do the work there, interacting directly. When the user confirms it's done, run `/cd-complete` in that session.
4. Back here in the master, run `/cd-merge $ARGUMENTS` to fold only the approved result in.

(Do not try to do the branch's work here in the master session.)
