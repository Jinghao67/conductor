---
description: Initialize Conductor in this project and bind the current session as the clean master control room.
argument-hint: "[project-name]"
allowed-tools: ["Bash", "Read", "Edit", "Write"]
---

Scaffolding result (runs before you act):
!`D=".conductor"; mkdir -p "$D/branches" "$D/bindings" "$D/snapshots"; SID="${CLAUDE_SESSION_ID}"; PROJ="$(basename "$PWD")"; if [ ! -f "$D/registry.json" ]; then printf '{"schema_version":1,"project":"%s","master":{"session_id":"%s","snapshot_id":null,"current_wave":1,"active_interactive_branch_limit":2},"waves":[],"branches":{},"snapshots":[]}\n' "$PROJ" "$SID" > "$D/registry.json"; else tmp="$(mktemp)"; jq --arg s "$SID" '.master.session_id=$s' "$D/registry.json" > "$tmp" && mv "$tmp" "$D/registry.json"; fi; printf '{"session_id":"%s","role":"master","branch_id":null}\n' "$SID" > "$D/bindings/$SID.json"; [ -f "$D/master-snapshot.md" ] || printf '# Master Snapshot\n\n- Goal: <fill>\n- Constraints: <fill>\n- Current wave: 1\n' > "$D/master-snapshot.md"; echo "initialized .conductor (master session bound)"`

You are now the **Conductor master (control room)** for this project (`$ARGUMENTS` overrides the project name if given — update `.conductor/registry.json` `.project` if so).

Master discipline now in effect (enforced by hooks):
- Hold only goals, constraints, the branch map, confirmed decisions, risks, and approved summaries here.
- Broad/external reads (Grep/Glob/WebFetch/WebSearch/large Read) are **firewalled** in this session — delegate them to the **Explore** subagent (codebase) or **cd-research** (web/papers); only their distilled result returns here.
- Branches are separate sessions you drive directly; they return only through approved completion reports.

Next steps to tell the user:
1. Edit `.conductor/master-snapshot.md` to capture the real goal and constraints.
2. `/cd-branch "<title>" --role <role> --wave <n>` to create the first branch card.
3. `/cd-status` any time for the Today View.
