# data/ ディレクトリ

## 📂 ファイル構成

### fcf_input.csv（FCF入力データ）
**目的**: 月次のFCF計算用の原本データ

**記入者**: CEO（社長）  
**更新頻度**: 月1回  
**保守**: Git管理

---

## 📋 fcf_input.csv フォーマット

```csv
month,app_name,sales,apple_fee,external_cost,tool_cost,tax
2026-01,Dose Note,12000,3600,0,500,1200
```

### カラム定義

| 列名 | 内容 | 単位 |
|---|---|---|
| month | 対象月 | YYYY-MM |
| app_name | アプリ名 | 文字列 |
| sales | 売上 | 円 |
| apple_fee | Apple手数料（30%） | 円 |
| external_cost | 外注費 | 円 |
| tool_cost | ツール費用 | 円 |
| tax | 税金 | 円 |

---

## ✍️ 記入方法（社長向け）

### 月末にやること
1. App Store Connectで売上確認
2. fcf_input.csvに1行追加
3. Copilotに「今月のFCFレビューを実行してください」と指示

**それだけです。5分で終わります。**

---

## 🤖 AI処理（自動）

社長が指示すると、AIが以下を自動実行：
1. FCF計算（`FCF = sales - (apple_fee + external_cost + tool_cost + tax)`）
2. 月別・アプリ別集計
3. 前月比・3ヶ月平均算出
4. `docs/FCF_REPORT.md` 生成
5. `docs/CEO_DASHBOARD.md` のFCF欄を更新
6. 判断が必要な事項のみCEOに提示

---

## 🔒 データ管理ルール

- **原本**: data/fcf_input.csv
- **Git管理**: 必須（履歴を残す）
- **公開範囲**: プライベートリポジトリのみ
- **バックアップ**: Gitが自動保管
- **修正**: 過去データの修正も可能（履歴に残る）

---

## 注意事項

- 空欄は「0」として扱われます
- 人件費は含めません（会社OS仕様）
- 複数アプリがある場合は行を追加してください
