import SwiftUI
import SwiftData

/// 保存済みパスワードから選択するピッカー
/// フラット一覧で全パスワードを即座に選択可能
struct SavedPasswordPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \VaultItem.title) private var items: [VaultItem]
    @State private var searchText = ""
    @State private var decryptedEntries: [DecryptedEntry] = []
    @State private var isLoading = true
    @State private var selectedEntry: DecryptedEntry?
    @State private var showConfirmation = false
    
    /// 選択結果を返すコールバック
    var onSelect: (PasswordEntry, ApplyAction) -> Void
    
    enum ApplyAction {
        case apply   // 現在のフォームに適用
        case copy    // クリップボードにコピー
    }
    
    /// 復号済みのパスワード情報
    struct DecryptedEntry: Identifiable {
        let id = UUID()
        let serviceName: String
        let username: String
        let entry: PasswordEntry
    }
    
    var filteredEntries: [DecryptedEntry] {
        if searchText.isEmpty {
            return decryptedEntries
        } else {
            return decryptedEntries.filter {
                $0.serviceName.localizedStandardContains(searchText) ||
                $0.entry.label.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if decryptedEntries.isEmpty {
                    ContentUnavailableView(
                        "保存済みパスワードがありません",
                        systemImage: "key.slash",
                        description: Text("まずパスワードを保存してください。")
                    )
                } else {
                    List {
                        ForEach(filteredEntries) { item in
                            Button(action: {
                                selectedEntry = item
                                showConfirmation = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "key.fill")
                                        .font(.callout)
                                        .foregroundStyle(AppTheme.accent)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.serviceName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        
                                        HStack(spacing: 6) {
                                            if item.entry.label != "パスワード" {
                                                Text(item.entry.label)
                                                    .font(.caption2)
                                                    .foregroundStyle(AppTheme.accent.opacity(0.8))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(AppTheme.accent.opacity(0.1))
                                                    .clipShape(Capsule())
                                            }
                                            
                                            Text(item.username)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if !searchText.isEmpty && filteredEntries.isEmpty {
                            ContentUnavailableView.search
                        }
                    }
                }
            }
            .navigationTitle("保存済みパスワード")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "サービス名で検索")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .confirmationDialog(
                "このパスワードを使いますか？",
                isPresented: $showConfirmation,
                titleVisibility: .visible,
                presenting: selectedEntry
            ) { selected in
                Button("フォームに適用") {
                    onSelect(selected.entry, .apply)
                    dismiss()
                }
                Button("クリップボードにコピー") {
                    onSelect(selected.entry, .copy)
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {
                    selectedEntry = nil
                }
            } message: { selected in
                Text("\(selected.serviceName) の「\(selected.entry.label)」")
            }
            .task {
                decryptAll()
            }
        }
    }
    
    /// 全VaultItemを復号してフラットなパスワード一覧を生成
    private func decryptAll() {
        var entries: [DecryptedEntry] = []
        for item in items {
            guard let decryptedData = try? EncryptionManager.shared.decrypt(item.encryptedData),
                  let payload = try? JSONDecoder().decode(SecretPayload.self, from: decryptedData) else {
                continue
            }
            for pw in payload.passwords {
                entries.append(DecryptedEntry(
                    serviceName: item.title,
                    username: payload.username,
                    entry: pw
                ))
            }
        }
        decryptedEntries = entries
        isLoading = false
    }
}
