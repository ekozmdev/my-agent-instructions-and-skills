#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "" ]]; then
  echo "usage: report.sh <daily|monthly|session> [args...]" >&2
  exit 1
fi

exec npx @ccusage/codex@latest "$@"
