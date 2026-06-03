# Clean Branch

Clean Branch is a Codex skill for context hygiene and interactive branch orchestration.

It keeps a master session clean while exploratory, implementation-heavy, research-heavy, review-heavy, or explanatory work happens in separate user-interactive branch sessions. A branch only returns to the master session through an explicit completion report and a user-approved merge.

## Why

Long-running AI workflows often collapse into one overloaded context:

- requirement discussion
- exploratory branches
- implementation details
- failed attempts
- long explanations
- review notes
- final process documentation

Clean Branch separates these into a visible branch structure:

- **master session**: project overview, decisions, branch registry, approved summaries
- **interactive branches**: user-enterable Codex threads for messy work
- **explainer sidecar**: a high-pollution learning thread that almost never merges
- **completion reports**: short, explicit summaries generated only after the user confirms a branch is complete

The goal is not to create background workers. The goal is to make multi-session work auditable, recoverable, and easy to understand.

## Repository Layout

```text
.
├── README.md
├── docs/
│   ├── AI_INSTALL.zh.md
│   ├── DESIGN.zh.md
│   └── REVIEW_CHECKLIST.zh.md
├── examples/
│   ├── branch-map.md
│   ├── clean-branch.yaml
│   └── trellis-task-meta.json
├── prompts/
│   ├── install-with-claude-code.md
│   └── install-with-codex.md
├── scripts/
│   └── install.sh
└── skills/
    └── clean-branch/
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
cp -R skills/clean-branch ~/.codex/skills/clean-branch
```

Or run the local installer from the repository root:

```bash
bash scripts/install.sh
```

Then start a new Codex session and invoke:

```text
Use $clean-branch to split this complex task into interactive branches, keep the master session clean, and only merge approved completion reports.
```

## AI-Assisted Install

You can also hand the installation to Codex or Claude Code with a one-shot prompt:

- [Install with Codex](prompts/install-with-codex.md)
- [Install with Claude Code](prompts/install-with-claude-code.md)

Paste the whole prompt into the target AI coding agent. The prompts already point to this repository.

## Core Protocol

Clean Branch follows a few hard rules:

1. The master session owns global context only.
2. Branch sessions are interactive threads, not one-shot background agents.
3. Branches receive only a brief, approved summaries, explicit file references, and messages inside their own thread.
4. Completion reports are generated only after the user confirms branch completion.
5. The master session merges only after explicit user approval.
6. Explainer branches default to no merge.
7. Branch-local global decisions must be confirmed in the master session.

## Trellis Best Practice

With Trellis, Clean Branch maps naturally onto parent and child tasks:

- parent/root task: master session
- child task: interactive branch
- Codex thread: user-enterable conversation for the branch
- `branch-map.md`: human-readable branch view
- `task.json.meta.clean_branch`: minimal machine-readable binding

Clean Branch should prefer Trellis task scripts for parent/child relationships and should not use `implement.jsonl` or `check.jsonl` as a dumping ground for branch chat history.

## Status

Initial public draft. License is intentionally left TBD.
