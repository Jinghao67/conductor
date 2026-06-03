# One-Shot Install Prompt For Codex

Copy this whole prompt into a Codex session.

```text
Install the Trunkline skill from this GitHub repository:

https://github.com/Jinghao67/trunkline

Goal:
- Install the repository's Codex-compatible `skills/trunkline` folder into my Codex skills directory at `${CODEX_HOME:-~/.codex}/skills/trunkline`.
- Preserve any existing installed `trunkline` skill by moving it to a timestamped backup.
- Verify that the installed skill contains `SKILL.md`, `agents/openai.yaml`, and the three reference templates.
- If the repo has `scripts/install.sh`, prefer running that script from the repo root.
- If validation tools are available, run the Codex skill quick validator.
- Do not push, commit, or modify unrelated files.

Steps:
1. Clone the repository into a temporary or user-approved local directory.
2. Inspect the repo layout and confirm `skills/trunkline/SKILL.md` exists.
3. Run `bash scripts/install.sh` from the repo root if present.
4. If the script is not present, install manually:
   - create `${CODEX_HOME:-~/.codex}/skills`
   - back up any existing `${CODEX_HOME:-~/.codex}/skills/trunkline`
   - copy `skills/trunkline` into `${CODEX_HOME:-~/.codex}/skills/trunkline`
5. Verify the installed files.
6. Report the install path, any backup path, validation result, and the exact trigger phrase:

Use $trunkline to split this complex task into interactive branches, keep the master session clean, and only merge approved completion reports.
```
