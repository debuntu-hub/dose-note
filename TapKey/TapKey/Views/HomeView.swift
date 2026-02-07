import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @Query private var allItems: [VaultItem]
    @FocusState private var focusedField: Field?
    
    enum Field {
        case serviceName, username, note
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // パスワード表示エリア（複数対応）
                    VStack(spacing: 16) {
                        Text("生成されたパスワード")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ForEach(Array(viewModel.passwords.enumerated()), id: \.element.id) { index, entry in
                            VStack(alignment: .leading, spacing: 4) {
                                if viewModel.passwords.count > 1 {
                                    HStack {
                                        Text(entry.label)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        if viewModel.passwords.count > 1 {
                                            Button(action: {
                                                viewModel.removePassword(at: index)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                    }
                                }
                                
                                HStack {
                                    Text(entry.value)
                                        .font(.system(.title3, design: .monospaced))
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.copyPassword(at: index)
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.title3)
                                            .padding(6)
                                    }
                                    
                                    Button(action: {
                                        viewModel.generatePassword(at: index)
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.title3)
                                            .padding(6)
                                    }
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                        
                        // パスワード追加ボタン
                        Button(action: {
                            viewModel.addPassword()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("パスワードを追加")
                            }
                            .font(.footnote)
                            .foregroundStyle(.tint)
                        }
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // 入力フォーム
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("サービス名")
                                .font(.caption)
                                .bold()
                            TextField("例: Amazon, Google", text: $viewModel.serviceName)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .serviceName)
                                .submitLabel(.next)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("ユーザーID / Email")
                                .font(.caption)
                                .bold()
                            TextField("user@example.com", text: $viewModel.username)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .focused($focusedField, equals: .username)
                                .submitLabel(.next)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("メモ (任意)")
                                .font(.caption)
                                .bold()
                            TextField("備考など", text: $viewModel.note)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .note)
                                .submitLabel(.done)
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // 保存ボタン
                    if !PurchaseManager.shared.isPremium {
                        let remaining = PurchaseManager.shared.remainingSlots(currentCount: allItems.count)
                        Text("残り\(remaining)件保存可能（無料）")
                            .font(.caption)
                            .foregroundStyle(remaining <= 3 ? .orange : .secondary)
                    }
                    
                    Button(action: {
                        viewModel.save(modelContext: modelContext)
                        // キーボードを閉じる
                        focusedField = nil
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("保存して完了")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.serviceName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                    }
                    .disabled(viewModel.serviceName.isEmpty)
                }
                .padding()
            }
            .navigationTitle("TapKey")
            .alert("通知", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("保存完了", isPresented: $viewModel.isSaved) {
                Button("新しいパスワードを作る") {
                    viewModel.reset()
                }
                Button("一覧を見る") {
                    viewModel.reset()
                }
            }
            .sheet(isPresented: $viewModel.showUpgrade) {
                UpgradeView()
            }
        }
        .onAppear {
            // クリップボードにメールアドレスっぽいものがあればIDに自動入力する（SRS要件）
            if viewModel.username.isEmpty, let clipboardString = UIPasteboard.general.string {
                // 簡易的なメアド判定
                if clipboardString.contains("@") && clipboardString.count < 50 {
                    viewModel.username = clipboardString
                }
            }
        }
        .onSubmit {
            switch focusedField {
            case .serviceName:
                focusedField = .username
            case .username:
                focusedField = .note
            case .note:
                focusedField = nil
            case .none:
                break
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: VaultItem.self, inMemory: true)
}
