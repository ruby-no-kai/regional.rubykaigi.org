# Contributing

地域Ruby会議の開催情報の追加、リンク切れの修正、過去サイトの保全などへの協力を歓迎します 🥰

## 開催情報を追加するには

`_data/kaigis/COPYME.yml.example` をコピーし、開催回の識別子をファイル名にして `_data/kaigis/` に追加してください（例: `okrk04.yml`）。識別子は小文字英数字にし、既存の回と重複しないようにしてください。regional.rubykaigi.org上のURLの一部としても使われます。

```yaml
title: "〇〇Ruby会議01"
held_on: 2027-01-23
external_url: https://example.org/
```

各項目の意味は次のとおりです。

- `title`（必須）: 一覧に表示する正式名称
- `held_on`（単日開催の場合は必須）: 開催日。`YYYY-MM-DD` 形式
- `start_on`・`end_on`（複数日開催の場合は必須）: 開催初日・最終日。`held_on` の代わりにこの2つを使う
- `name`（任意）: イベントを識別する小文字英数字の名前。省略するとファイル名がそのまま識別子になる。書く場合はファイル名と一致させる
- `external_url`（任意）: 別の場所で公開している公式サイト
- `report_url`（任意）: 開催レポート。"任意"というのは項目の指定が任意という意味で、開催レポートの投稿が任意という意味ではありません!!!

### 外部サイトでページをホストする場合

regional.rubykaigi.org(rrk.org)ではないドメインに転送したい場合は、`external_url` に公式サイトのHTTPS URLを指定してください。

外部リポジトリ(地域RubyコミュニティのGitHub Pagesなど)でページを公開するけれども、URLとしては `https://regional.rubykaigi.org/#{your_kaigi_name}` のようなサブディレクトリとして公開したい場合は、次のセクションを参考にしてください。

### rrk.org上のURLでサイトを公開する場合

`external_url` を省略します。この場合の公開方法は2通りあります。

#### このリポジトリにサイトを置く（歴史的経緯からサポートしています）

リポジトリのルートに開催回の識別子（ファイル名、または明示した `name`）と同名のディレクトリを作成します。
その直下に `index.html` と必要な画像・CSS・JavaScriptを配置してください。

```text
example01/
├── index.html
├── images/
└── stylesheets/
```

画像やCSSなどはイベントのディレクトリ内に配置し、リンク切れがないことを確認してください。

#### 外部リポジトリにサイトを置く（GitHub Pagesなど）

自分のGitHubリポジトリでGitHub Pages（カスタムドメインの設定は不要）を用意し、[ruby-no-kai/rko-router](https://github.com/ruby-no-kai/rko-router) にプロキシ設定を追加するPRを送ってください。手順は rko-router の README（Quick Reference > Add regional.rubykaigi.org subdirectory）に従ってください。

この方法では、このリポジトリ（ruby-no-kai/regional.rubykaigi.org）へのPRとは別に、rko-router側へのPRも必要になります。このリポジトリへのPull Requestでは `_data/kaigis/` にファイルを追加するだけで、`index.html` などは不要です。

### RSSフィードへの掲載

`_data/kaigis/`に追加したファイルは、そのPRがマージされた時点で自動的に[index.rss](https://regional.rubykaigi.org/index.rss)に載ります。書き加える項目はありません——掲載日はファイルがリポジトリに追加された日から自動的に決まります。`_data/events.yml`側の（歴史的経緯で残っている）既存イベントは対象外です。

### 開催レポートを追加する

るびま（Rubyist Magazine）に開催レポートが掲載されたら、`report_url` にそのURLを追加してください。

## イベントデータの検証

Pull Requestを作成する前に、次のコマンドを実行してください。

```console
ruby script/validate_kaigis.rb
```
