# 🏦 銀行API連携仕様書 (Bank API Integration Spec)

**関連判断**: DEC-2026-02-06-01  
**連携先**: GMOあおぞらネット銀行  
**目的**: FCF（フリーキャッシュフロー）入力の完全自動化

---

## 1. 概要
本プロジェクトでは、GMOあおぞらネット銀行のAPI（Sunabarおよび本番API）を利用し、入出金明細を自動取得するシステムを構築する。  
取得したデータは「会社OS」のMCP (Model Context Protocol) サーバーを通じて、Copilotから直接参照・集計可能にする。

---

## 2. API接続要件
- **利用API**: GMOあおぞらネット銀行API
- **契約形態**: プライベートアクセス（自社利用）
- **認証**: OAuth 2.0 (Authorization Code Flow / Client Credentials Flow)
- **SDK**: 公式Python SDK (`gmo-aozora-api-python`) を使用

---

## 3. システム構成

### MCPサーバー (`company-os-bank-mcp`)
- **機能**:
  - `get_balance()`: 口座残高の取得
  - `get_transactions(from_date, to_date)`: 指定期間の入出金明細取得
  - `generate_fcf_report(month)`: 指定月のFCF暫定レポート生成
- **実行環境**: ローカル (macOS) / コンテナ (将来的)

### データフロー
1. ユーザー (CEO) が Copilot に「今月のキャッシュフローは？」と質問
2. Copilot が MCP ツール `get_fcf_status` を呼び出し
3. MCPサーバーが銀行APIから最新明細を取得
4. 既知の固定費・変動費タグに基づいて明細を分類（売上、サーバー費、報酬など）
5. 集計結果をCopilotに返却し、レポート形式で回答

---

## 4. 開発ステップ

### Step 1: 環境構築 (Sunabar)
- [ ] Sunabarアカウント登録（CEO）
- [ ] Python仮想環境セットアップ
- [ ] 公式SDKインストール

### Step 2: 接続テスト
- [ ] アクセストークン取得スクリプト作成
- [ ] 残高照会テスト
- [ ] 入出金明細照会テスト

### Step 3: MCPサーバー実装
- [ ] MCPサーバーのボイラープレート作成
- [ ] ツール定義 (`get_account_balance`, `get_transactions`)
- [ ] エラーハンドリング（トークン切れ時の再認証など）

### Step 4: 会社OS統合
- [ ] `FCF_REPORT.md` 生成ロジックの実装
- [ ] `data/fcf_input.csv` への自動追記モード実装

---

## 5. セキュリティ
- **クレデンシャル管理**:
  - アクセストークン、クライアントID等は環境変数 (`.env`) で管理
  - `.env` は `.gitignore` に含め、リポジトリにコミットしない
- **アクセス制限**:
  - 参照系APIのみ使用（振込等の更新系APIは使用しない）

---

## 6. 運用フロー（After）
1. 月末、CEOがCopilotに「今月のFCFを確定して」と指示
2. Copilotが銀行APIから明細を取得
3. Copilotが「以下の内容で `data/fcf_input.csv` を更新しますか？」と提案
4. 承認後、ファイル更新＆ `FCF_REPORT.md` 生成
