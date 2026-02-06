import os
import secrets
from dotenv import load_dotenv
import ganb_auth
import ganb_personal_client

load_dotenv()

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")

# Sunabar (Test) Environment
# Personal API Host
HOST = "https://api.sunabar.gmo-aozora.com/personal/v1"

def main():
    if not CLIENT_ID or not CLIENT_SECRET or not REDIRECT_URI:
        print("❌ Error: .env is missing required variables.")
        return
    
    print("\n🏦 GMO Aozora Bank API (Sunabar) - SDK Test")
    print("-" * 60)
    
    # Step 1: Generate Authorization URL using SDK
    auth_helper = ganb_auth.PersonalAuthHelper(
        client_id=CLIENT_ID,
        client_secret=CLIENT_SECRET
    )
    
    state = secrets.token_urlsafe(16)
    scopes = ["public", "personal", "accounts", "transactions"]
    
    # Generate Authorization URL
    auth_url = auth_helper.get_authorization_url(
        redirect_uri=REDIRECT_URI,
        scopes=scopes,
        state=state
    )
    
    print("📋 以下のURLをブラウザで開き、ログインして承認してください:")
    print(auth_url)
    print("-" * 60)
    print("承認後、リダイレクト先のURL全体を貼り付けてください")
    print("(例: http://localhost:8080/callback?code=xxxxx...)")
    
    redirected_url = input("\n👉 Redirected URL: ").strip()
    
    # Step 2: Extract code from URL
    try:
        import urllib.parse
        parsed = urllib.parse.urlparse(redirected_url)
        qs = urllib.parse.parse_qs(parsed.query)
        code = qs['code'][0]
        print(f"\n✅ Code extracted: {code[:20]}...")
    except Exception as e:
        print(f"❌ Failed to extract code: {e}")
        return
    
    # Step 3: Exchange code for tokens
    print("\n🔄 Exchanging code for access token...")
    try:
        tokens = auth_helper.get_token(
            code=code,
            redirect_uri=REDIRECT_URI
        )
        access_token = tokens['access_token']
        print("✅ Access token acquired!")
        
        # Step 4: Fetch account data using SDK
        fetch_accounts_with_sdk(access_token)
        
    except Exception as e:
        print(f"❌ Token exchange failed: {e}")
        import traceback
        traceback.print_exc()

def fetch_accounts_with_sdk(access_token):
    print("\n💰 Fetching account information...")
    
    # Create Personal Client
    client = ganb_personal_client.PersonalClient(
        host=HOST,
        access_token=access_token
    )
    
    try:
        # Fetch accounts
        accounts = client.accounts()
        print("✅ Account data retrieved successfully!")
        print(f"\nAccounts: {accounts}")
        
        # Fetch balances if accounts exist
        if accounts:
            print("\n💵 Fetching balances...")
            balances = client.balances()
            print(f"Balances: {balances}")
        
    except Exception as e:
        print(f"❌ API call failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
