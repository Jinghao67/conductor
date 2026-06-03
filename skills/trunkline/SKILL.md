---
name: trunkline
description: Use when a complex task needs multiple interactive branches, subagents, or AI coding threads while keeping the master session context clean through explicit branch briefs, completion reports, and user-approved merges. Especially useful with grill-me, Trellis, research, implementation, writing, and planning workflows that risk context pollution.
---

# Trunkline

## Purpose

`trunkline` is a context isolation and branch registry protocol. It keeps one master session clean while messy exploration, implementation, research, review, or learning happens in separate user-interactive branch sessions.

Use it to decide whether a request belongs in the master session, an interactive branch, an explainer sidecar, or a merge flow. It does not replace Trellis executors or other workflow agents; it governs how branches are created, tracked, completed, and optionally merged.

## Core Rules

- The master session owns the project overview: goal, constraints, branch map, global decisions, approved summaries, risks, and next steps.
- Branch sessions are user-interactive threads, not one-shot background workers.
- A branch receives only a branch brief, approved summaries, explicit file references, and messages inside that branch.
- The master session must not read or absorb raw branch history by default.
- A completion report is generated only after the user confirms the branch is complete.
- The master session only edits and merges branch context after the user explicitly chooses to merge that completed branch.
- Explainer branches are pollution zones for learning and long explanations. They default to no merge.
- Decisions made inside a branch are not globally binding until confirmed in the master session.

## Routing

Whenever this skill is active, route each new request before acting:

1. Keep in master session if it changes global goals, scope, constraints, priorities, branch structure, merge decisions, or project snapshots.
2. Create or use an interactive branch if the work is exploratory, implementation-heavy, research-heavy, review-heavy, or likely to produce many intermediate details.
3. Send to the explainer sidecar if the user wants long-form explanation, background learning, conceptual clarification, or tutorial-style help.
4. Enter merge flow only after a branch is user-confirmed complete.

Keep this routing lightweight. Do not turn every message into process ceremony.

## Branch State Machine

Use these stable states:

| State | Meaning | Typical next step |
| --- | --- | --- |
| `planned` | Suggested by master, not confirmed | create brief or cancel |
| `brief_ready` | Branch brief exists, thread not created | create thread or revise brief |
| `active` | User can enter and interact | block, park, or suggest completion |
| `blocked` | Waiting on master, user, external input, or another branch | resume or cancel |
| `completion_suggested` | Branch thinks it may be done | user confirms completion or continues |
| `report_ready` | User confirmed completion and report exists | request merge or archive |
| `merge_pending` | Master asks whether to merge report | merge, reject, or defer |
| `merged` | Master wrote approved compressed record | archive |
| `rejected` | User chose not to merge | archive |
| `archived` | Hidden from active view | reopen |

Default active branch limit: 3. If creating a fourth active branch, suggest parking, completing, or archiving an existing branch first.

## Creating Branches

Create branches only after user confirmation. First show:

- proposed branch title and role
- why it should be a branch
- expected artifact
- completion criteria
- whether it needs a Trellis child task, an AI coding thread, or both

After confirmation, write a branch brief using `references/branch-brief-template.md`. If thread tools are available, create or bind an AI coding thread and give it only the branch brief as the initial prompt. Record the returned `thread_id`; a Codex deep link such as `codex://threads/<thread-id>` is optional when using Codex and is not the source of truth.

If thread creation is unavailable, create the brief and ask the user to start a separate session with it.

## Completion And Merge

A branch may suggest completion, but only the user can confirm it. After confirmation, generate a completion report using `references/completion-report-template.md`.

The master session then asks whether to merge:

- Merge: read the completion report, compress it, normalize terminology, and add a short approved record to the master context.
- Reject: record that the branch completed but was not merged.
- Defer: leave the branch in `merge_pending`.

Do not read raw branch history unless the user explicitly asks to debug or audit that branch. The default merge input is `completion-report.md`, especially its `Suggested Merge Note`.

## Explainer Sidecar

Use one explainer thread per project. It is for questions that would heavily pollute context: tutorials, long derivations, conceptual gaps, background knowledge, and repeated clarification.

Do not create a Trellis child task for the explainer by default. Represent it as a sidecar in the branch map. Only promote explainer output if the user strongly requests it and the content becomes a project decision, constraint, terminology definition, or spec/task update. Even then, merge as a very short project knowledge item, not as teaching material.

## Global Decisions

If a branch discussion creates or implies a decision affecting other branches, architecture, scope, naming, deadlines, acceptance criteria, or project goals, the branch must record it as a proposed global decision. It is not binding until the master session confirms it.

Completion reports should include proposed global decisions with:

- decision
- affected scope
- why it matters
- affected branches
- recommended master-session action

## Snapshots And Staleness

The master session should create short snapshots after major events: branch creation, branch completion, merge, archival, and confirmed global decisions.

Each branch brief should record:

- `based_on_snapshot_id`
- `brief_version`
- creation date
- parent task or root branch

When the master snapshot changes in a way that affects an active branch, mark that branch stale and ask whether to refresh its brief. Do not silently sync hidden context.

## Trellis Best Practice

With Trellis, map `trunkline` like this:

- master session: parent/root task
- interactive branch: Trellis child task plus a user-enterable AI coding thread
- explainer: sidecar AI coding thread, not a Trellis child task by default
- branch map: parent task `branch-map.md`
- machine binding: `task.json.meta.trunkline`

Prefer Trellis scripts such as `task.py create --parent` or `task.py add-subtask` for parent/child relationships. Do not manually edit `parent` or `children` unless Trellis scripts are unavailable or fail.

Use `task.json.meta.trunkline` only for small machine-readable fields:

```json
{
  "trunkline": {
    "branch_id": "TL-001",
    "branch_type": "interactive",
    "role": "research",
    "parent_branch_id": "TL-ROOT",
    "thread_id": "thr_xxx",
    "branch_brief_path": ".trellis/tasks/example/branch-brief.md",
    "completion_report_path": ".trellis/tasks/example/completion-report.md",
    "status": "active",
    "brief_version": 1,
    "based_on_snapshot_id": "snap-2026-06-03-001",
    "merge_policy": "explicit_user_confirm"
  }
}
```

Do not add branch briefs, completion reports, or raw conversation summaries to `implement.jsonl` or `check.jsonl` by default. Those files are for Trellis execution/check context and should be touched only when the user confirms the branch artifact must become implementation or check context.

## Non-Trellis Fallback

If Trellis is not available, maintain:

- `trunkline.yaml` as the machine-readable registry
- `branch-map.md` as the human-readable snapshot
- Mermaid inside `branch-map.md` for visualization

Use `references/branch-map-template.md` when creating or refreshing the map.

## When To Stop And Summarize

When the user asks for a Trellis-ready summary or before implementation begins, provide:

- goal and non-goals
- user flow
- routing rules
- branch states
- Trellis mapping or fallback registry
- acceptance criteria
- risks
- open questions
