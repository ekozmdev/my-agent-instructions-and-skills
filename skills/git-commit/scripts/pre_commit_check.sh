#!/usr/bin/env bash
set -euo pipefail

print_cmd() {
  printf '$ %s\n' "$*"
}

run() {
  print_cmd "$*"
  "$@"
}

print_cmd "git rev-parse --is-inside-work-tree"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository (run inside a repo)."
  exit 1
fi

# 現在のブランチと upstream との差分状態を確認する
branch=$(git branch --show-current)
if [ -z "$branch" ]; then
  branch="(detached HEAD)"
fi

echo "== Summary =="
print_cmd "git status --short --branch"
git --no-pager status --short --branch

if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  echo "WARNING: current branch is $branch."
fi

# 作業ツリー全体の変更一覧を確認する
echo
echo "== Status =="
run git --no-pager status --short

# 未追跡ファイルを確認する
echo
echo "== Untracked files =="
print_cmd "git ls-files --others --exclude-standard"
untracked=$(git ls-files --others --exclude-standard)
if [ -z "$untracked" ]; then
  echo "(no untracked files)"
else
  printf '%s\n' "$untracked"
fi

# ステージ済み変更の概要を確認する
echo
echo "== Staged diff stat =="
print_cmd "git --no-pager diff --staged --stat"
if git diff --staged --quiet; then
  echo "(no staged changes)"
else
  git --no-pager diff --staged --stat
fi

# ステージ済み変更の詳細を確認する
echo
echo "== Staged diff detail =="
print_cmd "git --no-pager diff --staged --quiet"
if git diff --staged --quiet; then
  echo "(no staged changes)"
else
  run git --no-pager diff --staged
fi

# 未ステージ変更の概要を確認する
echo
echo "== Worktree diff stat =="
print_cmd "git --no-pager diff --stat"
if git diff --quiet; then
  echo "(no unstaged changes)"
else
  git --no-pager diff --stat
fi

# 未ステージ変更の詳細を確認する
echo
echo "== Worktree diff detail =="
print_cmd "git --no-pager diff --quiet"
if git diff --quiet; then
  echo "(no unstaged changes)"
else
  run git --no-pager diff
fi
