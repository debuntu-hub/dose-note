"""
GMO Aozora Bank MCP Server
会社OS用の銀行API連携MCPサーバー

提供ツール:
- get_account_balance: 口座残高を取得
- get_transactions: 入出金明細を取得（期間指定可能）
- get_monthly_summary: 月次サマリー（FCF分析用）
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
