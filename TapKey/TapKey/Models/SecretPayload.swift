import Foundation

/// パスワードエントリ（ラベル付き）
struct PasswordEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var label: String   // 例: "ログインパスワード", "PIN", "秘密の質問"
    var value: String   // パスワード本体
}

struct SecretPayload: Codable {
    var username: String
    var passwords: [PasswordEntry]  // 複数パスワード対応
    var note: String
    
    // MARK: - 後方互換性（旧フォーマットからの読み込み）
    
    enum CodingKeys: String, CodingKey {
        case username, password, passwords, note
    }
    
    init(username: String, passwords: [PasswordEntry], note: String) {
        self.username = username
        self.passwords = passwords
        self.note = note
    }
    
    /// 旧フォーマット互換コンストラクタ（単一パスワード）
    init(username: String, password: String, note: String) {
        self.username = username
        self.passwords = [PasswordEntry(label: "パスワード", value: password)]
        self.note = note
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        note = try container.decode(String.self, forKey: .note)
        
        // 新フォーマット（passwords配列）を試行、失敗したら旧フォーマット（password単一）にフォールバック
        if let pwArray = try? container.decode([PasswordEntry].self, forKey: .passwords) {
            passwords = pwArray
        } else if let singlePW = try? container.decode(String.self, forKey: .password) {
            passwords = [PasswordEntry(label: "パスワード", value: singlePW)]
        } else {
            passwords = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(passwords, forKey: .passwords)
        try container.encode(note, forKey: .note)
    }
    
    /// 便利アクセサ: メインパスワード（最初のエントリ）
    var primaryPassword: String {
        passwords.first?.value ?? ""
    }
}
