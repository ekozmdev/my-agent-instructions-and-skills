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

# 作業ツリーに未コミット変更が残っていないか確認する
echo
echo "== Status =="
run git --no-pager status --short

# upstream の設定有無を確認する
echo
echo "== Upstream =="
print_cmd "git rev-parse --abbrev-ref --symbolic-full-name @{u}"
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
  echo "upstream: $upstream"

# push 対象になる未プッシュコミットを確認する
  echo
  echo "== Ahead commits =="
  print_cmd "git --no-pager log --oneline --decorate --reverse @{u}..HEAD"
  log=$(git --no-pager log --oneline --decorate --reverse @{u}..HEAD)
  if [ -z "$log" ]; then
    echo "(no commits ahead of upstream)"
  else
    printf '%s\n' "$log"
  fi

# リモート側に未取り込みコミットがないか確認する
  echo
  echo "== Behind commits =="
  print_cmd "git --no-pager log --oneline --decorate --reverse HEAD..@{u}"
  behind_log=$(git --no-pager log --oneline --decorate --reverse HEAD..@{u})
  if [ -z "$behind_log" ]; then
    echo "(no commits behind upstream)"
  else
    printf '%s\n' "$behind_log"
  fi
else
# upstream がない場合は直近コミットを確認する
  echo "(no upstream set) showing last 10 commits"
  print_cmd "git --no-pager log --oneline --decorate -n 10"
  git --no-pager log --oneline --decorate -n 10
fi
