---
name: sync-agent-config
description: ユーザーレベルの AGENTS.md または ~/.agents/skills 配下のスキルを更新した場合に実行する。~/.codex/AGENTS.md と ~/.agents/skills を GitHub 管理リポジトリへ同期し、差分があればユーザー確認後にコミット・プッシュするスキル。
---

# Sync Agent Config

## 目的

ユーザーレベルの `AGENTS.md` とユーザースキルを `~/workspace/my-agent-instructions-and-skills` に同期し、GitHub に上げる。同期対象は `~/.codex/AGENTS.md` と `~/.agents/skills/`。

## 手順

### 1. 同期スクリプトを実行する

```sh
bash ~/.agents/skills/sync-agent-config/scripts/sync_agent_config.sh
```

スクリプトは同期と差分表示のみ行う。コミット・プッシュはしない。

### 2. 差分を確認する

- 差分がない場合は「変更なし」として終了する。
- 差分がある場合は次のステップへ進む。

### 3. コミットメッセージを考える

`== Diff stat ==` と `== Untracked files ==` の内容をもとに、変更内容を表す Conventional Commit 形式のメッセージを考える。

- 追加・削除・変更されたスキル名やファイルを具体的に示す
- 例: `feat: add git-push skill, remove git-pre-push skill`
- 例: `chore: update AGENTS.md`

### 4. ユーザーに確認を取る

提案したコミットメッセージを示し、コミット・プッシュして良いか確認する。main / master ブランチの場合はその旨を明示する。ユーザーが拒否した場合は終了する。

### 5. 公開安全性を検査する

staged diff に以下の情報が含まれていないか確認する。含まれている場合はコミット・プッシュせず、該当箇所をユーザーに伝えて修正を促す。

- フルパス（`/Users/...`、`/home/...`）
- 秘密鍵、API キー、トークン、パスワード、シークレット

```sh
cd ~/workspace/my-agent-instructions-and-skills
git add AGENTS.md skills
git --no-pager diff --cached --unified=0 --no-ext-diff
```

### 6. コミット・プッシュする

```sh
cd ~/workspace/my-agent-instructions-and-skills
git add AGENTS.md skills
git commit -m "<考えたメッセージ>"
git push
```

### 7. 結果を報告する

push されたコミットハッシュとメッセージを報告する。

## 注意

- ユーザーが明示していない変更を戻さない
- `skills/` は `~/.agents/skills/` のミラーとして扱い、同期元で削除されたスキルは repo 側でも削除する
