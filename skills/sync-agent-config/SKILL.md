---
name: sync-agent-config
description: ユーザーレベルの AGENTS.md または ~/.agents/skills 配下のスキルを更新した場合に実行する。~/.codex/AGENTS.md と ~/.agents/skills を GitHub 管理リポジトリへ同期し、差分があればユーザー確認後にコミット・プッシュするスキル。
---

# Sync Agent Config

## 目的

ユーザーレベルの `AGENTS.md` とユーザースキルを `~/workspace/my-agent-instructions-and-skills` に同期し、GitHub に上げる。同期対象は `~/.codex/AGENTS.md` と `~/.agents/skills/`。

## 手順

1. 同期スクリプトを実行する。

```sh
bash ~/.agents/skills/sync-agent-config/scripts/sync_agent_config.sh
```

2. スクリプト出力の `git status --short` と `git diff --stat` を確認する。
3. 差分がない場合は、変更なしとして終了する。
4. 差分がある場合は、`~/workspace/my-agent-instructions-and-skills` で詳細差分を確認する。

```sh
git --no-pager diff
```

5. 差分の内容をユーザーに説明し、コミット・プッシュしてよいか確認する。
6. ユーザーが承認した場合のみ、同期された変更を stage してコミットする。

```sh
git add AGENTS.md skills
git commit -m "change: 🔧 ユーザーAGENTSとスキルを同期"
```

7. コミット後、push 前の状態を確認してから push する。

```sh
git status --short --branch
git push
```

## 注意

- `git add`、`git commit`、`git push` はスクリプトに含めない。
- 差分がある場合は、必ずユーザー確認後にコミット・プッシュする。
- `main` / `master` 上でコミットする場合も、必ずユーザー確認を挟む。
- ユーザーが明示していない変更を戻さない。
- `skills/` は `~/.agents/skills/` のミラーとして扱い、同期元で削除されたスキルは repo 側でも削除する。
