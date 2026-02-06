import os
from dotenv import load_dotenv

def check_config():
    load_dotenv()
    
    required_vars = [
        "SUNABAR_USER_ID",
        "SUNABAR_PASSWORD",
        "API_BASE_URL",
        # "CLIENT_ID", # These might not be set yet if user only did step 1
        # "CLIENT_SECRET"
    ]
    
    print("--- 🔧 設定チェック (Configuration Check) ---")
    
    all_ok = True
    for var in required_vars:
        value = os.getenv(var)
        if value:
            print(f"✅ {var}: 設定済み (Set)")
        else:
            print(f"❌ {var}: 未設定 (Not Set)")
            all_ok = False
            
    # Check for Client Credentials specifically
    client_id = os.getenv("CLIENT_ID")
    client_secret = os.getenv("CLIENT_SECRET")
    
    if client_id and client_secret:
        print("✅ CLIENT_ID / SECRET: 設定済み (Set)")
    else:
        print("⚠️  CLIENT_ID / SECRET: 未設定 (Not Set)")
        print("   → APIを利用するには、Sunabarポータルでアプリケーションを作成し、")
        print("     CLIENT_ID と CLIENT_SECRET を .env に追記する必要があります。")
        all_ok = False

    if all_ok:
        print("\n✨ 準備完了！API接続テストに進めます。")
    else:
        print("\n🚧 設定が不足しています。.envファイルを確認してください。")

if __name__ == "__main__":
    check_config()
