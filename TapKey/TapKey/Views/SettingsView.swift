import SwiftUI

struct SettingsView: View {
    @AppStorage("clipboardClearSeconds") private var clipboardClearSeconds: Int = 30
    @AppStorage("autoLockSeconds") private var autoLockSeconds: Int = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Environment(BiometricManager.self) private var biometricManager
    
    let clipboardOptions = [10, 15, 30, 60, 90, 120]
    let autoLockOptions = [0, 5, 15, 30, 60, 300]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "faceid", color: Color(hex: "10B981"))
                        Toggle("生体認証ロック", isOn: Binding(
                            get: { biometricManager.isBiometricEnabled },
                            set: { biometricManager.isBiometricEnabled = $0 }
                        ))
                        .tint(Color(hex: "10B981"))
                    }
                    
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "lock.fill", color: AppTheme.accent)
                        Picker("自動ロック", selection: $autoLockSeconds) {
                            ForEach(autoLockOptions, id: \.self) { sec in
                                Text(autoLockLabel(sec)).tag(sec)
                            }
                        }
                    }
                } header: {
                    Label("セキュリティ", systemImage: "shield.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                
                Section {
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "clipboard.fill", color: Color(hex: "F59E0B"))
                        Picker("自動クリア", selection: $clipboardClearSeconds) {
                            ForEach(clipboardOptions, id: \.self) { sec in
                                Text("\(sec)秒").tag(sec)
                            }
                        }
                    }
                    
                    Text("コピー後、指定秒数でクリップボードを自動クリアします")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .listRowBackground(Color.clear)
                } header: {
                    Label("クリップボード", systemImage: "doc.on.clipboard.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "F59E0B"))
                }
                
                Section {
                    InfoRow(label: "バージョン", value: "v0.1")
                    InfoRow(label: "データ保存", value: "ローカルのみ")
                    InfoRow(label: "暗号化", value: "AES-256-GCM")
                } header: {
                    Label("アプリ情報", systemImage: "info.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        HStack(spacing: 14) {
                            SettingsIcon(icon: "questionmark.circle", color: Color(hex: "8B5CF6"))
                            Text("ガイダンスを再表示")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("設定")
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

private struct SettingsIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.callout)
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
