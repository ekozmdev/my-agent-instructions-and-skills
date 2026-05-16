#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "" ]]; then
  echo "usage: model_breakdown.sh <daily|monthly|session> [ccusage args...]" >&2
  exit 1
fi

grouping="$1"
shift

case "$grouping" in
  daily|monthly|session) ;;
  *)
    echo "unsupported grouping: $grouping" >&2
    exit 1
    ;;
esac

npx @ccusage/codex@latest "$grouping" --json "$@" | node -e '
const fs = require("fs");

const input = fs.readFileSync(0, "utf8");
const data = JSON.parse(input);
const groups = data.monthly ?? data.daily ?? data.sessions;

if (!Array.isArray(groups)) {
  console.error("unexpected ccusage JSON shape");
  process.exit(1);
}

const summary = new Map();

for (const group of groups) {
  const models = group.models ?? {};
  for (const [name, metrics] of Object.entries(models)) {
    const row = summary.get(name) ?? {
      model: name,
      inputTokens: 0,
      cachedInputTokens: 0,
      outputTokens: 0,
      reasoningOutputTokens: 0,
      totalTokens: 0,
      costUSD: 0,
      groups: 0,
      hasFallback: false,
    };
    row.inputTokens += metrics.inputTokens ?? 0;
    row.cachedInputTokens += metrics.cachedInputTokens ?? 0;
    row.outputTokens += metrics.outputTokens ?? 0;
    row.reasoningOutputTokens += metrics.reasoningOutputTokens ?? 0;
    row.totalTokens += metrics.totalTokens ?? 0;
    row.groups += 1;
    row.hasFallback ||= Boolean(metrics.isFallback);
    summary.set(name, row);
  }

  const costUSD = Number(group.costUSD ?? 0);
  const totalTokens = Number(group.totalTokens ?? 0);
  if (costUSD > 0 && totalTokens > 0) {
    for (const [name, metrics] of Object.entries(models)) {
      const modelTokens = Number(metrics.totalTokens ?? 0);
      const row = summary.get(name);
      row.costUSD += costUSD * (modelTokens / totalTokens);
    }
  }
}

const rows = Array.from(summary.values()).sort((left, right) => {
  return right.costUSD - left.costUSD || right.totalTokens - left.totalTokens;
});

const formatInt = (value) => new Intl.NumberFormat("en-US").format(Math.round(value));
const formatCost = (value) => `$${value.toFixed(2)}`;

const headers = [
  "Model",
  "Cost",
  "Total Tokens",
  "Input",
  "Cache Read",
  "Output",
  "Reasoning",
  "Groups",
  "Fallback",
];

const table = rows.map((row) => [
  row.model,
  formatCost(row.costUSD),
  formatInt(row.totalTokens),
  formatInt(row.inputTokens),
  formatInt(row.cachedInputTokens),
  formatInt(row.outputTokens),
  formatInt(row.reasoningOutputTokens),
  String(row.groups),
  row.hasFallback ? "yes" : "no",
]);

const widths = headers.map((header, index) =>
  Math.max(header.length, ...table.map((row) => row[index].length)),
);

const renderRow = (row) =>
  row
    .map((cell, index) => cell.padEnd(widths[index]))
    .join("  ")
    .trimEnd();

console.log(renderRow(headers));
console.log(widths.map((width) => "-".repeat(width)).join("  "));
for (const row of table) {
  console.log(renderRow(row));
}
' 
