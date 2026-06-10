# Conductor

[English](README.md) | [中文](README.zh-CN.md)

<p align="center">
    <a href="https://linux.do" alt="LINUX DO">
        <img src="https://img.shields.io/badge/LINUX-DO-FFB003.svg?logo=data:image/svg%2bxml;base64,DQo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCIgaGVpZ2h0PSIxMDAiPjxwYXRoIGQ9Ik00Ni44Mi0uMDU1aDYuMjVxMjMuOTY5IDIuMDYyIDM4IDIxLjQyNmM1LjI1OCA3LjY3NiA4LjIxNSAxNi4xNTYgOC44NzUgMjUuNDV2Ni4yNXEtMi4wNjQgMjMuOTY4LTIxLjQzIDM4LTExLjUxMiA3Ljg4NS0yNS40NDUgOC44NzRoLTYuMjVxLTIzLjk3LTIuMDY0LTM4LjAwNC0yMS40M1EuOTcxIDY3LjA1Ni0uMDU0IDUzLjE4di02LjQ3M0MxLjM2MiAzMC43ODEgOC41MDMgMTguMTQ4IDIxLjM3IDguODE3IDI5LjA0NyAzLjU2MiAzNy41MjcuNjA0IDQ2LjgyMS0uMDU2IiBzdHlsZT0ic3Ryb2tlOm5vbmU7ZmlsbC1ydWxlOmV2ZW5vZGQ7ZmlsbDojZWNlY2VjO2ZpbGwtb3BhY2l0eToxIi8+PHBhdGggZD0iTTQ3LjI2NiAyLjk1N3EyMi41My0uNjUgMzcuNzc3IDE1LjczOGE0OS43IDQ5LjcgMCAwIDEgNi44NjcgMTAuMTU3cS00MS45NjQuMjIyLTgzLjkzIDAgOS43NS0xOC42MTYgMzAuMDI0LTI0LjM4N2E2MSA2MSAwIDAgMSA5LjI2Mi0xLjUwOCIgc3R5bGU9InN0cm9rZTpub25lO2ZpbGwtcnVsZTpldmVub2RkO2ZpbGw6IzE5MTkxOTtmaWxsLW9wYWNpdHk6MSIvPjxwYXRoIGQ9Ik03Ljk4IDcwLjkyNmMyNy45NzctLjAzNSA1NS45NTQgMCA4My45My4xMTNRODMuNDI2IDg3LjQ3MyA2Ni4xMyA5NC4wODZxLTE4LjgxIDYuNTQ0LTM2LjgzMi0xLjg5OC0xNC4yMDMtNy4wOS0yMS4zMTctMjEuMjYyIiBzdHlsZT0ic3Ryb2tlOm5vbmU7ZmlsbC1ydWxlOmV2ZW5vZGQ7ZmlsbDojZjlhZjAwO2ZpbGwtb3BhY2l0eToxIi8+PC9zdmc+" alt="LINUX DO" />
    </a>
</p>

![Clean master](https://img.shields.io/badge/master-clean-2ea44f)
![Dirty sidecar](https://img.shields.io/badge/dirty_sidecar-welcome-f9c74f)
![Interactive branches](https://img.shields.io/badge/branches-interactive-3b82f6)
![Dispatch room](https://img.shields.io/badge/dispatch-routing_room-06b6d4)
![Dependency-aware](https://img.shields.io/badge/order-dependency_aware-f97316)
![Explicit merge gate](https://img.shields.io/badge/merge-explicit_only-ef4444)
![Codex + Claude Code](https://img.shields.io/badge/works_with-Codex_%2B_Claude_Code-8b5cf6)

Conductor is a context hygiene and interactive branch orchestration skill for long-running AI work. The protocol is tool-agnostic; this repository includes a Codex-compatible skill folder, a Claude Code-native plugin adapter, and one-shot prompts for Codex or Claude Code.

Conductor treats a long project like an orchestra. You and the master session stay at the podium with the score: the goal, constraints, decisions, and shape of the whole piece. The dispatch room decides which parts should play now and which must wait. Each branch takes its own part, the explainer sidecar becomes the rehearsal room for questions and false starts, and only the passages worth keeping are written back into the score.

It keeps the **master session** clean, cues **interactive branch sessions** for detailed work, reserves a **dispatch session** for session-planning debate, and keeps a deliberately **dirty sidecar** where users can ask all the questions that would otherwise poison the master context. Branch context only returns to the master session through a completion report and a user-approved merge.

## Why Conductor

Most AI workflows do not fail because the model cannot do the work. They fail because everything lands in one overloaded conversation:

- requirement interviews
- exploratory branches
- implementation details
- failed attempts
- long explanations
- review notes
- final process documentation

Even after workflows like Superpowers or grill-me, users may still not fully understand every part of their own project. That is normal. Conductor gives that uncertainty a dedicated place: a dirty explainer sidecar for deep questions, tutorials, and repeated clarification, while the master session stays useful as the project control room.

## What It Protects

| Area | What happens | Why it matters |
| --- | --- | --- |
| Clean master | The master session keeps only goals, constraints, branch registry, decisions, risks, and approved summaries. | You can always return to the project overview without digging through noisy execution history. |
| Dirty sidecar | A dedicated explainer session absorbs long explanations, background learning, and "I do not fully understand this yet" questions. | Users can learn freely without contaminating the master session. |
| Omniscient explainer | The dirty explainer may read across all session contexts on demand, while labeling which sources are confirmed or branch-local. | It can answer project-wide questions without becoming an authority that rewrites the master session. |
| Dispatch room | A fixed routing session discusses whether to open new sessions, whether work is parallel or serial, and which wave should run next. | The master session avoids being polluted by meta-discussion about session planning. |
| Interactive branches | Subagents are user-enterable sessions, not invisible background workers. | You can steer, question, and refine each branch without manually reopening sessions or reconstructing context. |
| Stable session names | Every session gets a stable ID and title such as `[CD-001][W1][task] First confirmed branch`. | You can recognize every thread from the session list. |
| Automatic branch briefs | Conductor prepares the right starting context for each branch. | The user does not have to repeatedly paste goals, constraints, and hand-written context. |
| Dependency-aware waves | Conductor decides which branches can run now and which must wait for earlier outputs. | Work starts in the right order instead of pretending every subagent can run in parallel. |
| Explicit merge gate | A branch only returns through a completion report after user-confirmed completion. | The master context grows through deliberate knowledge, not accidental context spillover. |
| Visual registry | Branch maps, snapshots, and Trellis-compatible metadata track where work lives. | The process becomes auditable, recoverable, and easier to roll back. |

## Repository Layout

```text
.
├── README.md
├── README.zh-CN.md
├── claude-code/
│   ├── .claude-plugin/plugin.json
│   ├── commands/
│   ├── hooks/
│   ├── scripts/
│   └── skills/conductor-cc/
├── docs/
│   ├── AI_INSTALL.zh.md
│   ├── DESIGN.zh.md
│   └── REVIEW_CHECKLIST.zh.md
├── examples/
│   ├── branch-map.md
│   ├── conductor.yaml
│   └── trellis-task-meta.json
├── prompts/
│   ├── install-with-claude-code.md
│   └── install-with-codex.md
├── scripts/
│   └── install.sh
└── skills/
    └── conductor/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/
            ├── branch-brief-template.md
            ├── branch-map-template.md
            └── completion-report-template.md
```

## Install

### Codex Skill

Copy the skill folder into your Codex skills directory:

```bash
cp -R skills/conductor ~/.codex/skills/conductor
```

Or run the local installer from the repository root:

```bash
bash scripts/install.sh
```

Then start a new Codex session and invoke:

```text
Use $conductor to keep this as the clean master session, create named branch cards before opening sessions, use CD-DISPATCH for routing debate, use CD-E01 as a context-rich dirty explainer, and merge only approved completion reports.
```

### Claude Code Plugin

Claude Code users can use the native adapter under [`claude-code/`](claude-code/). It ports Conductor into Claude Code slash commands and hooks, so the same protocol is enforced by the Claude Code harness:

```bash
claude plugin validate ./claude-code
claude --plugin-dir ./claude-code
```

Then, inside a project, run `/cd-init` to make the current Claude Code session the Conductor master.

## AI-Assisted Install

You can also hand the installation to Codex or Claude Code with a one-shot prompt:

- [Install with Codex](prompts/install-with-codex.md)
- [Install with Claude Code](prompts/install-with-claude-code.md)

Paste the whole prompt into the target AI coding agent. The prompts already point to this repository.

## Core Protocol

Conductor follows a few hard rules:

1. The master session owns global context only.
2. Conductor creates visible branch cards before opening real sessions.
3. Every session must have a stable title, purpose card, expected output, and return condition.
4. Branch sessions are interactive threads, not one-shot background agents.
5. Branches receive only a brief, approved summaries, explicit file references, and messages inside their own thread.
6. Branches are not assumed parallel; Conductor plans dependency-aware waves before opening threads.
7. The dispatch session handles session-planning debate and returns only final routing decisions to the master.
8. Completion reports are generated only after the user confirms branch completion.
9. The master session merges only after explicit user approval.
10. Explainer branches default to no merge, even though the explainer may read across all session contexts on demand.
11. Branch-local global decisions must be confirmed in the master session.

## Session Naming

Conductor uses stable titles so the thread list stays navigable. The initial open sessions should stay small: usually the clean master, the optional dispatch room, the dirty explainer, and the first user-confirmed branch.

```text
[CD-MAIN][master] Project control room
[CD-DISPATCH][routing] Branch planning
[CD-E01][sidecar][explainer] Dirty questions
[CD-001][W1][task] First confirmed branch
```

Do not put mutable status such as `active`, `done`, or `blocked` in the title. Status belongs in the branch map and Today View.

Replace `task` and `First confirmed branch` with the actual role and purpose from the confirmed branch card. Later branches such as `[CD-002][W1][review] Risk check` or `[CD-003][W2][implement] Prototype implementation` should start as planned branch cards, not open sessions. A card becomes a session only after the user confirms the card, stable title, purpose, output, and return condition.

## Trellis Best Practice

With Trellis, Conductor maps naturally onto parent and child tasks:

- parent/root task: master session
- dispatch session: sidecar routing thread, not a Trellis child task by default
- child task: interactive branch
- Codex / Claude Code thread: user-enterable conversation for the branch
- explainer sidecar: dirty context-rich explanation thread, not a Trellis child task by default
- `branch-map.md`: human-readable branch view
- `task.json.meta.conductor`: minimal machine-readable binding
- dependency fields: `execution_wave`, `depends_on`, `unblocks`, `gate_condition`

Conductor should prefer Trellis task scripts for parent/child relationships and should not use `implement.jsonl` or `check.jsonl` as a dumping ground for branch chat history.

## Grill-me (or grill-me-docs) + Trellis Workflow

Conductor is especially useful when paired with grill-me (or grill-me-docs) and Trellis:

| Tool | Role |
| --- | --- |
| `grill-me` (or `grill-me-docs`) | Interrogate the idea until goals, non-goals, constraints, and acceptance criteria are clear. |
| `Conductor` | Route context into the clean master, interactive branches, dirty explainer sidecar, or merge flow. |
| `Trellis` | Persist the structure as parent/child tasks and keep branch artifacts discoverable. |

Recommended flow:

1. Start with grill-me (or grill-me-docs) in the master session.
2. When multiple independent directions appear, enable Conductor.
3. If session planning becomes multi-turn, open `[CD-DISPATCH][routing] Branch planning` and keep routing debate out of the master session.
4. Run a dependency pass before opening threads: identify what can run now, what must wait, and what gate unlocks the next wave.
5. Create branch cards before creating real sessions.
6. Map the master session to a Trellis parent/root task.
7. Map current-wave interactive branches to Trellis child tasks and user-enterable AI coding threads.
8. Keep dependent branches as planned or blocked until their prerequisites are done.
9. Keep `[CD-E01][sidecar][explainer] Dirty questions` outside Trellis child tasks by default, but allow it to read relevant context across all sessions on demand.
10. Generate completion reports only after the user confirms a branch is done.
11. Merge only the approved compressed report back into the master session.

Copyable starter prompt:

```text
Use $grill-me (or $grill-me-docs) first if the requirements are still unclear. Once the work splits into multiple directions, enable $conductor.

Treat this session as [CD-MAIN][master] Project control room. Keep only goals, constraints, the branch map, confirmed decisions, risks, snapshots, and approved summaries here.

Create branch cards before opening sessions. Each card must include stable title, purpose, allowed context, expected output, dependencies/wave, completion criteria, and return condition. Open only user-confirmed current-wave branches, with at most two active interactive branches; keep later branches planned or blocked.

Use stable names: [CD-DISPATCH][routing] Branch planning only when routing debate needs its own thread, [CD-E01][sidecar][explainer] Dirty questions as the single dirty explainer, and branch titles like [CD-001][W1][task] First confirmed branch with the real role and purpose substituted.

Run a dependency pass before opening branches. Branches are user-interactive and receive only their branch brief plus approved master context. The explainer may read relevant context across sessions for questions, but is non-authoritative and no-merge by default.

After I confirm a branch is complete, generate its completion report. Ask before merging; merge only my approved compressed summary into master. If I am using Trellis, persist the branch map, parent/child tasks, and task.json.meta.conductor fields without dumping raw chat into implement.jsonl or check.jsonl.
```

## Status

Initial public draft. License is intentionally left TBD.
