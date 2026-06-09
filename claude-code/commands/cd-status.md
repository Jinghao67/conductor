---
description: Show the Conductor Today View, wave plan, and staleness; optionally relax the read-firewall.
argument-hint: "[--unlock] [--lock]"
allowed-tools: ["Bash", "Read"]
---

!`D=".conductor"; if [ ! -f "$D/registry.json" ]; then echo "No .conductor — run /cd-init."; else jq -r '"project: "+(.project//"?")+"   current wave: "+(.master.current_wave|tostring)' "$D/registry.json" 2>/dev/null; echo; echo "Branches:"; jq -r '.branches | to_entries[] | "  "+.key+"  ["+.value.status+"]  W"+(.value.execution_wave|tostring)+"  "+.value.title + (if (.value.stale==true) then "  [STALE]" else "" end)' "$D/registry.json" 2>/dev/null; echo; if [ -f "$D/.firewall-off" ]; then echo "read-firewall: RELAXED (.firewall-off present)"; else echo "read-firewall: ACTIVE"; fi; if [ -f "$D/.merge-lock" ]; then echo "merge in flight: $(cat "$D/.merge-lock")"; fi; fi; true`

Present the above as a compact **Today View**: Active now / Planned / Blocked / Merge pending, plus any staleness warnings.

Argument handling for `$ARGUMENTS`:
- If it contains `--unlock`: run `touch .conductor/.firewall-off` to downgrade the master read-firewall from deny to ask for this project, and tell the user to `/cd-status --lock` (or `rm .conductor/.firewall-off`) to restore it.
- If it contains `--lock`: run `rm -f .conductor/.firewall-off` to restore strict enforcement.

Also prune obviously stale bindings if you notice branches that are `merged`/`rejected`/`archived` still holding a `bound_session_id`.
