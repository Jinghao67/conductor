---
description: Generate this branch's completion report (run in the branch, after the user confirms it's done).
allowed-tools: ["Bash", "Read", "Write"]
---

Branch + brief (resolved from this session's binding):
!`SID="${CLAUDE_SESSION_ID}"; B="$(jq -r '.branch_id // empty' ".conductor/bindings/$SID.json" 2>/dev/null)"; if [ -z "$B" ]; then echo "This session is not bound to a branch. Run /cd-bind <id> first."; else echo "branch=$B"; echo "--- brief ---"; cat ".conductor/branches/$B/brief.md" 2>/dev/null; fi; true`

Only proceed if the **user has confirmed** this branch is complete (a branch may suggest completion, but only the user confirms it).

Write `.conductor/branches/<branch-id>/completion-report.md` (your own branch dir — allowed) using this structure. Keep the Suggested Merge Note ≤150 words — it is the only text intended for the master context:

```markdown
# Completion Report: <branch-id> — <title>

## Result
3–6 sentences on the outcome.

## Artifacts / Files
- paths produced or changed

## Decisions Made Locally
- ...

## Proposed Global Decisions
- Decision / Scope affected / Why it matters / Branches affected / Recommended master action

## Validation / Checks
- what you ran/verified

## Risks
- ...

## Suggested Merge Note
<=150 words. The compressed, master-ready summary.
```

Writing this report flips the branch to `report_ready` automatically. Tell the user to run `/cd-merge <branch-id>` from the **master** session to fold the result in.
