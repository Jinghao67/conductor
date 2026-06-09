# Conductor for Claude Code

A Claude Code **plugin** port of [Conductor](../README.md). Same protocol — one clean master
session, dependency-aware interactive branches, a dirty explainer sidecar, an explicit merge
gate — but rebuilt around Claude Code's native harness so the rules are **enforced**, not just
suggested.

The original (on `main`) is a Codex skill that relies on the model following `SKILL.md`. This
version leans on the harness:

| Conductor need | Claude Code mechanism |
| --- | --- |
| Master never sees a branch's raw history | branches are **separate sessions** (separate context windows) + the SessionStart hook injects only the right context |
| Master never bulk-reads code/web into itself | **PreToolUse read-firewall** → delegate to the built-in **Explore** subagent / `cd-research` |
| No merge without an approved report | **PreToolUse merge-gate** + the `cd-merge-verify` subagent |
| A branch can't corrupt master records | **PreToolUse branch-write-guard** |
| Human view never drifts from state | **PostToolUse** renders `branch-map.md` from `registry.json` |
| Distilled state survives long sessions | **PreCompact** staleness nudge |
| The judgment (routing, waves, what-to-merge) | the `conductor-cc` **skill** |

## The mental model

You only ever type into the **master**. A branch is a **separate session you open and drive
directly**; the master can't see its history and inherits only the final completion report.
Subagents are throwaway reading instruments (Explore / cd-research) and one-shot helpers
(`cd-merge-verify`), never branches.

```
master tab                              branch tab (you drive it directly)
  /cd-branch  ─ writes brief ─▶ .conductor/branches/CD-001/brief.md
                                          /cd-bind CD-001   (injects ONLY the brief)
                                          …direct, messy work…
                                          /cd-complete ─▶ completion-report.md
  /cd-merge CD-001 ◀─ reads ONLY the report ─┘  (cd-merge-verify gates it)
```

## Install (local dev)

```bash
claude plugin validate ./claude-code
claude --plugin-dir ./claude-code
```

Then, in a project: `/cd-init` to make the current session the master.

## Commands

`/cd-init` · `/cd-branch "<title>" --role <r> --wave <n>` · `/cd-enter <id>` → `/cd-bind <id>`
(in the new tab) · `/cd-status [--unlock|--lock]` · `/cd-complete` (in the branch) ·
`/cd-merge <id>` (in the master).

## State (`.conductor/` in the project)

`registry.json` (source of truth) · `branch-map.md` (rendered) · `master-snapshot.md`
(what the master is reseeded with) · `branches/CD-NNN/{brief,completion-report}.md` ·
`bindings/<session-id>.json` (gitignored) · `snapshots/`.

## Status

v0.1 — the full master→branch→complete→merge loop, read-firewall, and merge gate. Wave-planning
(`cd-dispatch`), `cd-research`, and the macOS auto-open-tab helper are planned next. See
[`docs/`](../docs) for the design and the implementation plan.
