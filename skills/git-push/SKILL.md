---
name: git-push
description: ユーザーが「プッシュして」「公開して」「push したい」と言ったときに使う。プッシュ前の確認をスクリプトでまとめて実行し、状況をユーザーに伝えて確認を取ってから push し、結果を報告するスキル。
---

# Git Push

## 概要

プッシュ前の確認コマンドを `scripts/pre_push_check.sh` にまとめて実行し、状況をユーザーに伝えて確認を取ってから push する。push 後は結果を必ず報告する。

## 手順

### 1. 確認スクリプトを実行する（読み取り専用）

```sh
bash ~/.agents/skills/git-push/scripts/pre_push_check.sh
```

### 2. 未コミット変更の確認

`== Status ==` セクションに未コミット変更が存在する場合は、`/git-commit` スキルの手順に従ってコミットを先に済ませる。コミット完了後、手順 1 からやり直す。

### 3. 出力を分析してユーザーに状況を伝える

以下の点を確認し、ユーザーへの説明に含める：

- **ブランチ名**: main / master の場合はその旨を明示する
- **push 対象コミット**: `== Ahead commits ==` の内容をリストアップする
  - コミットが 0 件の場合は「push するコミットがありません」と伝えて終了する
- **upstream**: 設定済みか未設定かを伝える
  - 未設定の場合は `git push --set-upstream origin <ブランチ名>` で push することを説明する
- **Behind commits**: リモートが進んでいる場合は競合リスクをユーザーに伝える

### 4. ユーザーに確認を取る

状況に応じて以下のような確認をユーザーに取る：

- 通常ケース: 「X 件のコミットを push しますか？」
- main / master ブランチ: 「main ブランチに push します。よろしいですか？」
- upstream 未設定: 「upstream を設定して push します（`git push --set-upstream origin <branch>`）。よろしいですか？」
- Behind commits あり: 「リモートに未取り込みコミットがあります。push すると競合が生じる可能性があります。それでも push しますか？」

ユーザーが拒否した場合はそこで終了する。

### 5. push を実行する

```sh
# upstream が設定済みの場合
git push

# upstream が未設定の場合
git push --set-upstream origin <ブランチ名>
```

### 6. 結果を報告する

- 成功した場合: push されたブランチとリモートを報告する
- 失敗した場合: エラー出力をそのまま示し、原因と対処法をユーザーに伝える
