#!/usr/bin/env bash
set -euo pipefail

repo="$HOME/workspace/my-agent-instructions-and-skills"
agents_source="$HOME/.codex/AGENTS.md"
skills_source="$HOME/.agents/skills/"

print_cmd() {
  printf '$ %s\n' "$*"
}

run() {
  print_cmd "$*"
  "$@"
}

if [ ! -d "$repo/.git" ]; then
  echo "Not a git repository: $repo"
  exit 1
fi

if [ ! -f "$agents_source" ]; then
  echo "Missing source AGENTS.md: $agents_source"
  exit 1
fi

if [ ! -d "$skills_source" ]; then
  echo "Missing source skills directory: $skills_source"
  exit 1
fi

cd "$repo"

echo "== Sync sources =="
printf 'AGENTS.md: %s -> %s\n' "$agents_source" "$repo/AGENTS.md"
printf 'skills: %s -> %s\n' "$skills_source" "$repo/skills/"

echo
echo "== Copy AGENTS.md =="
run cp "$agents_source" "$repo/AGENTS.md"

echo
echo "== Sync skills =="
run mkdir -p "$repo/skills"
run rsync -a --delete "$skills_source" "$repo/skills/"

echo
echo "== Status =="
run git --no-pager status --short

echo
echo "== Diff stat =="
if git diff --quiet; then
  echo "(no changes)"
else
  run git --no-pager diff --stat
fi
