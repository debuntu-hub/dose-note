import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case serviceName, username, note
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // パスワード表示エリア
                    VStack(spacing: 16) {
                        Text("生成されたパスワード")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(viewModel.password)
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                // 実際は伏せ字にするか要検討だが、生成時は見えた方が良いので表示
                                // PRDでは「伏せ字」とあるが、コピー前提なので
                                // タップで表示切り替えなどのUIが良いかも。
                                // v0.1では簡易的にそのまま表示し、隠すモードをつけるか、
                                // "••••••••••••••••" とトグルする
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.copyPassword()
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.title2)
                                    .padding(8)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        Button("- 再生成 -") {
                            viewModel.generatePassword()
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                        .font(.footnote)
                        .foregroundStyle(.tint)
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
                    // 簡易的な遷移（TabViewの仕様による）
                    // 実際にはBindingやEnvironmentObjectでタブを切り替える実装が必要
                    // ここでは一旦リセットのみとする
                }
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
