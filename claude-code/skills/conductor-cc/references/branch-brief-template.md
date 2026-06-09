# Branch Brief: <branch-id> — <title>

The brief is the ONLY context a branch session receives (injected by the SessionStart hook
after `/cd-bind`). Keep it self-contained.

## Purpose Card

```text
You are branch <branch-id>: <title>
Purpose: <one precise outcome>
Not for: <unscoped work outside this card>
Input: master snapshot <snapshot-id>; approved summaries only
Output: completion-report.md
Return to master when: output is ready and the user confirms completion
```

## Parent Context
- Snapshot id:
- Brief version:
- Why this branch exists:

## Dependency / Order
- Execution wave:
- Depends on:
- Unblocks:
- Start policy: current_wave_only | wait_for_prerequisite | optional

## In Scope
- ...

## Out Of Scope
- ...

## Allowed Context
This branch may use only: this brief, files explicitly listed here, approved summaries
included here, and user messages inside this branch session.

## Completion Criteria
- ...

## Global-Decision Rule
If you make or imply a decision affecting other branches, architecture, scope, naming,
deadlines, acceptance criteria, or goals, do not treat it as binding. Record it under
"Proposed Global Decisions" in the completion report and ask the user to confirm it in the master.
