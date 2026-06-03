# Conductor

[English](README.md) | [中文](README.zh-CN.md)

![Clean master](https://img.shields.io/badge/master-clean-2ea44f)
![Dirty sidecar](https://img.shields.io/badge/dirty_sidecar-welcome-f9c74f)
![Interactive branches](https://img.shields.io/badge/branches-interactive-3b82f6)
![Explicit merge gate](https://img.shields.io/badge/merge-explicit_only-ef4444)
![Codex + Claude Code](https://img.shields.io/badge/works_with-Codex_%2B_Claude_Code-8b5cf6)

Conductor is a context hygiene and interactive branch orchestration skill for long-running AI work. The protocol is tool-agnostic; this repository includes a Codex-compatible skill folder and one-shot prompts for Codex or Claude Code.

Conductor treats a long project like an orchestra. You and the master session stay at the podium with the score: the goal, constraints, decisions, and shape of the whole piece. Each branch takes its own part, the explainer sidecar becomes the rehearsal room for questions and false starts, and only the passages worth keeping are written back into the score.

It keeps the **master session** clean, cues **interactive branch sessions** for detailed work, and reserves a deliberately **dirty sidecar** where users can ask all the questions that would otherwise poison the master context. Branch context only returns to the master session through a completion report and a user-approved merge.

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
| Interactive branches | Subagents are user-enterable sessions, not invisible background workers. | You can steer, question, and refine each branch without manually reopening sessions or reconstructing context. |
| Automatic branch briefs | Conductor prepares the right starting context for each branch. | The user does not have to repeatedly paste goals, constraints, and hand-written context. |
| Explicit merge gate | A branch only returns through a completion report after user-confirmed completion. | The master context grows through deliberate knowledge, not accidental context spillover. |
| Visual registry | Branch maps, snapshots, and Trellis-compatible metadata track where work lives. | The process becomes auditable, recoverable, and easier to roll back. |

## Repository Layout

```text
.
├── README.md
├── README.zh-CN.md
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
Use $conductor to split this complex task into interactive branches, keep the master session clean, and only merge approved completion reports.
```

## AI-Assisted Install

You can also hand the installation to Codex or Claude Code with a one-shot prompt:

- [Install with Codex](prompts/install-with-codex.md)
- [Install with Claude Code](prompts/install-with-claude-code.md)

Paste the whole prompt into the target AI coding agent. The prompts already point to this repository.

## Core Protocol

Conductor follows a few hard rules:

1. The master session owns global context only.
2. Branch sessions are interactive threads, not one-shot background agents.
3. Branches receive only a brief, approved summaries, explicit file references, and messages inside their own thread.
4. Completion reports are generated only after the user confirms branch completion.
5. The master session merges only after explicit user approval.
6. Explainer branches default to no merge.
7. Branch-local global decisions must be confirmed in the master session.

## Trellis Best Practice

With Trellis, Conductor maps naturally onto parent and child tasks:

- parent/root task: master session
- child task: interactive branch
- Codex / Claude Code thread: user-enterable conversation for the branch
- `branch-map.md`: human-readable branch view
- `task.json.meta.conductor`: minimal machine-readable binding

Conductor should prefer Trellis task scripts for parent/child relationships and should not use `implement.jsonl` or `check.jsonl` as a dumping ground for branch chat history.

## Grill-me + Trellis Workflow

Conductor is especially useful when paired with grill-me and Trellis:

| Tool | Role |
| --- | --- |
| `grill-me` | Interrogate the idea until goals, non-goals, constraints, and acceptance criteria are clear. |
| `Conductor` | Route context into the clean master, interactive branches, dirty explainer sidecar, or merge flow. |
| `Trellis` | Persist the structure as parent/child tasks and keep branch artifacts discoverable. |

Recommended flow:

1. Start with grill-me in the master session.
2. When multiple independent directions appear, enable Conductor.
3. Map the master session to a Trellis parent/root task.
4. Map each interactive branch to a Trellis child task and a user-enterable AI coding thread.
5. Keep the dirty explainer sidecar outside Trellis child tasks by default.
6. Generate completion reports only after the user confirms a branch is done.
7. Merge only the approved compressed report back into the master session.

Copyable starter prompt:

```text
Use $grill-me to clarify and pressure-test my requirements first. Once the discussion reveals multiple independent directions, enable $conductor.

Treat this session as the master session. Keep only global goals, constraints, the Trellis branch map, key decisions, risks, and approved summaries here.

Use Trellis to persist the structure: the master session maps to a parent/root task, and each interactive branch maps to a Trellis child task plus a user-enterable AI coding thread.

Split complex exploration, implementation, review, and research into interactive branches. Create a dirty explainer sidecar for questions I do not fully understand; do not merge that sidecar into the master session by default.

For each branch, generate a branch brief before opening the branch. Only after I confirm the branch is complete, generate a completion report. Ask me whether to merge it back into the master session, and merge only the approved compressed summary.
```

## Status

Initial public draft. License is intentionally left TBD.
