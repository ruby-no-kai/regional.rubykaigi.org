# Contributing

地域Ruby会議の開催情報の追加、リンク切れの修正、過去サイトの保全などへの協力を歓迎します 🥰

## 開催情報を追加する

`_data/events.yml` の末尾に、開催日の順でエントリーを追加してください。

```yaml
- name: example01
  title: "〇〇Ruby会議01"
  start_on: 2027-01-23
  end_on: 2027-01-23
  external_url: https://example.org/
```

各項目の意味は次のとおりです。

- `name`（必須）: イベントを識別する、小文字英数字からなる一意な名前
- `title`（必須）: 一覧に表示する正式名称
- `start_on`（必須）: 開催初日。`YYYY-MM-DD` 形式
- `end_on`（必須）: 開催最終日。1日開催でも省略しない
- `external_url`（任意）: 別の場所で公開している公式サイト
- `report_url`（任意）: 開催レポート

複数日開催では `start_on` と `end_on` にそれぞれ初日と最終日を指定します。

### 外部サイトを使う場合（現代ではこちらが主流です）

`external_url` に公式サイトのHTTPS URLを指定してください。

### regional.rubykaigi.orgでサイトを公開する場合（歴史的経緯からサポートしています）

`external_url` を省略し、リポジトリのルートに `name` と同名のディレクトリを作成します。
その直下に `index.html` と必要な画像・CSS・JavaScriptを配置してください。

```text
example01/
├── index.html
├── images/
└── stylesheets/
```

画像やCSSなどはイベントのディレクトリ内に配置し、リンク切れがないことを確認してください。

### 開催レポートを追加する

るびま（Rubyist Magazine）に開催レポートが掲載されたら、`report_url` にそのURLを追加してください。

## イベントデータの検証

Pull Requestを作成する前に、次のコマンドを実行してください。

```console
ruby script/validate_events.rb
```
