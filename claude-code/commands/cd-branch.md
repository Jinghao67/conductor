---
description: Create a Conductor branch CARD and brief (does not open a session). Master only.
argument-hint: "\"<title>\" [--role <role>] [--wave <n>] [--depends-on CD-00X]"
allowed-tools: ["Bash", "Read", "Edit", "Write"]
---

Existing branches and waves (for picking the next id and placing the wave):
!`jq -r '{next_index:( ([.branches|keys[]|sub("CD-";"")|tonumber]|max // 0) + 1 ), branches:[.branches|to_entries[]|{id:.key,status:.value.status,wave:.value.execution_wave,depends_on:.value.depends_on}], waves:.waves}' .conductor/registry.json 2>/dev/null || echo "No .conductor — run /cd-init first."`

Request: `$ARGUMENTS`

Do this:
1. **Judge** the wave and dependencies (this is your job, not a hook's): is this branch `ready_parallel` (runs now from the current snapshot) or `dependent` (needs another branch's output first)? Respect the active interactive-branch budget (max 2). If dependencies are ambiguous, ask the user before creating the card.
2. Choose the next id `CD-NNN` from `next_index` above. Build the stable title `[CD-NNN][W<wave>][<role>] <short purpose>`.
3. **Append the branch to `.conductor/registry.json`** under `.branches["CD-NNN"]` with this shape (status `brief_ready`):
   ```json
   {"title":"<title>","stable_title":"[CD-NNN][W<wave>][<role>] <short>","type":"branch","role":"<role>","status":"brief_ready","execution_wave":<n>,"depends_on":[],"unblocks":[],"start_policy":"current_wave_only","gate_condition":"completion_report_ready","merge_policy":"explicit_user_confirm","based_on_snapshot_id":null,"brief_version":1,"stale":false,"brief_path":".conductor/branches/CD-NNN/brief.md","report_path":".conductor/branches/CD-NNN/completion-report.md","bound_session_id":null}
   ```
   Also add/extend the relevant `.waves[]` entry. (The branch-map.md re-renders automatically.)
4. **Write `.conductor/branches/CD-NNN/brief.md`** — the ONLY context the branch will receive:
   ```markdown
   # Branch CD-NNN — <title>

   ## Purpose Card
   You are branch CD-NNN: <title>
   Purpose: <one precise outcome>
   Not for: <out of scope>
   Input: master snapshot <id>; approved summaries only
   Output: completion-report.md
   Return to master when: output is ready and the user confirms completion

   ## In scope / Out of scope
   ## Allowed context (this brief + listed files only)
   ## Completion criteria
   ## Global-decision rule
   If you make/imply a decision affecting other branches, scope, naming, or goals, record it
   under "Proposed Global Decisions" in the completion report; it is not binding until the master confirms it.
   ```
5. Do NOT open a session. Tell the user: review the card, then `/cd-enter CD-NNN` to start the branch in a new tab.
