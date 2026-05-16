---
name: codex-usage
description: Codex の利用状況や API 従量課金換算を `@ccusage/codex` で確認するときに使う。日別・月別・セッション別の集計、期間指定、JSON 出力、最近の使用傾向の確認に使う。
---

# Codex Usage

`@ccusage/codex` を使って、利用状況を集計する。

## スコープ

- このスキルは `@ccusage/codex` の標準出力または `--json` 出力だけを扱う
- スキルを読んだエージェントが `.codex/` 配下の生ファイルや履歴を直接読んで独自解析することはしない
- 独自解析が必要な要望はいったんスコープ外として扱う

## 出力方針

- まず `@ccusage/codex` の出力に忠実であることを優先する
- ユーザーに頼まれていない要約、順位付け、重要度判断、勝手な抜粋はしない
- 月別なら月別の結果をその順で示し、日別なら日別の結果をその順で示す
- 「上位だけ」「重い日だけ」「重要なところだけ」は、ユーザーが明示したときだけ行う
- 補助スクリプトで再集計する場合も、既定では並べ替えや圧縮を最小限にする

## 使いどころ

- 「今月どれくらい使ったか」を見たい
- API 従量課金ならいくら相当かを見たい
- 日別・月別・セッション別の偏りを確認したい
- 直近 7 日 / 30 日などの利用傾向を出したい
- 後で加工できるように JSON で取りたい
- 使えるオプションを先に確認したい

## このスキルで扱う範囲

- 対応: `monthly`、`daily`、`session`、`--help`、`--json`
- 対応: モデル別内訳の再集計
- 標準フロー: `monthly` を実行し、今月は `daily --since YYYY-MM-01` を実行する
- 非対応: リポジトリ別集計
- 非対応: `.codex` 生ログの直接解析

`@ccusage/codex` の標準出力と `session --json` では、少なくともそのまま使えるリポジトリ識別子は出てこない。リポジトリ別集計のように生ログ解析が必要なものは、このスキルでは扱わない。

## 前提

- `npx @ccusage/codex@latest` が実行できること
- ローカルに Codex のセッションログがあること
- 価格表の更新が不要なら `--offline` を使う

## 標準手順

1. まず月別集計を実行する
2. 次に当月の初日を `YYYY-MM-01` で求める
3. 当月初日を `--since` に指定して日別集計を実行する
4. 必要なら `session` や `--json` で追加調査する

## 基本コマンド

ラッパースクリプトを優先して使う。

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh monthly --noColor
```

直接実行する場合:

```sh
npx @ccusage/codex@latest monthly --noColor
```

### オプション確認

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh monthly --help
bash ./.agents/skills/codex-usage/scripts/report.sh daily --help
bash ./.agents/skills/codex-usage/scripts/report.sh session --help
```

## よく使う例

### 月別

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh monthly --noColor
```

### 日別

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh daily --noColor
```

### セッション別

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh session --noColor
```

### 期間指定

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh monthly --since 2026-03-01 --until 2026-03-31 --noColor
```

### 今月の日別

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh daily --since 2026-03-01 --noColor
```

### JSON 出力

```sh
bash ./.agents/skills/codex-usage/scripts/report.sh monthly --json --since 2026-01-01
```

### モデル別集計

月別・日別・セッション別の `@ccusage/codex --json` 出力をモデルごとに再集計する。

```sh
bash ./.agents/skills/codex-usage/scripts/model_breakdown.sh monthly
```

```sh
bash ./.agents/skills/codex-usage/scripts/model_breakdown.sh monthly --since 2026-03-01
```

```sh
bash ./.agents/skills/codex-usage/scripts/model_breakdown.sh daily --since 2026-03-01
```

## 運用メモ

- まず `--help` で使えるオプションを確認してよい
- まず `monthly` で全体感を見る
- 今月については `daily --since YYYY-MM-01` を必ず実行する
- 次に必要なら `daily` をそのまま提示する
- 必要なら `session` で重いセッションを掘る
- モデル構成を見たいときは `model_breakdown.sh` を使う
- 再現性を優先するなら `--offline` を付ける
- 金額は推定値で、実課金額そのものではない

## 読み取りの指針

- 大きい月を見つけたら、その月だけ `daily --since ... --until ...` で掘る
- 合計金額の微差は価格表の更新タイミングで起こりうる
- モデル名が混在している月は、モデル更新や fallback を疑う
