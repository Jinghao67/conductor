# One-Shot Install Prompt For Claude Code

Copy this whole prompt into a Claude Code session.

```text
Please install the Conductor skill from this GitHub repository:

https://github.com/Jinghao67/conductor

This installs a Codex-compatible skill folder. It is not a code refactor.

Requirements:
- Install `skills/conductor` into `${CODEX_HOME:-~/.codex}/skills/conductor`.
- If an existing `conductor` skill is already installed, move it to a timestamped backup before copying the new one.
- Prefer using `scripts/install.sh` from the repository root if it exists.
- Verify these files exist after installation:
  - `SKILL.md`
  - `agents/openai.yaml`
  - `references/branch-brief-template.md`
  - `references/branch-map-template.md`
  - `references/completion-report-template.md`
- Do not edit unrelated files.
- Do not commit or push anything.

Suggested procedure:
1. Clone the repository to a temporary or user-approved folder.
2. Inspect the repository and locate `skills/conductor`.
3. Run `bash scripts/install.sh` from the repository root if available.
4. If no script is available, copy the skill manually with backup.
5. Report:
   - install path
   - backup path, if any
   - whether validation passed or was skipped
   - how to invoke the skill in a fresh Codex session

Trigger phrase:
Use $conductor to split this complex task into interactive branches, keep the master session clean, and only merge approved completion reports.
```
