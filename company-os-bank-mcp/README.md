# 🏦 会社OS 銀行API連携サーバー (MCP)

GMO青空ネット銀行のAPI（Sunabar環境）に接続し、残高や明細を取得するMCPサーバーです。

## セットアップ手順

### 1. 環境変数の設定
`company-os-bank-mcp` ディレクトリにある `.env.template` を `.env` にリネーム（複製）し、Sunabarの情報を入力してください。

```bash
cp .env.template .env
```

**入力項目:**
- `SUNABAR_USER_ID`: SunabarポータルにログインするID
- `SUNABAR_PASSWORD`: Sunabarポータルにログインするパスワード
- その他の項目は、APIを利用するためのアプリケーション登録後に取得します。

### 2. インストール

```bash
cd company-os-bank-mcp
pip install -r requirements.txt
```

### 3. アプリケーション登録 (APIキー発行)
Sunabarポータルにログインし、テスト用のアプリケーションを作成して `CLIENT_ID` と `CLIENT_SECRET` を取得する必要があります。
（詳細な手順はポータルサイトを参照してください）
