"""
GMO Aozora Net Bank Sunabar API - Simple Connection Test
シンプルで確実な接続テスト
"""
import os
import requests
from dotenv import load_dotenv

load_dotenv()

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")

# Sunabar endpoints
BASE_URL = "https://api.sunabar.gmo-aozora.com"

def main():
    print("\n" + "="*70)
    print("🏦 GMO青空ネット銀行 Sunabar API 接続テスト")
    print("="*70)
    
    if not all([CLIENT_ID, CLIENT_SECRET, REDIRECT_URI]):
        print("❌ エラー: .envファイルの設定が不足しています")
        return
    
    print(f"\n✅ 設定確認:")
    print(f"  CLIENT_ID: {CLIENT_ID}")
    print(f"  REDIRECT_URI: {REDIRECT_URI}")
    
    # Build authorization URL
    auth_params = {
        'client_id': CLIENT_ID,
        'redirect_uri': REDIRECT_URI,
        'response_type': 'code',
        'scope': 'refer',  # 最小限のスコープ
        'state': 'test123'
    }
    
    auth_url = f"{BASE_URL}/auth/v1/authorization"
    
    # URLエンコードして表示
    import urllib.parse
    query_string = urllib.parse.urlencode(auth_params)
    full_auth_url = f"{auth_url}?{query_string}"
    
    print("\n" + "="*70)
    print("📋 ステップ1: 以下のURLをブラウザで開いてください")
    print("="*70)
    print(f"\n{full_auth_url}\n")
    print("="*70)
    print("\n⚠️  重要:")
    print("  1. ブラウザでこのURLを開く")
    print("  2. Sunabarアカウントでログイン")
    print("  3. アプリを承認")
    print("  4. リダイレクト後のURL全体をコピー")
    print("     (例: http://localhost:8080/callback?code=xxxxx&state=test123)")
    print("\n⚠️  「ページが見つかりません」と表示されても正常です")
    print("     → アドレスバーのURLをコピーしてください")
    
    # ユーザー入力を待つ
    print("\n" + "="*70)
    redirected_url = input("👉 リダイレクト後のURL: ").strip()
    
    if not redirected_url:
        print("❌ URLが入力されませんでした")
        return
    
    # codeを抽出
    try:
        parsed = urllib.parse.urlparse(redirected_url)
        params = urllib.parse.parse_qs(parsed.query)
        code = params.get('code', [None])[0]
        
        if not code:
            print("❌ コードが見つかりませんでした")
            print(f"入力されたURL: {redirected_url}")
            return
            
        print(f"\n✅ 認証コード取得成功: {code[:20]}...")
        
    except Exception as e:
        print(f"❌ URLの解析に失敗: {e}")
        return
    
    # トークン取得
    print("\n🔄 ステップ2: アクセストークンを取得中...")
    
    token_url = f"{BASE_URL}/auth/v1/token"
    token_data = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': REDIRECT_URI,
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET
    }
    
    try:
        response = requests.post(
            token_url,
            data=token_data,
            headers={'Content-Type': 'application/x-www-form-urlencoded'}
        )
        
        print(f"  レスポンスコード: {response.status_code}")
        
        if response.status_code == 200:
            tokens = response.json()
            access_token = tokens.get('access_token')
            print(f"✅ トークン取得成功!")
            
            # APIテスト
            test_api_call(access_token)
            
        else:
            print(f"❌ トークン取得失敗")
            print(f"  レスポンス: {response.text}")
            
    except Exception as e:
        print(f"❌ エラー: {e}")
        import traceback
        traceback.print_exc()

def test_api_call(access_token):
    """口座情報の取得テスト"""
    print("\n💰 ステップ3: 口座情報を取得中...")
    
    # 口座一覧取得
    accounts_url = f"{BASE_URL}/personal/v1/accounts"
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json;charset=UTF-8'
    }
    
    try:
        response = requests.get(accounts_url, headers=headers)
        print(f"  レスポンスコード: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ 口座情報取得成功!")
            print(f"\nデータ:")
            import json
            print(json.dumps(data, indent=2, ensure_ascii=False))
            
            print("\n" + "="*70)
            print("🎉 接続テスト完了!")
            print("="*70)
            print("✨ GMO青空ネット銀行APIとの接続に成功しました")
            print("   これでMCPサーバーの実装に進めます")
            
        else:
            print(f"❌ API呼び出し失敗")
            print(f"  レスポンス: {response.text}")
            
    except Exception as e:
        print(f"❌ エラー: {e}")

if __name__ == "__main__":
    main()
