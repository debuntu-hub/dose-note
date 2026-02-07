import SwiftUI
import SwiftData

struct VaultDetailView: View {
    let item: VaultItem
    @State private var payload: SecretPayload?
    @State private var errorMessage: String?
    @State private var isVisible: Bool = false
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Service")) {
                Text(item.title)
                    .font(.headline)
            }
            
            if let payload = payload {
                Section(header: Text("Username / ID")) {
                    HStack {
                        Text(payload.username)
                        Spacer()
                        Button(action: {
                            ClipboardManager.shared.copy(payload.username)
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
                
                Section(header: Text("Password")) {
                    ForEach(Array(payload.passwords.enumerated()), id: \.element.id) { index, entry in
                        VStack(alignment: .leading, spacing: 6) {
                            if payload.passwords.count > 1 {
                                Text(entry.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                if isVisible {
                                    Text(entry.value)
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    Text("••••••••••••••••")
                                        .font(.system(.body, design: .monospaced))
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    isVisible.toggle()
                                }) {
                                    Image(systemName: isVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                    .frame(height: 20)
                                
                                Button(action: {
                                    ClipboardManager.shared.copy(entry.value)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                    }
                }
                
                if !payload.note.isEmpty {
                    Section(header: Text("Note")) {
                        Text(payload.note)
                    }
                }
            } else if let error = errorMessage {
                Section {
                    Text("復号に失敗しました")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ProgressView("復号中...")
                }
            }
            
            Section {
                Text("Created: \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Details")
        .toolbar {
            Button("Edit") {
                showEditSheet = true
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditVaultItemView(item: item)
        }
        // 編集から戻ってきた時などに再読み込みするトリガー
        // itemの更新を検知できるようにする
        .onChange(of: item.updatedAt) { _, _ in
            loadData()
        }
        .task {
            loadData()
        }
    }
    
    private func loadData() {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let decoded = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            self.payload = decoded
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
