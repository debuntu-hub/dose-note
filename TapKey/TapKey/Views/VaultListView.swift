import SwiftUI
import SwiftData

struct VaultListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VaultItem.createdAt, order: .reverse) private var items: [VaultItem]
    @State private var searchText = ""
    @State private var copiedItemId: UUID?
    
    var filteredItems: [VaultItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "key.slash")
                            .font(.system(size: 56))
                            .foregroundStyle(AppTheme.accent.opacity(0.3))
                        
                        Text("パスワードがまだありません")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("ホーム画面でパスワードを生成して\n保存しましょう")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: VaultDetailView(item: item)) {
                                HStack(spacing: 14) {
                                    ServiceInitialsView(title: item.title, size: 44)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.title)
                                            .font(.body.weight(.semibold))
                                        Text(item.createdAt.formatted(date: .numeric, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        copyPassword(for: item)
                                    }) {
                                        Image(systemName: copiedItemId == item.id ? "checkmark.circle.fill" : "doc.on.doc")
                                            .font(.body)
                                            .foregroundStyle(copiedItemId == item.id ? .green : AppTheme.accent)
                                            .padding(8)
                                            .background(
                                                (copiedItemId == item.id ? Color.green : AppTheme.accent).opacity(0.1)
                                            )
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteItems(item)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    copyUsername(for: item)
                                } label: {
                                    Label("IDコピー", systemImage: "person.crop.circle")
                                }
                                .tint(AppTheme.accent)
                            }
                        }
                        
                        if !searchText.isEmpty && filteredItems.isEmpty {
                            ContentUnavailableView.search
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("保管庫")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "サービス名で検索")
        }
    }
    
    private func deleteItems(_ item: VaultItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
    
    private func copyPassword(for item: VaultItem) {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let payload = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            ClipboardManager.shared.copy(payload.primaryPassword)
            withAnimation(.spring(response: 0.3)) {
                copiedItemId = item.id
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring(response: 0.3)) {
                    if copiedItemId == item.id {
                        copiedItemId = nil
                    }
                }
            }
        } catch {
        }
    }
    
    private func copyUsername(for item: VaultItem) {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let payload = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            ClipboardManager.shared.copy(payload.username)
        } catch {
        }
    }
}

#Preview {
    VaultListView()
        .modelContainer(for: VaultItem.self, inMemory: true)
}
