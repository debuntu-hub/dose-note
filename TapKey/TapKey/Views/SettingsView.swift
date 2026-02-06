import SwiftUI

struct SettingsView: View {
    // クリップボードクリア時間（秒）
    @AppStorage("clipboardClearSeconds") private var clipboardClearSeconds: Int = 30
    // 自動ロック設定（バックグラウンド移行後の秒数、0=即時）
    @AppStorage("autoLockSeconds") private var autoLockSeconds: Int = 0
    // オンボーディング
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    let clipboardOptions = [10, 15, 30, 60, 90, 120]
    let autoLockOptions = [0, 5, 15, 30, 60, 300]
    
    var body: some View {
        NavigationStack {
            List {
                // セキュリティ
                Section(header: Text("セキュリティ")) {
                    // 生体認証（常時ON、情報表示のみ）
                    HStack {
                        Label("生体認証ロック", systemImage: "faceid")
                        Spacer()
                        Text("ON")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 自動ロック時間
                    Picker(selection: $autoLockSeconds) {
                        ForEach(autoLockOptions, id: \.self) { sec in
                            Text(autoLockLabel(sec)).tag(sec)
                        }
                    } label: {
                        Label("自動ロック", systemImage: "lock.fill")
                    }
                }
                
                // クリップボード
                Section(header: Text("クリップボード")) {
                    Picker(selection: $clipboardClearSeconds) {
                        ForEach(clipboardOptions, id: \.self) { sec in
                            Text("\(sec)秒").tag(sec)
                        }
                    } label: {
                        Label("自動クリア", systemImage: "clipboard")
                    }
                    
                    Text("コピー後、指定秒数でクリップボードを自動クリアします")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // データ管理
                Section(header: Text("データ管理")) {
                    // エクスポート/インポート（v1.0以降）
                    HStack {
                        Label("エクスポート / インポート", systemImage: "square.and.arrow.up")
                        Spacer()
                        Text("v1.0")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .foregroundStyle(.secondary)
                }
                
                // アプリ情報
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("v0.1")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("データ保存")
                        Spacer()
                        Text("ローカルのみ")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("暗号化")
                        Spacer()
                        Text("AES-256-GCM")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // リセット
                Section {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        Label("ガイダンスを再表示", systemImage: "questionmark.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func autoLockLabel(_ seconds: Int) -> String {
        switch seconds {
        case 0: return "即時"
        case 5: return "5秒"
        case 15: return "15秒"
        case 30: return "30秒"
        case 60: return "1分"
        case 300: return "5分"
        default: return "\(seconds)秒"
        }
    }
}
