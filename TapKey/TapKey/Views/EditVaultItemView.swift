import SwiftUI
import SwiftData

struct EditVaultItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var item: VaultItem
    
    // 編集用の一時ステート
    @State private var serviceName: String = ""
    @State private var username: String = ""
    @State private var passwords: [PasswordEntry] = []
    @State private var note: String = ""
    
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                if isLoading {
                    ProgressView("読み込み中...")
                } else if let error = errorMessage {
                    Text("エラー: \(error)")
                        .foregroundStyle(.red)
                } else {
                    Section(header: Text("サービス情報")) {
                        TextField("サービス名", text: $serviceName)
                        TextField("ユーザーID / Email", text: $username)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    
                    Section(header: Text("パスワード")) {
                        ForEach(Array(passwords.enumerated()), id: \.element.id) { index, entry in
                            VStack(alignment: .leading, spacing: 4) {
                                if passwords.count > 1 {
                                    HStack {
                                        TextField("ラベル", text: $passwords[index].label)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Button(action: {
                                            if passwords.count > 1 {
                                                passwords.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(.red)
                                                .font(.caption)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                                HStack {
                                    TextField("パスワード", text: $passwords[index].value)
                                        .font(.system(.body, design: .monospaced))
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                    
                                    Button(action: {
                                        passwords[index].value = PasswordGenerator.generate()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                        
                        Button(action: {
                            passwords.append(PasswordEntry(label: "パスワード", value: PasswordGenerator.generate()))
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("パスワードを追加")
                            }
                            .font(.footnote)
                        }
                    }
                    
                    Section(header: Text("メモ")) {
                        TextField("メモ (任意)", text: $note)
                    }
                }
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(isLoading || serviceName.isEmpty)
                }
            }
            .task {
                loadData()
            }
        }
    }
    
    private func loadData() {
        self.serviceName = item.title
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let payload = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            
            self.username = payload.username
            self.passwords = payload.passwords
            self.note = payload.note
            self.isLoading = false
        } catch {
            self.errorMessage = "データの読み込みに失敗しました: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    private func save() {
        do {
            let newPayload = SecretPayload(username: username, passwords: passwords, note: note)
            let jsonData = try JSONEncoder().encode(newPayload)
            let encrypted = try EncryptionManager.shared.encrypt(jsonData)
            
            // SwiftDataのオブジェクトを更新
            item.title = serviceName
            item.encryptedData = encrypted
            item.updatedAt = Date()
            
            // 何もしなくてもautosaveされるが、明示的に書き込むなら try modelContext.save()
            
            dismiss()
        } catch {
            self.errorMessage = "保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
