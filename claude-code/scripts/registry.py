#!/usr/bin/env python3
"""Conductor (Claude Code) registry helper.

Deterministic, derived-view operations on a project's .conductor/registry.json.
Used by hooks (which have ${CLAUDE_PLUGIN_ROOT}); NOT relied on by slash commands.

Subcommands:
  render-branch-map <conductor_dir>   Re-render branch-map.md FROM registry.json.
  validate <conductor_dir>            Exit non-zero if registry.json is malformed.

The model authors registry.json content (add branches, set states) per command
instructions; this script keeps the human-readable view in sync and validates shape.
"""
import json
import os
import sys

STATES = {
    "planned", "brief_ready", "active", "blocked", "completion_suggested",
    "report_ready", "merge_pending", "merged", "rejected", "archived",
}


def load(conductor_dir):
    with open(os.path.join(conductor_dir, "registry.json"), "r") as f:
        return json.load(f)


def render_branch_map(conductor_dir):
    try:
        reg = load(conductor_dir)
    except (OSError, ValueError):
        return 0  # nothing to render; never fail a hook
    master = reg.get("master", {}) or {}
    branches = reg.get("branches", {}) or {}
    waves = reg.get("waves", []) or []

    def by_status(*sts):
        return [(bid, b) for bid, b in branches.items() if (b or {}).get("status") in sts]

    lines = []
    lines.append(f"# Conductor Map: {reg.get('project', 'project')}")
    lines.append("")
    lines.append("> Rendered from registry.json. Do not edit by hand.")
    lines.append("")
    lines.append("## Snapshot")
    lines.append(f"- Snapshot id: {master.get('snapshot_id', '')}")
    lines.append(f"- Current wave: {master.get('current_wave', '')}")
    lines.append(f"- Active interactive branch limit: {master.get('active_interactive_branch_limit', 2)}")
    lines.append("")

    lines.append("## Today View")
    lines.append("")
    lines.append("### Active Now")
    active = by_status("active")
    if active:
        for bid, b in active:
            stale = " [STALE]" if (b or {}).get("stale") else ""
            lines.append(f"- {bid} {b.get('title','')} — {b.get('role','')}{stale}")
    else:
        lines.append("- none")
    lines.append("")
    lines.append("### Planned / Brief Ready")
    planned = by_status("planned", "brief_ready")
    if planned:
        for bid, b in planned:
            dep = ", ".join((b or {}).get("depends_on", []) or [])
            lines.append(f"- {bid} {b.get('title','')}" + (f" — waits for {dep}" if dep else ""))
    else:
        lines.append("- none")
    lines.append("")
    lines.append("### Blocked / Waiting")
    blocked = by_status("blocked")
    lines.append("\n".join(f"- {bid} {b.get('title','')}" for bid, b in blocked) if blocked else "- none")
    lines.append("")
    lines.append("### Merge Pending")
    pend = by_status("report_ready", "merge_pending")
    lines.append("\n".join(f"- {bid} {b.get('title','')}" for bid, b in pend) if pend else "- none")
    lines.append("")

    lines.append("## Wave Plan")
    lines.append("")
    lines.append("| Wave | Branches | Prerequisites | Gate to unlock next wave |")
    lines.append("| --- | --- | --- | --- |")
    for w in waves:
        lines.append(
            f"| {w.get('wave','')} | {', '.join(w.get('branches', []) or [])} "
            f"| {', '.join(w.get('prerequisites', []) or []) or 'none'} | {w.get('gate','')} |"
        )
    lines.append("")

    lines.append("## Branch Registry")
    lines.append("")
    lines.append("| Branch | Type | Role | Status | Wave | Depends on | Unblocks |")
    lines.append("| --- | --- | --- | --- | --- | --- | --- |")
    for bid, b in branches.items():
        b = b or {}
        lines.append(
            f"| {bid} | {b.get('type','')} | {b.get('role','')} | {b.get('status','')} "
            f"| {b.get('execution_wave','')} | {', '.join(b.get('depends_on', []) or []) or 'none'} "
            f"| {', '.join(b.get('unblocks', []) or []) or 'none'} |"
        )
    lines.append("")

    lines.append("## Visualization")
    lines.append("")
    lines.append("```mermaid")
    lines.append("flowchart TD")
    lines.append('  ROOT["CD-MAIN master"]')
    for bid, b in branches.items():
        b = b or {}
        label = f"{bid} {b.get('role','')}".strip()
        lines.append(f'  {bid.replace("-", "_")}["{label}"]')
    for bid, b in branches.items():
        b = b or {}
        deps = (b or {}).get("depends_on", []) or []
        if deps:
            for d in deps:
                lines.append(f'  {d.replace("-", "_")} --> {bid.replace("-", "_")}')
        else:
            lines.append(f'  ROOT -.-> {bid.replace("-", "_")}')
    lines.append("```")
    lines.append("")

    out = os.path.join(conductor_dir, "branch-map.md")
    with open(out, "w") as f:
        f.write("\n".join(lines) + "\n")
    return 0


def validate(conductor_dir):
    try:
        reg = load(conductor_dir)
    except OSError as e:
        print(f"registry.json unreadable: {e}", file=sys.stderr)
        return 1
    except ValueError as e:
        print(f"registry.json is not valid JSON: {e}", file=sys.stderr)
        return 1
    errs = []
    for bid, b in (reg.get("branches", {}) or {}).items():
        st = (b or {}).get("status")
        if st not in STATES:
            errs.append(f"{bid}: invalid status {st!r}")
    if errs:
        print("\n".join(errs), file=sys.stderr)
        return 1
    print("registry.json OK")
    return 0


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 0
    cmd, conductor_dir = argv[1], argv[2]
    if cmd == "render-branch-map":
        return render_branch_map(conductor_dir)
    if cmd == "validate":
        return validate(conductor_dir)
    print(f"unknown subcommand: {cmd}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
