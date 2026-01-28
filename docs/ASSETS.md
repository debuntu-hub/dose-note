# 🧰 再利用可能資産一覧（ASSETS）

**目的**: 停止・売却したアプリから抽出した再利用可能な資産を管理する

**基本思想**: アプリは失敗しても失敗させない。止めた＝損ではない。再利用できた時点で勝ち。

---

## 📋 資産分類

### 1. コード資産
実装済みのコードで、次のアプリに流用可能なもの

### 2. 仕様・設計資産
PRD/SRS/仕様書で、設計思想や判断プロセスが再利用可能なもの

### 3. 運用ノウハウ
App Store審査、課金設定、マーケティングなどの知見

---

## 💾 Dose Note の資産

### コード資産

#### #billing（課金処理）
- **内容**: StoreKit 2 を使った月額・年額サブスクリプション実装
- **ファイル**: `StoreManager.swift`
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（ほぼ全アプリで使える）
- **タグ**: `#billing` `#storekit2` `#subscription`

#### #persistence（データ永続化）
- **内容**: UserDefaults を使ったシンプルなローカル保存
- **ファイル**: `DoseStore.swift`
- **再利用度**: ⭐️⭐️⭐️⭐️（小規模データ管理に有効）
- **タグ**: `#persistence` `#userdefaults` `#local_storage`

#### #calendar_ui（カレンダーUI）
- **内容**: SwiftUIのDatePickerを使った履歴カレンダー表示
- **ファイル**: `CalendarView.swift`
- **再利用度**: ⭐️⭐️⭐️⭐️（日付ベースのアプリで有効）
- **タグ**: `#calendar_ui` `#swiftui` `#date_picker`

#### #premium_gate（Freemium制御）
- **内容**: Free/Premium機能の分離とロック画面UI
- **ファイル**: `ContentView.swift`, `PaywallView.swift`
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（Freemiumアプリ必須）
- **タグ**: `#premium_gate` `#freemium` `#paywall`

#### #stats_calculation（統計計算）
- **内容**: 平均間隔・集計ロジックの実装パターン
- **ファイル**: `DoseStore.swift`内の計算メソッド
- **再利用度**: ⭐️⭐️⭐️（記録系アプリで有効）
- **タグ**: `#stats_calculation` `#aggregation`

---

### 仕様・設計資産

#### #freemium_design（Freemium設計思想）
- **内容**: Free版とPremium版の機能分離設計
- **文書**: `docs/SRS.md` - 各機能の区分定義
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（全Freemiumアプリで適用可）
- **学び**: 
  - Free版は「使える」けど「物足りない」状態にする
  - Premium機能は「あると嬉しい」ではなく「ないと困る」レベルにする
  - 30日制限はちょうどいい誘導ライン
- **タグ**: `#freemium_design` `#pricing_strategy`

#### #edge_case_spec（境界条件の仕様化）
- **内容**: 記録1件のみの場合の統計計算など、エッジケースを明文化する重要性
- **文書**: `docs/SRS.md` - 5章 集計ロジック（境界条件含む）
- **再利用度**: ⭐️⭐️⭐️⭐️（すべてのアプリで適用可）
- **学び**: 
  - エッジケースは実装前に仕様化する
  - 判断をコードではなく文書で行う
  - CEO判断が必要な境界条件は必ず記録する
- **タグ**: `#edge_case_spec` `#boundary_condition`

#### #disclaimer_template（免責文テンプレート）
- **内容**: 医療系・健康系アプリの免責文
- **文書**: `docs/SRS.md` - 7章 非機能要件（免責事項）
- **再利用度**: ⭐️⭐️⭐️⭐️（医療系アプリで必須）
- **文面**: 「本アプリは○○を記録・管理するためのツールです。医療行為、診断、治療を目的としたものではありません。」
- **タグ**: `#disclaimer_template` `#legal` `#health_app`

#### #gate_system（Gate制御システム）
- **内容**: 企画→仕様→実装の各Gateで品質を担保する仕組み
- **文書**: `docs/会社OS.md` - 6章 品質ゲート
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（すべてのアプリ開発で適用可）
- **学び**: 
  - Gate未達で次工程へ進まない
  - 手戻り時は原因を分類する
  - 実装前に仕様を固める
- **タグ**: `#gate_system` `#quality_control`

---

### 運用ノウハウ

#### #appstore_review（App Store審査フロー）
- **内容**: 初回申請から承認までのプロセス
- **文書**: `docs/CEO_DASHBOARD.md` - Task 502-503
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（全アプリで必要）
- **ノウハウ**: 
  - スクリーンショットサイズ（6.7/6.5/5.5インチ）
  - Archive → Distribute App の手順
  - TestFlight経由が確実
- **タグ**: `#appstore_review` `#app_submission`

#### #subscription_setup（課金審査通過パターン）
- **内容**: サブスクリプション設定と審査対応
- **文書**: なし（今後追加）
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（課金アプリ必須）
- **ノウハウ**: 
  - StoreKit 2 は審査が通りやすい
  - Debug時の「無料でアンロック」ボタンは有効
  - 復元機能は必須
- **タグ**: `#subscription_setup` `#storekit`

#### #fcf_management（FCF管理運用）
- **内容**: CSV入力→AI集計の半自動化運用
- **文書**: `docs/会社OS.md` - 13.5章
- **再利用度**: ⭐️⭐️⭐️⭐️⭐️（全事業で適用可）
- **ノウハウ**: 
  - 月1回のCSV入力（5分で完了）
  - AIに「今月のFCFレビューを実行」指示するだけ
  - 会計ソフト連携は後回し（初期は不要）
- **タグ**: `#fcf_management` `#automation`

---

## 🗂 アーカイブ構造

停止・売却したアプリは以下の構造で保管する。

```
archive/
 └─ dose-note/
     ├─ code/（ソースコード一式）
     ├─ specs/（PRD/SRS/DECISIONS）
     ├─ data/（fcf_input.csvなどの実績データ）
     └─ ASSETS.md（このアプリから得られた資産のまとめ）
```

**重要**: 消さない・凍結する。これが正解。

---

## 🔖 再利用タグ一覧

以下のタグで資産を素早く検索可能にする。

### コード系
- `#billing` - 課金処理
- `#persistence` - データ永続化
- `#calendar_ui` - カレンダーUI
- `#premium_gate` - Freemium制御
- `#stats_calculation` - 統計計算
- `#storekit2` - StoreKit 2
- `#swiftui` - SwiftUI実装

### 仕様・設計系
- `#freemium_design` - Freemium設計
- `#edge_case_spec` - 境界条件仕様
- `#disclaimer_template` - 免責文
- `#gate_system` - Gate制御
- `#quality_control` - 品質管理

### 運用系
- `#appstore_review` - App Store審査
- `#subscription_setup` - 課金設定
- `#fcf_management` - FCF管理
- `#automation` - 自動化

---

## 📝 資産追加ルール

1. **アプリ停止時**: 必ず資産を棚卸しして記録する
2. **売却前**: 買い手に渡す資産と残す資産を分類する
3. **新アプリ開始時**: ここから再利用可能な資産を検索する
4. **Git管理**: 必須（資産は会社の財産）

---

## 💡 再利用の考え方

### 完璧なコピペは不要
- コードは「そのまま使える状態」より「見つけられる状態」が重要
- タグで検索して、参考にしながら実装する

### 失敗も資産
- FCFがマイナスで止めたアプリでも、コード・仕様・ノウハウは残る
- 「やめた＝損」ではない。再利用できた時点で勝ち。

### 次のアプリで活かす
- 「#billing」って言えば課金処理が再利用できる状態にする
- 次のアプリ開発時間を1/3に短縮できる

---

**関連文書**:
- [会社OS.md](./会社OS.md) - アプリ停止・資産化ルール
- [FEATURES.md](./FEATURES.md) - 機能定義（停止前に必ず更新）
- [CEO_DASHBOARD.md](./CEO_DASHBOARD.md) - 停止・資産化ステータス
