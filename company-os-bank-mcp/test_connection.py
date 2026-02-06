import os
import requests
import json
import urllib.parse
from dotenv import load_dotenv

load_dotenv()

# Sunabar Endpoints
API_HOST = "https://api.sunabar.gmo-aozora.com"
AUTH_PATH = "/auth/v1/authorization"
TOKEN_PATH = "/auth/v1/token"
PERSONAL_PATH = "/personal/v1"

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")

# Scopes
# "openid" is often the minimum required scope. 
# If "public personal..." failed, we try "openid" or even empty string if the registry defines default scopes.
SCOPES = "openid" 

def authorize():
    """
    Generate authorization URL and get code from user interface
    """
    # 1. Construct Authorization URL
    params = {
        "response_type": "code",
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "scope": SCOPES,
        "state": "test_state_123"
    }
    encoded_params = urllib.parse.urlencode(params)
    auth_url = f"{API_HOST}{AUTH_PATH}?{encoded_params}"
    
    print("\n🔐 認証フローを開始します (Authorization Flow)")
    print("以下のURLをブラウザで開き、Sunabarアカウントでログインしてアプリを許可してください：")
    print("\n" + "=" * 60)
    print(auth_url)
    print("=" * 60 + "\n")
    
    print(f"⚠️ 注意: Sunabarポータルで設定したリダイレクトURI ({REDIRECT_URI}) と一致している必要があります。")
    print(f"ログイン完了後、リダイレクトされた先（localhostなど）のURL全体、")
    print(f"または '?code=...' 以降の文字列をここに貼り付けてください。")
    
    code_input = input("\n👉 Code or Full URL > ").strip()
    
    # Extract code if URL is pasted
    if "code=" in code_input:
        try:
            if "?" in code_input:
                query_part = code_input.split("?")[1]
            else:
                query_part = code_input
                
            qs = urllib.parse.parse_qs(query_part)
            code = qs.get('code', [None])[0]
        except:
            code = code_input # Fallback
    else:
        code = code_input
        
    return code

def get_token(code):
    """
    Exchange authorization code for access token
    """
    print("\n🔄 アクセストークンと交換中...", end=" ")
    
    url = f"{API_HOST}{TOKEN_PATH}"
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json"
    }
    data = {
        "grant_type": "authorization_code",
        "code": code,
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "redirect_uri": REDIRECT_URI
    }
    
    try:
        response = requests.post(url, headers=headers, data=data)
        response.raise_for_status()
        tokens = response.json()
        print("✅ 成功！")
        return tokens
    except Exception as e:
        print("❌ 失敗")
        print(f"Error: {e}")
        try:
             print(f"Response: {response.text}")
        except:
             pass
        return None

def get_account_balances(access_token):
    """
    Fetch balances using the access token
    """
    print("\n💰 口座残高取得テスト...")
    url = f"{API_HOST}{PERSONAL_PATH}/accounts/balances"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json;charset=UTF-8"
    }
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        print("✅ 取得成功:")
        print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        return response.json()
    except Exception as e:
        print(f"❌ 取得エラー: {e}")
        try:
             print(f"Response: {response.text}")
        except:
             pass
        return None

if __name__ == "__main__":
    if not CLIENT_ID or not CLIENT_SECRET or not REDIRECT_URI:
        print("Error: .env variables missing. Please check CLIENT_ID, CLIENT_SECRET, REDIRECT_URI.")
        exit(1)
        
    code = authorize()
    if code:
        tokens = get_token(code)
        if tokens and "access_token" in tokens:
            # Try to fetch balances
            get_account_balances(tokens["access_token"])
            
            print("\n🎉 テスト完了！")
            print("Access Token取得に成功しました。これを使ってMCPサーバーを構築します。")

