import SwiftUI
import SwiftData

struct VaultListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VaultItem.createdAt, order: .reverse) private var items: [VaultItem]
    @State private var searchText = ""
    
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
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.createdAt.formatted(date: .numeric, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteItems(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
}

#Preview {
    VaultListView()
        .modelContainer(for: VaultItem.self, inMemory: true)
}
