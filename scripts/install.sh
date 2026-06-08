#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root/skills/conductor"
codex_home="${CODEX_HOME:-$HOME/.codex}"
target_dir="$codex_home/skills/conductor"
archive_root="$codex_home/skills-archive"

if [[ ! -d "$source_dir" ]]; then
  echo "Error: skill source not found: $source_dir" >&2
  exit 1
fi

if [[ ! -f "$source_dir/SKILL.md" ]]; then
  echo "Error: SKILL.md not found in $source_dir" >&2
  exit 1
fi

mkdir -p "$codex_home/skills"
mkdir -p "$archive_root"

if [[ -e "$target_dir" ]]; then
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$archive_root/conductor.backup-$timestamp"
  mv "$target_dir" "$backup_dir"
  echo "Existing conductor skill backed up to: $backup_dir"
fi

cp -R "$source_dir" "$target_dir"

echo "Installed conductor skill to: $target_dir"

required_files=(
  "$target_dir/SKILL.md"
  "$target_dir/agents/openai.yaml"
  "$target_dir/references/branch-brief-template.md"
  "$target_dir/references/branch-map-template.md"
  "$target_dir/references/completion-report-template.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: missing installed file: $file" >&2
    exit 1
  fi
done

validator="$codex_home/skills/.system/skill-creator/scripts/quick_validate.py"
if [[ -f "$validator" ]] && command -v python3 >/dev/null 2>&1; then
  if python3 "$validator" "$target_dir"; then
    echo "Validation passed."
  else
    echo "Validation command failed. The files were installed, but please inspect the skill manually." >&2
    exit 1
  fi
else
  echo "Validation skipped: quick_validate.py or python3 not available."
fi

echo
echo "Next: start a new Codex session and say:"
echo "Use \$conductor to keep this as the clean master session, create named branch cards before opening sessions, use CD-DISPATCH for routing debate, use CD-E01 as a context-rich dirty explainer, and merge only approved completion reports."
