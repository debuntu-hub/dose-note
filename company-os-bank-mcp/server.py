"""
GMO Aozora Bank MCP Server
会社OS用の銀行API連携MCPサーバー

提供ツール:
- get_account_balance: 口座残高を取得
- get_transactions: 入出金明細を取得（期間指定可能）
- get_monthly_summary: 月次サマリー（FCF分析用）
- generate_fcf_data: FCF入力データの自動生成（App Store入金識別）
- analyze_cash_flow: 大きな入出金の検知・アラート
- get_all_accounts: 全口座一覧取得（複数口座対応）
"""
import os
import json
from datetime import datetime, timedelta
from typing import Optional
import requests
from dotenv import load_dotenv
from mcp.server import Server
from mcp.types import Tool, TextContent

# 環境変数読み込み
load_dotenv()

ACCESS_TOKEN = os.getenv("ACCESS_TOKEN")
BASE_URL = "https://api.sunabar.gmo-aozora.com/personal/v1"
ACCOUNT_ID = os.getenv("ACCOUNT_ID", "301010012027")  # デフォルト値を設定

# MCPサーバー初期化
server = Server("gmo-aozora-bank")

def call_api(endpoint: str) -> dict:
    """銀行APIを呼び出す共通関数"""
    url = f"{BASE_URL}{endpoint}"
    headers = {
        "x-access-token": ACCESS_TOKEN,
        "accept": "application/json;charset=UTF-8"
    }
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

@server.list_tools()
async def list_tools() -> list[Tool]:
    """利用可能なツール一覧"""
    return [
        Tool(
            name="get_account_balance",
            description="GMO青空ネット銀行の口座残高を取得します。現在の残高、前日残高、前月残高が確認できます。",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="get_transactions",
            description="指定期間の入出金明細を取得します。デフォルトでは直近30日分の明細を取得します。",
            inputSchema={
                "type": "object",
                "properties": {
                    "days": {
                        "type": "number",
                        "description": "過去何日分の明細を取得するか（デフォルト: 30日）",
                        "default": 30
                    }
                },
                "required": []
            }
        ),
        Tool(
            name="get_monthly_summary",
            description="指定月の入出金サマリーを取得します。FCF（フリーキャッシュフロー）分析に使用します。",
            inputSchema={
                "type": "object",
                "properties": {
                    "year": {
                        "type": "number",
                        "description": "年（例: 2026）。省略時は今年"
                    },
                    "month": {
                        "type": "number",
                        "description": "月（1-12）。省略時は今月"
                    }
                },
                "required": []
            }
        ),
        Tool(
            name="generate_fcf_data",
            description="指定月の銀行取引データからFCF入力データを自動生成します。App Store入金を識別し、手数料30%を自動計算します。",
            inputSchema={
                "type": "object",
                "properties": {
                    "year": {
                        "type": "number",
                        "description": "年（例: 2026）。省略時は今年"
                    },
                    "month": {
                        "type": "number",
                        "description": "月（1-12）。省略時は今月"
                    },
                    "app_name": {
                        "type": "string",
                        "description": "アプリ名（例: 'Dose Note'）。省略時は自動検出を試みる",
                        "default": "Dose Note"
                    }
                },
                "required": []
            }
        ),
        Tool(
            name="analyze_cash_flow",
            description="指定期間の資金移動を分析し、大きな入出金や異常なパターンを検知します。アラート閾値を設定可能。",
            inputSchema={
                "type": "object",
                "properties": {
                    "days": {
                        "type": "number",
                        "description": "過去何日分を分析するか（デフォルト: 30日）",
                        "default": 30
                    },
                    "alert_threshold": {
                        "type": "number",
                        "description": "アラートを出す金額閾値（円）。この金額以上の入出金を報告（デフォルト: 10000円）",
                        "default": 10000
                    }
                },
                "required": []
            }
        ),
        Tool(
            name="get_all_accounts",
            description="GMO青空ネット銀行の全口座一覧を取得します。複数口座を管理している場合に使用します。",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """ツール実行"""
    
    if not ACCESS_TOKEN:
        return [TextContent(
            type="text",
            text="❌ エラー: ACCESS_TOKENが設定されていません。.envファイルを確認してください。"
        )]
    
    try:
        if name == "get_account_balance":
            # 残高照会
            data = call_api("/accounts/balances")
            
            if not data.get("balances"):
                return [TextContent(type="text", text="口座情報が見つかりませんでした。")]
            
            balance_info = data["balances"][0]
            
            result = f"""💰 口座残高情報

📊 基本情報:
- 口座ID: {balance_info['accountId']}
- 口座種別: {balance_info['accountTypeName']}
- 基準日時: {balance_info['baseDate']} {balance_info['baseTime']}

💵 残高:
- 現在残高: {int(balance_info['balance']):,}円
- 出金可能額: {int(balance_info['withdrawableAmount']):,}円
- 前日残高: {int(balance_info['previousDayBalance']):,}円
- 前月残高: {int(balance_info['previousMonthBalance']):,}円
"""
            return [TextContent(type="text", text=result)]
        
        elif name == "get_transactions":
            # 入出金明細取得
            days = arguments.get("days", 30)
            
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            date_from = start_date.strftime("%Y-%m-%d")
            date_to = end_date.strftime("%Y-%m-%d")
            
            endpoint = f"/accounts/{ACCOUNT_ID}/transactions?dateFrom={date_from}&dateTo={date_to}"
            data = call_api(endpoint)
            
            transactions = data.get("transactions", [])
            
            if not transactions:
                return [TextContent(type="text", text=f"📭 {date_from} 〜 {date_to} の期間に取引はありませんでした。")]
            
            result = f"📜 入出金明細（{date_from} 〜 {date_to}）\n\n"
            result += f"取引件数: {len(transactions)}件\n\n"
            
            for i, tx in enumerate(transactions[:20], 1):  # 最大20件表示
                tx_date = tx.get('transactionDate', '')
                amount = int(tx.get('amount', 0))
                balance_after = int(tx.get('balance', 0))
                description = tx.get('remarks', tx.get('transactionTypeName', ''))
                
                result += f"{i}. {tx_date}\n"
                result += f"   金額: {amount:+,}円\n"
                result += f"   残高: {balance_after:,}円\n"
                result += f"   摘要: {description}\n\n"
            
            if len(transactions) > 20:
                result += f"... 他 {len(transactions) - 20}件\n"
            
            return [TextContent(type="text", text=result)]
        
        elif name == "get_monthly_summary":
            # 月次サマリー
            now = datetime.now()
            year = arguments.get("year", now.year)
            month = arguments.get("month", now.month)
            
            # 月初〜月末
            start_date = datetime(year, month, 1)
            if month == 12:
                end_date = datetime(year + 1, 1, 1) - timedelta(days=1)
            else:
                end_date = datetime(year, month + 1, 1) - timedelta(days=1)
            
            date_from = start_date.strftime("%Y-%m-%d")
            date_to = end_date.strftime("%Y-%m-%d")
            
            endpoint = f"/accounts/{ACCOUNT_ID}/transactions?dateFrom={date_from}&dateTo={date_to}"
            data = call_api(endpoint)
            
            transactions = data.get("transactions", [])
            
            # 集計
            total_in = 0
            total_out = 0
            
            for tx in transactions:
                amount = int(tx.get('amount', 0))
                if amount > 0:
                    total_in += amount
                else:
                    total_out += abs(amount)
            
            net_flow = total_in - total_out
            
            result = f"""📊 {year}年{month}月 資金移動サマリー

💰 収入（入金）: {total_in:,}円
💸 支出（出金）: {total_out:,}円
━━━━━━━━━━━━━━━
📈 純キャッシュフロー: {net_flow:+,}円

取引件数: {len(transactions)}件

⚠️  注意: これは銀行口座の入出金記録です。
FCF計算には、以下の作業が必要です:
1. 売上の特定（App Store入金など）
2. 経費の分類（手数料、外注費など）
3. data/fcf_input.csv への入力
"""
            return [TextContent(type="text", text=result)]
        
        elif name == "generate_fcf_data":
            # FCF入力データ自動生成
            now = datetime.now()
            year = arguments.get("year", now.year)
            month = arguments.get("month", now.month)
            app_name = arguments.get("app_name", "Dose Note")
            
            # 月初〜月末の取引取得
            start_date = datetime(year, month, 1)
            if month == 12:
                end_date = datetime(year + 1, 1, 1) - timedelta(days=1)
            else:
                end_date = datetime(year, month + 1, 1) - timedelta(days=1)
            
            date_from = start_date.strftime("%Y-%m-%d")
            date_to = end_date.strftime("%Y-%m-%d")
            
            endpoint = f"/accounts/{ACCOUNT_ID}/transactions?dateFrom={date_from}&dateTo={date_to}"
            data = call_api(endpoint)
            
            transactions = data.get("transactions", [])
            
            # App Store入金を識別
            app_store_income = 0
            other_income = 0
            expenses = 0
            app_store_transactions = []
            
            for tx in transactions:
                amount = int(tx.get('amount', 0))
                remarks = tx.get('remarks', '').lower()
                
                # App Store入金の識別（摘要に"apple"、"app store"、"itunes"などが含まれる）
                if amount > 0:
                    if any(keyword in remarks for keyword in ['apple', 'app store', 'appstore', 'itunes', 'app ストア']):
                        app_store_income += amount
                        app_store_transactions.append({
                            'date': tx.get('transactionDate'),
                            'amount': amount,
                            'remarks': tx.get('remarks')
                        })
                    else:
                        other_income += amount
                else:
                    expenses += abs(amount)
            
            # Apple手数料計算（30%）
            apple_fee = int(app_store_income * 0.3)
            
            # FCF計算
            fcf = app_store_income - apple_fee - expenses
            
            result = f"""📊 {year}年{month}月 FCF入力データ（自動生成）

🍎 App Store売上分析:
"""
            
            if app_store_transactions:
                result += f"- App Store入金: {app_store_income:,}円（{len(app_store_transactions)}件検出）\n"
                for tx in app_store_transactions:
                    result += f"  └ {tx['date']}: {tx['amount']:,}円 ({tx['remarks']})\n"
            else:
                result += f"- App Store入金: 0円（検出されませんでした）\n"
            
            result += f"\n💰 その他の入金: {other_income:,}円\n"
            result += f"💸 支出合計: {expenses:,}円\n"
            result += f"\n📋 FCF計算:\n"
            result += f"- 売上（sales）: {app_store_income:,}円\n"
            result += f"- Apple手数料（apple_fee）: {apple_fee:,}円（30%）\n"
            result += f"- 外注費（external_cost）: 0円\n"
            result += f"- ツール費（tool_cost）: {expenses:,}円\n"
            result += f"- 税金（tax）: 0円\n"
            result += f"━━━━━━━━━━━━━━━\n"
            result += f"💵 FCF: {fcf:,}円\n\n"
            
            # CSV行の生成
            month_str = f"{year}-{month:02d}"
            csv_line = f"{month_str},{app_name},{app_store_income},{apple_fee},0,{expenses},0"
            
            result += f"📝 data/fcf_input.csv に追加する行:\n"
            result += f"```csv\n{csv_line}\n```\n\n"
            result += f"⚠️  注意事項:\n"
            result += f"1. App Store入金が0円の場合、摘要の識別パターンを確認してください\n"
            result += f"2. 外注費・税金は手動で修正してください\n"
            result += f"3. ツール費は支出合計から自動設定されていますが、要確認です\n"
            result += f"4. この行をコピーして fcf_input.csv に追加してください\n"
            
            return [TextContent(type="text", text=result)]
        
        elif name == "analyze_cash_flow":
            # 資金移動分析・アラート
            days = arguments.get("days", 30)
            alert_threshold = arguments.get("alert_threshold", 10000)
            
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            date_from = start_date.strftime("%Y-%m-%d")
            date_to = end_date.strftime("%Y-%m-%d")
            
            endpoint = f"/accounts/{ACCOUNT_ID}/transactions?dateFrom={date_from}&dateTo={date_to}"
            data = call_api(endpoint)
            
            transactions = data.get("transactions", [])
            
            # 大きな取引を抽出
            large_deposits = []
            large_withdrawals = []
            
            for tx in transactions:
                amount = int(tx.get('amount', 0))
                if abs(amount) >= alert_threshold:
                    tx_info = {
                        'date': tx.get('transactionDate'),
                        'amount': amount,
                        'remarks': tx.get('remarks', ''),
                        'balance_after': int(tx.get('balance', 0))
                    }
                    
                    if amount > 0:
                        large_deposits.append(tx_info)
                    else:
                        large_withdrawals.append(tx_info)
            
            result = f"""🔍 資金移動分析レポート（{date_from} 〜 {date_to}）

📊 基本統計:
- 分析期間: {days}日間
- 総取引件数: {len(transactions)}件
- アラート閾値: {alert_threshold:,}円以上

"""
            
            if large_deposits:
                result += f"💰 大きな入金（{len(large_deposits)}件）:\n"
                for tx in sorted(large_deposits, key=lambda x: abs(x['amount']), reverse=True):
                    result += f"  🔼 {tx['date']}: +{tx['amount']:,}円\n"
                    result += f"     摘要: {tx['remarks']}\n"
                    result += f"     残高: {tx['balance_after']:,}円\n\n"
            else:
                result += f"💰 大きな入金: なし\n\n"
            
            if large_withdrawals:
                result += f"💸 大きな出金（{len(large_withdrawals)}件）:\n"
                for tx in sorted(large_withdrawals, key=lambda x: abs(x['amount']), reverse=True):
                    result += f"  🔽 {tx['date']}: {tx['amount']:,}円\n"
                    result += f"     摘要: {tx['remarks']}\n"
                    result += f"     残高: {tx['balance_after']:,}円\n\n"
            else:
                result += f"💸 大きな出金: なし\n\n"
            
            # アラート判定
            alerts = []
            
            # 1日で大きく残高が変動した日を検出
            daily_changes = {}
            for tx in transactions:
                date = tx.get('transactionDate')
                amount = int(tx.get('amount', 0))
                if date not in daily_changes:
                    daily_changes[date] = 0
                daily_changes[date] += amount
            
            for date, change in daily_changes.items():
                if abs(change) >= alert_threshold * 2:
                    alerts.append(f"⚠️  {date}: 1日で {change:+,}円 の変動")
            
            if alerts:
                result += f"🚨 アラート:\n"
                for alert in alerts:
                    result += f"{alert}\n"
            else:
                result += f"✅ 異常な資金移動は検出されませんでした\n"
            
            return [TextContent(type="text", text=result)]
        
        elif name == "get_all_accounts":
            # 全口座一覧取得
            data = call_api("/accounts")
            
            accounts = data.get("accounts", [])
            
            if not accounts:
                return [TextContent(type="text", text="口座情報が見つかりませんでした。")]
            
            result = f"🏦 GMO青空ネット銀行 口座一覧\n\n"
            result += f"基準日時: {data.get('baseDate')} {data.get('baseTime')}\n"
            result += f"口座数: {len(accounts)}件\n\n"
            
            for i, acc in enumerate(accounts, 1):
                result += f"{i}. {acc.get('accountName')}\n"
                result += f"   口座ID: {acc.get('accountId')}\n"
                result += f"   支店: {acc.get('branchName')} ({acc.get('branchCode')})\n"
                result += f"   種別: {acc.get('accountTypeName')}\n"
                result += f"   口座番号: {acc.get('accountNumber')}\n"
                result += f"   通貨: {acc.get('currencyName')}\n"
                
                if acc.get('primaryAccountCode') == '1':
                    result += f"   ⭐ 代表口座\n"
                
                result += f"\n"
            
            # SPアカウント情報
            sp_accounts = data.get("spAccounts", [])
            if sp_accounts:
                result += f"📁 SPアカウント: {len(sp_accounts)}件\n"
                for sp in sp_accounts:
                    result += f"   - {sp.get('spAccountName')} (ID: {sp.get('accountId')})\n"
            
            return [TextContent(type="text", text=result)]
        
        else:
            return [TextContent(type="text", text=f"❌ 不明なツール: {name}")]
    
    except requests.exceptions.HTTPError as e:
        error_msg = f"❌ API呼び出しエラー: {e}\n"
        try:
            error_msg += f"詳細: {e.response.text}"
        except:
            pass
        return [TextContent(type="text", text=error_msg)]
    
    except Exception as e:
        return [TextContent(type="text", text=f"❌ エラーが発生しました: {str(e)}")]

# サーバー起動
if __name__ == "__main__":
    import asyncio
    import sys
    from mcp.server.stdio import stdio_server
    
    async def main():
        async with stdio_server() as (read_stream, write_stream):
            await server.run(
                read_stream,
                write_stream,
                server.create_initialization_options()
            )
    
    asyncio.run(main())
