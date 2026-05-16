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

2. スクリプト出力の `git status --short`、`git diff --stat`、`git diff` を確認する。
3. 差分がない場合は、変更なしとして終了する。
4. 差分がある場合は、スクリプトの確認プロンプトでユーザーにコミット・プッシュしてよいか確認する。
5. ユーザーが承認した場合のみ、スクリプトが同期された変更を stage する。
6. commit 前に staged diff から公開すべきでない情報を検査する。
7. 検査で問題がなければ commit して push する。

## 注意

- スクリプトは `git add`、`git commit`、`git push` まで含む。
- 差分がある場合は、スクリプト内の確認プロンプトで必ずユーザー確認後にコミット・プッシュする。
- 非対話実行で確認入力を受け取れない場合は、コミット・プッシュせず終了する。
- commit 前に、ユーザー名を含むフルパス、ホームディレクトリパス、秘密鍵、API key、token、password、secret などの公開非推奨情報を staged diff で検査する。
- 公開非推奨情報の疑いが見つかった場合は、commit/push せず、該当行を確認して修正する。
- `main` / `master` 上でコミットする場合も、必ずユーザー確認を挟む。
- ユーザーが明示していない変更を戻さない。
- `skills/` は `~/.agents/skills/` のミラーとして扱い、同期元で削除されたスキルは repo 側でも削除する。
