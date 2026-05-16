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

check_public_safety() {
  echo
  echo "== Public safety check =="

  local mac_home linux_home private_path patterns
  mac_home="/""Users/"
  linux_home="/""home/"
  private_path="/""private/"
  patterns="(${mac_home}[^[:space:]]+|${linux_home}[^[:space:]]+|${private_path}[^[:space:]]+|-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|sk-[0-9A-Za-z_-]{20,}|(api[_-]?key|token|password|secret)[[:space:]]*[:=][[:space:]]*['\''\"]?[^[:space:]'\''\"]+)"

  if git --no-pager diff --cached --unified=0 --no-ext-diff | grep -E -i "$patterns"; then
    echo
    echo "Potentially private information was found in the staged diff."
    echo "Review and remove these values before committing or pushing."
    exit 1
  fi

  echo "(no obvious private paths, usernames, keys, tokens, passwords, or secrets found)"
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
untracked=$(git ls-files --others --exclude-standard)
if git diff --quiet && [ -z "$untracked" ]; then
  echo "(no changes)"
  exit 0
else
  run git --no-pager diff --stat
fi

echo
echo "== Diff detail =="
if git diff --quiet; then
  echo "(no tracked changes)"
else
  run git --no-pager diff
fi

if [ -n "$untracked" ]; then
  echo
  echo "== Untracked files =="
  printf '%s\n' "$untracked"
fi

echo
echo "== Commit and push confirmation =="
branch=$(git branch --show-current)
if [ -z "$branch" ]; then
  branch="(detached HEAD)"
fi

if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  echo "WARNING: current branch is $branch."
fi

printf 'Commit and push these synced changes? [y/N] '
if ! read -r answer; then
  echo
  echo "No confirmation input; skipped commit and push."
  exit 0
fi

case "$answer" in
  y|Y|yes|YES)
    ;;
  *)
    echo "Skipped commit and push."
    exit 0
    ;;
esac

echo
echo "== Commit =="
run git add AGENTS.md skills
if git diff --cached --quiet; then
  echo "(no staged changes)"
  exit 0
fi
check_public_safety
run git commit -m "change: 🔧 ユーザーAGENTSとスキルを同期"

echo
echo "== Push status =="
run git --no-pager status --short --branch

echo
echo "== Push =="
run git push
