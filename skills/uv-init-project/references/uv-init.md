# uv プロジェクト初期化

`uv init` を使って Python プロジェクトを初期化する手順をまとめます。

## 事前確認

- uv コマンドが見つからない場合はユーザーに確認する。

## 1. 新規プロジェクトを作成する

初期化したいディレクトリに移動して以下のコマンドを実行する

```shell
uv init .
```

- `uv init . --python 3.14` のように、pythonのバージョンを指定することも可能

## 2. 生成物の確認

初期化が完了すると、`pyproject.toml` や `.python-version`、などがが作成されます。想定どおりのファイルが生成されているか確認してください。

## 3. pyproject.toml の初期設定

依存パッケージを追加するときにバージョンの上限を自動付与したいので`pyproject.toml` に次の設定を追記します。

```toml
[tool.uv]
add-bounds = "major"
```

依存パッケージの公開直後を避けたい場合は、uv の dependency cooldowns として `exclude-newer` も設定できます。duration を指定すると、指定期間より新しい公開物を解決対象から外せます。

```toml
[tool.uv]
add-bounds = "major"
exclude-newer = "7 days"
```

- `exclude-newer = "7 days"` は直近 7 日以内に公開された依存を避けたいときの例
- より細かく制御したい場合は `exclude-newer-package` でパッケージごとの指定も可能

## パッケージ管理方法をプロジェクトのAGENTS.mdに追記

`uv-manage-dependencies` スキルの `references/uv-manage-dependencies.md` の内容をプロジェクトのAGENTS.mdに追記する
