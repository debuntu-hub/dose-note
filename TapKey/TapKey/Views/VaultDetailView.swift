import SwiftUI
import SwiftData

struct VaultDetailView: View {
    let item: VaultItem
    @State private var payload: SecretPayload?
    @State private var errorMessage: String?
    @State private var visiblePasswords: Set<UUID> = []
    @State private var showEditSheet: Bool = false
    @State private var copiedId: UUID?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    ServiceInitialsView(title: item.title, size: 64)
                    
                    Text(item.title)
                        .font(.title2.weight(.bold))
                    
                    if let payload = payload {
                        Text(payload.username)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .glassCard()
                
                if let payload = payload {
                    VStack(spacing: 0) {
                        // Username row
                        HStack(spacing: 14) {
                            Image(systemName: "person.fill")
                                .font(.callout)
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ユーザーID")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(payload.username)
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                ClipboardManager.shared.copy(payload.username)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.callout)
                                    .foregroundStyle(AppTheme.accent)
                                    .padding(6)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        ForEach(payload.passwords) { entry in
                            Divider().padding(.leading, 48)
                            
                            HStack(spacing: 14) {
                                Image(systemName: "key.fill")
                                    .font(.callout)
                                    .foregroundStyle(AppTheme.accent)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    if payload.passwords.count > 1 {
                                        Text(entry.label)
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.accentLight)
                                    }
                                    
                                    if visiblePasswords.contains(entry.id) {
                                        Text(entry.value)
                                            .font(.system(.body, design: .monospaced))
                                    } else {
                                        Text(String(repeating: "\u{2022}", count: 16))
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.2)) {
                                        if visiblePasswords.contains(entry.id) {
                                            visiblePasswords.remove(entry.id)
                                        } else {
                                            visiblePasswords.insert(entry.id)
                                        }
                                    }
                                }) {
                                    Image(systemName: visiblePasswords.contains(entry.id) ? "eye.slash" : "eye")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                        .padding(6)
                                }
                                
                                Button(action: {
                                    ClipboardManager.shared.copy(entry.value)
                                    withAnimation(.spring(response: 0.2)) {
                                        copiedId = entry.id
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { copiedId = nil }
                                    }
                                }) {
                                    Image(systemName: copiedId == entry.id ? "checkmark.circle.fill" : "doc.on.doc")
                                        .font(.callout)
                                        .foregroundStyle(copiedId == entry.id ? .green : AppTheme.accent)
                                        .padding(6)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        
                        if !payload.note.isEmpty {
                            Divider().padding(.leading, 48)
                            
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: "note.text")
                                    .font(.callout)
                                    .foregroundStyle(.orange)
                                    .frame(width: 24)
                                
                                Text(payload.note)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    
                } else if let error = errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        Text("復号に失敗しました")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .glassCard()
                } else {
                    ProgressView("復号中...")
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .glassCard()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { showEditSheet = true }) {
                Text("編集")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditVaultItemView(item: item)
        }
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
