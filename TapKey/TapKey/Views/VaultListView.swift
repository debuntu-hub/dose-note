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
            List {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: VaultDetailView(item: item)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.createdAt.formatted(date: .numeric, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // ワンタップコピー（§3.2: タップでパスワードコピー）
                            Button(action: {
                                copyPassword(for: item)
                            }) {
                                Image(systemName: copiedItemId == item.id ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundStyle(copiedItemId == item.id ? .green : .blue)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteItems(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            copyUsername(for: item)
                        } label: {
                            Label("Copy ID", systemImage: "person.crop.circle")
                        }
                        .tint(.blue)
                    }
                }
                
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Passwords",
                        systemImage: "key.slash",
                        description: Text("まずはホーム画面でパスワードを生成して保存しましょう。")
                    )
                } else if filteredItems.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .navigationTitle("Vault")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
            ClipboardManager.shared.copy(payload.password)
            withAnimation {
                copiedItemId = item.id
            }
            // 2秒後にチェックマークを戻す
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    if copiedItemId == item.id {
                        copiedItemId = nil
                    }
                }
            }
        } catch {
            // 復号失敗時は何もしない
        }
    }
    
    private func copyUsername(for item: VaultItem) {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let payload = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            ClipboardManager.shared.copy(payload.username)
        } catch {
            // 復号失敗時は何もしない
        }
    }
}

#Preview {
    VaultListView()
        .modelContainer(for: VaultItem.self, inMemory: true)
}
