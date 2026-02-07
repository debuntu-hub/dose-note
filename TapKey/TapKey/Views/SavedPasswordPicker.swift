import SwiftUI
import SwiftData

/// 保存済みパスワードから選択するピッカー
/// 設計原則: 自動表示なし・推奨なし・頻度順なし → 責任は完全にユーザー側
struct SavedPasswordPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \VaultItem.title) private var items: [VaultItem]
    @State private var searchText = ""
    @State private var selectedPayload: (title: String, entry: PasswordEntry)?
    @State private var showConfirmation = false
    
    /// 選択結果を返すコールバック
    var onSelect: (PasswordEntry, ApplyAction) -> Void
    
    enum ApplyAction {
        case apply   // 現在のフォームに適用
        case copy    // クリップボードにコピー
    }
    
    var filteredItems: [VaultItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    ContentUnavailableView(
                        "保存済みパスワードがありません",
                        systemImage: "key.slash",
                        description: Text("まずパスワードを保存してください。")
                    )
                } else {
                    ForEach(filteredItems) { item in
                        SavedPasswordRow(item: item) { title, entry in
                            selectedPayload = (title: title, entry: entry)
                            showConfirmation = true
                        }
                    }
                    
                    if !searchText.isEmpty && filteredItems.isEmpty {
                        ContentUnavailableView.search
                    }
                }
            }
            .navigationTitle("保存済みから選ぶ")
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
                presenting: selectedPayload
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
                    selectedPayload = nil
                }
            } message: { selected in
                Text("\(selected.title) の「\(selected.entry.label)」")
            }
        }
    }
}

// MARK: - 各行（復号してパスワード一覧を表示）

private struct SavedPasswordRow: View {
    let item: VaultItem
    var onTap: (String, PasswordEntry) -> Void
    
    @State private var payload: SecretPayload?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // サービス名タップで展開
            Button(action: {
                if payload == nil { decrypt() }
                withAnimation { isExpanded.toggle() }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let payload = payload {
                            Text(payload.username)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // 展開時: パスワード一覧
            if isExpanded, let payload = payload {
                VStack(spacing: 0) {
                    ForEach(payload.passwords) { entry in
                        Button(action: {
                            onTap(item.title, entry)
                        }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    if payload.passwords.count > 1 {
                                        Text(entry.label)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text("••••••••••••")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.primary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 8)
                            .padding(.leading, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
            }
        }
        .task {
            // 初回表示時は復号しない（展開時にのみ復号）
        }
    }
    
    private func decrypt() {
        guard let decryptedData = try? EncryptionManager.shared.decrypt(item.encryptedData),
              let decoded = try? JSONDecoder().decode(SecretPayload.self, from: decryptedData) else {
            return
        }
        payload = decoded
    }
}
