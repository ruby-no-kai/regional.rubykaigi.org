# `_data/` の構成

- `events.yml`: 過去に追加されたイベントの記録です。**新しい開催をここには追加しません。**
- `events_added_on.yml`: `events.yml` の各エントリが実際にサイトへ追加された日付のキャッシュです。`events.yml` は複数エントリが同居する共有ファイルのため、個々のエントリの追加日を git 履歴から直接（安く）読み取れません。`script/update_events_added_on.rb` で手動更新します。通常は編集不要です。
- `kaigis/`: 新しいイベントを1開催1ファイルで追加する場所です。開催情報の追加手順は [CONTRIBUTING.md](../CONTRIBUTING.md) を参照してください。`COPYME.yml.example` をコピーして使います。
- `og_image.yml`: OGP画像の再生成が必要かどうかを判定するための内部データです。手動で編集する必要はありません。

サイトの一覧ページには、`events.yml` と `kaigis/` の両方の内容が統合されて表示されます。
