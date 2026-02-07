import Foundation
import SwiftData
import SwiftUI

@Observable
class HomeViewModel {
    var passwords: [PasswordEntry] = []
    var serviceName: String = ""
    var username: String = ""
    var note: String = ""
    
    var isSaved: Bool = false
    var showAlert: Bool = false
    var alertMessage: String = ""
    var showUpgrade: Bool = false
    
    /// よく使うメールアドレス候補
    var recentUsernames: [String] = []
    
    private static let recentUsernamesKey = "tapkey_recent_usernames"
    private static let maxRecentUsernames = 10
    
    init() {
        // 起動時に自動生成（メインパスワード1つ）
        passwords = [PasswordEntry(label: "パスワード", value: PasswordGenerator.generate())]
        // よく使うメールアドレスを読み込み
        loadRecentUsernames()
    }
    
    func loadRecentUsernames() {
        recentUsernames = UserDefaults.standard.stringArray(forKey: Self.recentUsernamesKey) ?? []
    }
    
    /// 既存の保存済みVaultItemからユーザー名を収集して候補リストに追加
    func seedUsernamesFromVault(_ items: [VaultItem]) {
        var currentList = UserDefaults.standard.stringArray(forKey: Self.recentUsernamesKey) ?? []
        var added = false
        
        for item in items {
            guard let decryptedData = try? EncryptionManager.shared.decrypt(item.encryptedData),
                  let payload = try? JSONDecoder().decode(SecretPayload.self, from: decryptedData) else {
                continue
            }
            let name = payload.username.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty, !currentList.contains(name) else { continue }
            currentList.append(name)
            added = true
        }
        
        if added {
            // 上限を超えたら古いものを削除
            if currentList.count > Self.maxRecentUsernames {
                currentList = Array(currentList.prefix(Self.maxRecentUsernames))
            }
            UserDefaults.standard.set(currentList, forKey: Self.recentUsernamesKey)
            recentUsernames = currentList
        }
    }
    
    /// 使用したユーザー名を履歴に追加（使用頻度順に並替え）
    private func saveUsernameToRecent(_ name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var list = UserDefaults.standard.stringArray(forKey: Self.recentUsernamesKey) ?? []
        // 既存エントリを削除して先頭に挿入（最近使った順）
        list.removeAll { $0 == name }
        list.insert(name, at: 0)
        // 上限を超えたら古いものを削除
        if list.count > Self.maxRecentUsernames {
            list = Array(list.prefix(Self.maxRecentUsernames))
        }
        UserDefaults.standard.set(list, forKey: Self.recentUsernamesKey)
        recentUsernames = list
    }
    
    /// メインパスワード（最初のエントリ）
    var primaryPassword: String {
        passwords.first?.value ?? ""
    }
    
    func generatePassword(at index: Int = 0) {
        guard passwords.indices.contains(index) else { return }
        passwords[index].value = PasswordGenerator.generate()
        self.isSaved = false
    }
    
    func addPassword(label: String = "パスワード") {
        let newEntry = PasswordEntry(label: label, value: PasswordGenerator.generate())
        passwords.append(newEntry)
    }
    
    func removePassword(at index: Int) {
        guard passwords.count > 1, passwords.indices.contains(index) else { return }
        passwords.remove(at: index)
    }
    
    func copyPassword(at index: Int = 0) {
        guard passwords.indices.contains(index) else { return }
        ClipboardManager.shared.copy(passwords[index].value)
    }
    
    func copyUsername() {
        ClipboardManager.shared.copy(username)
    }
    
    func save(modelContext: ModelContext) {
        guard !serviceName.isEmpty else {
            alertMessage = "サービス名を入力してください"
            showAlert = true
            return
        }
        
        // 保存件数チェック (§8.3: 無料10件制限)
        let descriptor = FetchDescriptor<VaultItem>()
        let currentCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard PurchaseManager.shared.canSave(currentCount: currentCount) else {
            showUpgrade = true
            return
        }
        
        do {
            let payload = SecretPayload(username: username, passwords: passwords, note: note)
            let jsonData = try JSONEncoder().encode(payload)
            let encryptedData = try EncryptionManager.shared.encrypt(jsonData)
            
            let newItem = VaultItem(title: serviceName, encryptedData: encryptedData)
            modelContext.insert(newItem)
            
            // 成功時の処理
            isSaved = true
            saveUsernameToRecent(username)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // 保存完了後は遷移またはクリア（仕様に合わせて調整）
            // 今回はv0.1仕様「保存完了 -> 一覧に即反映」
            // 実際は画面遷移が必要だが、まずは保存完了ステートを変更
            
        } catch {
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showAlert = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    // UIのリセット（保存後など）
    func reset() {
        serviceName = ""
        username = ""
        note = ""
        passwords = [PasswordEntry(label: "パスワード", value: PasswordGenerator.generate())]
        isSaved = false
    }
}
