---
name: conductor-cc
description: Use when a complex, long-running task risks polluting one conversation — research, implementation, review, planning, or learning that should be split into dependency-aware branches while keeping the master session clean. The Claude Code-native Conductor, where branches are separate user-driven sessions, raw content is quarantined in subagents, and the protocol is enforced by hooks rather than only guidance. Pairs with grill-me-style requirement work.
---

# Conductor (Claude Code)

A context-isolation + branch-registry protocol for Claude Code. One **master** session
stays clean; messy work happens in separate **branch** sessions and throwaway subagents.
Unlike a plain skill, the hard rules here are enforced by **hooks**, not by your goodwill —
so this skill only has to carry the **judgment** the hooks can't.

## The one principle

**The master holds only distilled knowledge. All raw content is quarantined.**

| Raw content | Quarantine | Master gets |
| --- | --- | --- |
| a branch's messy history | a separate user-driven session | a completion report |
| codebase source | the **Explore** subagent | conclusion + `file:line` anchors |
| paper/web content | the **cd-research** subagent | distilled notes + sources |

## What the harness enforces for you (don't re-litigate it)

- **SessionStart hook** injects role context: master → snapshot + Today View; a bound branch → only its brief. A branch literally cannot see master/sibling history.
- **PreToolUse hook** = three gates: (a) read-firewall — broad/external reads in master are denied, forcing you to delegate to Explore/cd-research; (b) merge-gate — the master snapshot can't absorb a branch without an approved report; (c) branch-write-guard — a branch can't write master records.
- **PostToolUse hook** keeps `registry.json` → `branch-map.md` in sync and performs privileged state transitions.

When a read is denied in the master, that is by design: spawn an **Explore** subagent for codebase questions, or **cd-research** for web/papers, and absorb only the returned conclusion. Do not fight the firewall; `/cd-status --unlock` exists if the user truly needs it off.

## What YOU must judge (the soft layer)

1. **Routing** — where does a request belong?
   - master: changes to goals, scope, constraints, the branch map, merges, snapshots.
   - a branch: exploratory / implementation / research / review work with many intermediate details.
   - explainer sidecar: long explanations, tutorials, "I don't fully get this yet."
2. **Dependency / wave planning** — never assume all branches run in parallel. Classify each: `ready_parallel` (runs now from the current snapshot), `dependent` (needs another branch's output), `gate` (a review/merge/decision), `optional`, `explainer`. Only open current-wave branches. Keep ≤2 active interactive branches; suggest parking/archiving before a third.
3. **What to merge** — at `/cd-merge`, compress to a short approved record, normalize terminology, and separate **proposed global decisions** for explicit user confirmation. Reject reports that don't meet the brief (the cd-merge-verify subagent backs you up). Explainer output never merges by default.
4. **Card before session** — create a branch card + brief (`/cd-branch`) before anyone opens a session. If dependencies are ambiguous, ask the user before creating threads.
5. **Staleness** — if the master snapshot advances in a way that invalidates an active brief, mark it stale and offer to refresh; don't silently sync.
6. **Global decisions** — a decision made inside a branch is not binding until confirmed in the master.

## Commands (the verbs)

`/cd-init` · `/cd-branch` · `/cd-enter` → `/cd-bind` (in the new tab) · `/cd-status` · `/cd-complete` (in the branch) · `/cd-merge` (in the master).

## Session names

`[CD-MAIN][master] <project>` · `[CD-001][W1][<role>] <purpose>` · `[CD-E01][sidecar][explainer] Dirty questions`. Never put mutable status (active/done/blocked) in a title — that lives in the registry/Today View.

## Branch lifecycle

`planned → brief_ready → active → (completion_suggested) → report_ready → merge_pending → merged | rejected → archived` (or `blocked`). State is in `.conductor/registry.json`; the human view in `.conductor/branch-map.md` is rendered from it.
