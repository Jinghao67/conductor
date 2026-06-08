---
name: conductor
description: Use when a complex task needs dependency-aware interactive branches, subagents, or AI coding threads while keeping the master session context clean through explicit branch briefs, completion reports, wave planning, and user-approved merges. Especially useful with grill-me, Trellis, research, implementation, writing, and planning workflows that risk context pollution.
---

# Conductor

## Purpose

`conductor` is a context isolation and branch registry protocol. It keeps one master session clean while messy exploration, implementation, research, review, or learning happens in separate user-interactive branch sessions.

Use it to decide whether a request belongs in the master session, an interactive branch, an explainer sidecar, or a merge flow. It does not replace Trellis executors or other workflow agents; it governs how branches are created, tracked, completed, and optionally merged.

## Core Rules

- The master session owns the project overview: goal, constraints, branch map, global decisions, approved summaries, risks, and next steps.
- Use session registry first. Create visible branch cards before creating real sessions.
- Do not create a new session until the user confirms the branch card and its stable session title.
- Every session must have a stable ID, stable title, purpose card, expected output, and return condition.
- Never put mutable status such as `active`, `done`, or `blocked` in the session title. Status belongs in the branch map or Today View.
- Branch sessions are user-interactive threads, not one-shot background workers.
- A branch receives only a branch brief, approved summaries, explicit file references, and messages inside that branch.
- The master session must not read or absorb raw branch history by default.
- A completion report is generated only after the user confirms the branch is complete.
- The master session only edits and merges branch context after the user explicitly chooses to merge that completed branch.
- Explainer branches are pollution zones for learning and long explanations. They default to no merge.
- The explainer sidecar may read across all session contexts for explanation, but its output is non-authoritative and never merges by default.
- Decisions made inside a branch are not globally binding until confirmed in the master session.
- Do not assume all branches can run in parallel. Always run a dependency pass before opening branches.

## Session Types And Names

Use exactly these session types:

| Type | Stable title pattern | Purpose | Default merge behavior |
| --- | --- | --- | --- |
| `master` | `[CD-MAIN][master] <project>` | Project control room: global goals, branch map, confirmed decisions, risks, approved summaries | Source of truth |
| `dispatch` | `[CD-DISPATCH][routing] Branch planning` | Discuss whether to open sessions, whether work is parallel or serial, dependency waves, and session cards | Merge only final dispatch decisions |
| `branch` | `[CD-001][W1][design] API contract` | User-interactive work session for one bounded task | Report generated after user-confirmed completion; merge only after explicit user approval |
| `explainer` | `[CD-E01][sidecar][explainer] Dirty questions` | Dirty learning session for questions, tutorials, and cross-session explanation | No merge by default |

Rules:

- Session titles must start with the Conductor ID.
- Session titles must include role and wave when relevant.
- Session titles must be short enough to identify in a thread list.
- Do not create multiple explainer sessions. Use one fixed explainer per project.
- Do not create multiple dispatch sessions. Use one fixed dispatch session per project.
- Prefer at most 2 active interactive branch sessions, plus the optional dispatch session and fixed explainer sidecar.

## Session Registry First

Conductor creates branch cards before sessions. A branch card must include:

- ID and stable session title
- type and role
- one-sentence purpose
- why it exists
- dependency/wave placement
- allowed context
- expected artifact
- completion criteria
- return condition
- whether it should open now, stay planned, or stay blocked

Only after the user confirms the card should Conductor create or bind a real session. When entering a branch, the first visible content must be a Purpose Card:

```text
You are branch CD-001: API contract
Purpose: decide request/response shape
Not for: implementation
Input: master snapshot snap-xxx; approved summaries only
Output: completion-report.md
Return to master when: API contract options are compared and the user confirms completion
```

After creating, blocking, completing, merging, parking, or archiving a session, refresh a compact Today View in the master session:

```text
Active now:
- CD-001 API contract — design — waiting for user review
- CD-E01 Dirty questions — sidecar explainer

Planned, not opened:
- CD-002 Implementation plan — waits for CD-001

Merge pending:
- none
```

## Routing

Whenever this skill is active, route each new request before acting:

1. Keep in master session if it changes global goals, scope, constraints, priorities, branch structure, merge decisions, or project snapshots.
2. Use the dispatch session if the conversation is mainly about whether to open sessions, whether tasks are parallel or serial, dependency order, wave planning, or branch-card design.
3. Create or use an interactive branch if the work is exploratory, implementation-heavy, research-heavy, review-heavy, or likely to produce many intermediate details.
4. Send to the explainer sidecar if the user wants long-form explanation, background learning, conceptual clarification, or tutorial-style help.
5. Enter merge flow only after a branch is user-confirmed complete.

Keep this routing lightweight. Do not turn every message into process ceremony.

## Dispatch Session

Do not open the dispatch session by default. Suggest opening `[CD-DISPATCH][routing] Branch planning` when:

- branch planning takes more than 2-3 turns
- there are more than 3 candidate branch cards
- dependency order is unclear
- the user asks whether work should be parallel or serial
- session proliferation is starting to make the project hard to navigate

The dispatch session is isolated from the master session. It may discuss:

- which sessions should exist
- which branches should be planned, opened, parked, blocked, or archived
- which work can run in parallel and which must be serial
- branch titles, roles, expected outputs, and completion criteria
- active-session budget

The dispatch session must not do implementation, research, review, or long-form explanation. It must not read raw branch histories by default. It returns only a compact dispatch decision to the master session, for example:

```text
Dispatch decision:
- Open CD-001 and CD-E01 now.
- Keep CD-002 planned until CD-001 completion report is ready.
- Do not open implementation branch yet.
```

## Dependency Pass And Wave Plan

Before creating or opening branches, identify execution order. Many branches depend on outputs from earlier branches and must remain `planned` or `blocked` until their prerequisites are done.

Classify each proposed branch:

- `ready_parallel`: can start now from the current master snapshot without waiting on another branch.
- `dependent`: needs a specific branch output, decision, artifact, or user confirmation first.
- `gate`: a review, merge, or master-session decision required before the next wave can start.
- `optional`: useful but not on the critical path.
- `explainer`: can run as a sidecar unless the user explicitly makes it blocking.

Output a compact wave plan before creating threads:

| Wave | Branches | Prerequisites | Gate to unlock next wave |
| --- | --- | --- | --- |
| 0 | master decisions | none | user confirms scope |
| 1 | branches that can run now | current snapshot | completion reports reviewed |
| 2 | dependent branches | Wave 1 outputs | merge or user decision |

Rules:

- Only branches in the current unlocked wave should become active by default.
- Later-wave branches may be recorded as `planned`; mark them `blocked` if the user tries to start them before prerequisites are met.
- Parallel means "safe to run from the same snapshot without needing each other's outputs", not merely "different topics".
- If dependencies are ambiguous, ask the user to confirm the order before creating branch threads.
- After a wave completes, update the snapshot, note what it unlocks, and then propose the next wave.

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

Default active interactive branch limit: 2. The fixed explainer sidecar and optional dispatch session do not count as interactive branches. If creating a third active branch, suggest parking, completing, or archiving an existing branch first.

## Creating Branches

Create branches only after user confirmation. First show:

- stable session title
- proposed branch title and role
- why it should be a branch
- whether it is in the current wave or waiting on prerequisites
- dependencies, unblocks, and gate condition
- expected artifact
- completion criteria
- whether it needs a Trellis child task, an AI coding thread, or both

Create only current-wave branches by default. Do not create all planned branch threads at once unless the user explicitly requests that.

After confirmation, write a branch brief using `references/branch-brief-template.md`. If thread tools are available, create or bind an AI coding thread, set the thread title to the stable session title when possible, and give it only the branch brief as the initial prompt. Record the returned `thread_id`; a Codex deep link such as `codex://threads/<thread-id>` is optional when using Codex and is not the source of truth.

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

The explainer is context-rich but non-authoritative. It may read across all session contexts to answer user questions, but should load only the relevant context for the current question and should label source authority:

- L0: master snapshot, branch map, Today View - confirmed
- L1: branch cards and branch briefs - intended scope
- L2: completion reports and approved summaries - reviewed outputs
- L3: raw branch histories - branch-local and unconfirmed; read only when the user explicitly asks
- L4: explainer history - dirty learning context

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

With Trellis, map `conductor` like this:

- master session: parent/root task
- dispatch session: sidecar AI coding thread for branch planning; not a Trellis child task by default
- interactive branch: Trellis child task plus a user-enterable AI coding thread
- explainer: sidecar AI coding thread, not a Trellis child task by default
- branch map: parent task `branch-map.md`
- machine binding: `task.json.meta.conductor`

Prefer Trellis scripts such as `task.py create --parent` or `task.py add-subtask` for parent/child relationships. Do not manually edit `parent` or `children` unless Trellis scripts are unavailable or fail.

Use `task.json.meta.conductor` only for small machine-readable fields:

```json
{
  "conductor": {
    "branch_id": "CD-001",
    "branch_type": "interactive",
    "role": "research",
    "parent_branch_id": "CD-MAIN",
    "thread_id": "thr_xxx",
    "branch_brief_path": ".trellis/tasks/example/branch-brief.md",
    "completion_report_path": ".trellis/tasks/example/completion-report.md",
    "status": "active",
    "brief_version": 1,
    "based_on_snapshot_id": "snap-2026-06-03-001",
    "execution_wave": 1,
    "depends_on": [],
    "unblocks": ["CD-002"],
    "start_policy": "current_wave_only",
    "gate_condition": "completion_report_ready",
    "merge_policy": "explicit_user_confirm"
  }
}
```

Do not add branch briefs, completion reports, or raw conversation summaries to `implement.jsonl` or `check.jsonl` by default. Those files are for Trellis execution/check context and should be touched only when the user confirms the branch artifact must become implementation or check context.

## Non-Trellis Fallback

If Trellis is not available, maintain:

- `conductor.yaml` as the machine-readable registry
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
