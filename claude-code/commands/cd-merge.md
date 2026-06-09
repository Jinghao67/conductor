---
description: Merge an approved branch completion-report into the master snapshot (master only).
argument-hint: "<branch-id>"
allowed-tools: ["Bash", "Read", "Edit", "Task"]
---

Merge lock set, and the completion report below is the ONLY input you may use:
!`B="$ARGUMENTS"; D=".conductor"; if [ ! -f "$D/branches/$B/completion-report.md" ]; then echo "MISSING REPORT for $B — the branch must run /cd-complete first."; else printf '%s' "$B" > "$D/.merge-lock"; echo "merge-lock set for $B"; echo "=== completion-report.md ($B) ==="; cat "$D/branches/$B/completion-report.md"; fi; true`

Steps (do not read the branch's working history or files — only the report above):
1. **Verify first.** Launch the `cd-merge-verify` subagent (Task tool, `subagent_type: cd-merge-verify`) with the branch id `$ARGUMENTS`, the brief path `.conductor/branches/$ARGUMENTS/brief.md`, and the report path `.conductor/branches/$ARGUMENTS/completion-report.md`. It returns APPROVE/REJECT and, on APPROVE, writes the `.conductor/branches/$ARGUMENTS/report.approved` sentinel.
2. **If REJECTED:** do not merge. Summarize what's missing for the user, remove the lock (`rm -f .conductor/.merge-lock`), and stop.
3. **If APPROVED:** append the report's **Suggested Merge Note** to `.conductor/master-snapshot.md` (compress further and normalize terminology). The merge-gate hook allows this edit only because `report.approved` now exists. Surface any **Proposed Global Decisions** to the user for explicit confirmation before treating them as binding.
4. Editing the snapshot auto-flips the branch to `merged` and clears the lock. Confirm the Today View with `/cd-status`.

Explainer-sidecar reports never merge by default.
