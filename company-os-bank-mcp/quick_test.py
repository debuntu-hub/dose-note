"""
GMO Aozora Bank Sunabar API - Quick Test
ポータルから取得したトークンを使った直接接続
"""
import os
import requests
import json
from dotenv import load_dotenv

load_dotenv()

ACCESS_TOKEN = os.getenv("ACCESS_TOKEN")
BASE_URL = "https://api.sunabar.gmo-aozora.com/personal/v1"

def main():
    print("\n" + "="*70)
    print("🏦 GMO青空ネット銀行 Sunabar API クイックテスト")
    print("="*70)
    
    if not ACCESS_TOKEN:
        print("❌ ACCESS_TOKENが.envに設定されていません")
        return
    
    print(f"\n✅ アクセストークン確認: {ACCESS_TOKEN[:10]}...")
    
    # Test 1: 口座一覧取得
    print("\n📋 テスト1: 口座一覧取得")
    print("-" * 70)
    
    try:
        response = requests.get(
            f"{BASE_URL}/accounts",
            headers={
                "x-access-token": ACCESS_TOKEN,
                "accept": "application/json;charset=UTF-8"
            }
        )
        
        print(f"ステータスコード: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ 口座一覧取得成功！")
            print(json.dumps(data, indent=2, ensure_ascii=False))
            
            # Test 2: 残高照会
            print("\n" + "="*70)
            print("💰 テスト2: 残高照会")
            print("-" * 70)
            
            response2 = requests.get(
                f"{BASE_URL}/accounts/balances",
                headers={
                    "x-access-token": ACCESS_TOKEN,
                    "accept": "application/json;charset=UTF-8"
                }
            )
            
            print(f"ステータスコード: {response2.status_code}")
            
            if response2.status_code == 200:
                balance_data = response2.json()
                print("✅ 残高取得成功！")
                print(json.dumps(balance_data, indent=2, ensure_ascii=False))
                
                print("\n" + "="*70)
                print("🎉 すべてのテストが成功しました！")
                print("="*70)
                print("✨ GMO青空ネット銀行APIとの接続が確立されました")
                print("   次のステップ: MCPサーバーの実装")
                
            else:
                print(f"❌ 残高取得失敗")
                print(f"レスポンス: {response2.text}")
        else:
            print(f"❌ 口座一覧取得失敗")
            print(f"レスポンス: {response.text}")
            
    except Exception as e:
        print(f"❌ エラー発生: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
