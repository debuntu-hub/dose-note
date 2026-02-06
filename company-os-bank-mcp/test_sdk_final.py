import os
from dotenv import load_dotenv
import ganb_auth
import ganb_personal_client

load_dotenv()

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")

# Sunabar Host
PERSONAL_HOST = "https://api.sunabar.gmo-aozora.com/personal/v1"

def main():
    if not CLIENT_ID or not CLIENT_SECRET or not REDIRECT_URI:
        print("❌ Error: .env is missing required variables.")
        return
    
    print("\n🏦 GMO Aozora Bank API (Sunabar) - SDK Connection Test")
    print("=" * 60)
    
    # Step 1: Initialize GanbConnector for authentication
    # Try minimal initialization - redirect_uri might be passed to methods instead
    connector = ganb_auth.GanbConnector(
        client_id=CLIENT_ID,
        client_secret=CLIENT_SECRET
    )
    
    # Step 2: Generate Authorization URL
    # redirect_uri is likely passed here instead
    scopes = "public personal accounts transactions"
    state = "test_state_123"
    
    try:
        auth_url = connector.get_authorization_url(
            redirect_uri=REDIRECT_URI,
            scope=scopes,
            state=state
        )
    except TypeError as e:
        print(f"⚠️  Parameter error: {e}")
        print("Trying alternative parameter format...")
        # Maybe it needs different parameter names
        auth_url = connector.get_authorization_url(
            redirect_url=REDIRECT_URI,
            scopes=scopes,
            state=state
        )
    
    print("\n📋 以下のURLをブラウザで開き、ログインして承認してください:")
    print(auth_url)
    print("=" * 60)
    print("\n承認後、リダイレクト先のURL全体を貼り付けてください")
    print("(例: http://localhost:8080/callback?code=xxxxx&state=...)")
    
    redirected_url = input("\n👉 Redirected URL: ").strip()
    
    # Step 3: Extract code from URL
    try:
        import urllib.parse
        parsed = urllib.parse.urlparse(redirected_url)
        qs = urllib.parse.parse_qs(parsed.query)
        code = qs['code'][0]
        print(f"\n✅ Code extracted successfully")
    except Exception as e:
        print(f"❌ Failed to extract code: {e}")
        return
    
    # Step 4: Exchange code for access token
    print("\n🔄 Exchanging authorization code for access token...")
    try:
        token_response = connector.get_token(code=code)
        access_token = token_response.get('access_token')
        
        if not access_token:
            print(f"❌ No access token in response: {token_response}")
            return
            
        print("✅ Access token acquired!")
        
        # Step 5: Fetch account information
        fetch_account_info(access_token)
        
    except Exception as e:
        print(f"❌ Token exchange failed: {e}")
        import traceback
        traceback.print_exc()

def fetch_account_info(access_token):
    print("\n💰 Fetching account information...")
    
    # Configure API client
    config = ganb_personal_client.Configuration()
    config.host = PERSONAL_HOST
    config.access_token = access_token
    
    api_client = ganb_personal_client.ApiClient(configuration=config)
    account_api = ganb_personal_client.AccountApi(api_client)
    
    try:
        # Fetch accounts
        print("\n📊 Fetching accounts...")
        accounts_response = account_api.accounts_using_get()
        print(f"✅ Accounts retrieved: {accounts_response}")
        
        # Fetch balances
        print("\n💵 Fetching balances...")
        balances_response = account_api.balances_using_get()
        print(f"✅ Balances retrieved: {balances_response}")
        
        print("\n🎉 Connection test successful!")
        print("=" * 60)
        print("✨ GMO Aozora Bank APIとの接続に成功しました！")
        print("これでMCPサーバーの実装を進められます。")
        
    except Exception as e:
        print(f"❌ API call failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
