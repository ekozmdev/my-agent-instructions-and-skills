---
name: git-commit
description: ユーザーが「コミットして」「コミット作って」「コミット前確認」「コミットメッセージを考えて」と言ったときに使う。既存の確認スクリプトを実行し、差分からコミット粒度と Conventional Commit 形式のメッセージを決め、必要に応じて stage/commit して結果を報告するスキル。
---

# Git Commit

## 目的

差分を確認し、コミット粒度を決め、Conventional Commit 形式のメッセージを付けてコミットする。最後にコミット hash、件名、含めた変更のサマリーをユーザーに報告する。

## 手順

1. リポジトリで既存の確認スクリプトを最初に実行する。

```sh
bash ~/.agents/skills/git-commit/scripts/pre_commit_check.sh
```

2. `Staged diff`、`Worktree diff`、`Untracked files` を確認し、コミット粒度を確定する。
3. コミットメッセージを検討する。
4. コミット対象のファイルだけを stage する。
5. Conventional Commit 形式でコミットする。
6. コミット hash、件名、含めた変更のサマリーをユーザーに報告する。

## コミット粒度

- 単一目的の変更なら、そのまま 1 コミットにまとめる。
- 複数目的の差分が混ざっている場合は、コミット分割案を提示してユーザーに確認する。
- 未追跡ファイル、生成物らしきファイル、ロックファイル、大きな差分、無関係な変更が混ざっている場合は、含める前にユーザーに確認する。
- ユーザーが明示していない変更は戻さない。

## 自律実行

次の条件をすべて満たす場合は、確認を挟まず stage/commit まで進めてよい。

- 変更が単一目的である。
- コミット対象ファイルが明確である。
- 生成物や無関係な変更が混ざっていない。
- 現在のブランチが `main` / `master` ではない。

次の場合はコミット前にユーザー確認を挟む。

- 現在のブランチが `main` / `master` である。
- 分割コミットが妥当である。
- 未追跡ファイルを含めるか判断できない。
- ユーザー作業と思われる差分が混ざっている。
- コミットメッセージの意図が一意に決まらない。

## コミットメッセージ

Conventional Commit 形式を使う。

```text
type: :emoji: 日本語の簡潔な説明
```

例:

```text
feat: :sparkles: ユーザー設定画面を追加
fix: :bug: 設定保存時の例外を修正
change: :wrench: コミット手順を更新
```

type の前に emoji は置かない。`feat:` / `fix:` などを先頭に置き、Conventional Commit パーサーと相性を保つ。emoji は GitHub などで表示しやすい shortcode 形式で書く。

### 使用する type

- `init: :tada:` 初回コミット、初期構成
- `feat: :sparkles:` 機能追加
- `fix: :bug:` バグ修正
- `change: :wrench:` 既存挙動や設定の変更
- `remove: :fire:` 削除
- `docs: :memo:` ドキュメントのみ
- `refactor: :recycle:` 挙動を変えないコード整理
- `chore: :bricks:` 設定、依存、メタ作業など分類しづらい保守作業
- `revert: :rewind:` 取り消しコミット

`feat` と `fix` は Conventional Commits 仕様上の主要 type。その他の type は仕様上許容される。`docs`、`chore`、`revert` は Angular 系の慣習でもよく使われるため採用する。

## 禁止事項

- 確認スクリプトを実行せずにコミットしない。
- 確認なしに `main` / `master` へコミットしない。
- ユーザーが明示していない変更を戻さない。
- 確認スクリプトに `git add`、`git commit`、破壊的操作を入れない。
