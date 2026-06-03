# Trunkline

[English](README.md) | [中文](README.zh-CN.md)

![Clean master](https://img.shields.io/badge/master-clean-2ea44f)
![Dirty sidecar](https://img.shields.io/badge/dirty_sidecar-welcome-f9c74f)
![Interactive branches](https://img.shields.io/badge/branches-interactive-3b82f6)
![Explicit merge gate](https://img.shields.io/badge/merge-explicit_only-ef4444)
![Codex + Claude Code](https://img.shields.io/badge/works_with-Codex_%2B_Claude_Code-8b5cf6)

Trunkline is a context hygiene and interactive branch orchestration skill for long-running AI work. The protocol is tool-agnostic; this repository includes a Codex-compatible skill folder and one-shot prompts for Codex or Claude Code.

It keeps the **main trunk** clean, creates **interactive branch sessions** for detailed work, and reserves a deliberately **dirty sidecar** where users can ask all the questions that would otherwise poison the master context. Branch context only returns to the trunk through a completion report and a user-approved merge.

## Why Trunkline

Most AI workflows do not fail because the model cannot do the work. They fail because everything lands in one overloaded conversation:

- requirement interviews
- exploratory branches
- implementation details
- failed attempts
- long explanations
- review notes
- final process documentation

Even after workflows like Superpowers or grill-me, users may still not fully understand every part of their own project. That is normal. Trunkline gives that uncertainty a dedicated place: a dirty explainer sidecar for deep questions, tutorials, and repeated clarification, while the master session stays useful as a project control room.

## What It Protects

| Area | What happens | Why it matters |
| --- | --- | --- |
| Clean trunk | The master session keeps only goals, constraints, branch registry, decisions, risks, and approved summaries. | You can always return to the project overview without digging through noisy execution history. |
| Dirty sidecar | A dedicated explainer session absorbs long explanations, background learning, and "I do not fully understand this yet" questions. | Users can learn freely without contaminating the master session. |
| Interactive branches | Subagents are user-enterable sessions, not invisible background workers. | You can steer, question, and refine each branch without manually reopening sessions or reconstructing context. |
| Automatic branch briefs | Trunkline prepares the right starting context for each branch. | The user does not have to repeatedly paste goals, constraints, and hand-written context. |
| Explicit merge gate | A branch only returns through a completion report after user-confirmed completion. | The trunk grows through deliberate knowledge, not accidental context spillover. |
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
│   ├── trunkline.yaml
│   └── trellis-task-meta.json
├── prompts/
│   ├── install-with-claude-code.md
│   └── install-with-codex.md
├── scripts/
│   └── install.sh
└── skills/
    └── trunkline/
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
cp -R skills/trunkline ~/.codex/skills/trunkline
```

Or run the local installer from the repository root:

```bash
bash scripts/install.sh
```

Then start a new Codex session and invoke:

```text
Use $trunkline to split this complex task into interactive branches, keep the master session clean, and only merge approved completion reports.
```

## AI-Assisted Install

You can also hand the installation to Codex or Claude Code with a one-shot prompt:

- [Install with Codex](prompts/install-with-codex.md)
- [Install with Claude Code](prompts/install-with-claude-code.md)

Paste the whole prompt into the target AI coding agent. The prompts already point to this repository.

## Core Protocol

Trunkline follows a few hard rules:

1. The master session owns global context only.
2. Branch sessions are interactive threads, not one-shot background agents.
3. Branches receive only a brief, approved summaries, explicit file references, and messages inside their own thread.
4. Completion reports are generated only after the user confirms branch completion.
5. The master session merges only after explicit user approval.
6. Explainer branches default to no merge.
7. Branch-local global decisions must be confirmed in the master session.

## Trellis Best Practice

With Trellis, Trunkline maps naturally onto parent and child tasks:

- parent/root task: master session
- child task: interactive branch
- Codex / Claude Code thread: user-enterable conversation for the branch
- `branch-map.md`: human-readable branch view
- `task.json.meta.trunkline`: minimal machine-readable binding

Trunkline should prefer Trellis task scripts for parent/child relationships and should not use `implement.jsonl` or `check.jsonl` as a dumping ground for branch chat history.

## Status

Initial public draft. License is intentionally left TBD.
