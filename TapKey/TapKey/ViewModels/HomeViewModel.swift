import Foundation
import SwiftData
import SwiftUI

@Observable
class HomeViewModel {
    var password: String = ""
    var serviceName: String = ""
    var username: String = ""
    var note: String = ""
    
    var isSaved: Bool = false
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    init() {
        // 起動時に自動生成
        generatePassword()
    }
    
    func generatePassword() {
        self.password = PasswordGenerator.generate()
        self.isSaved = false
    }
    
    func copyPassword() {
        UIPasteboard.general.string = password
    }
    
    func copyUsername() {
        UIPasteboard.general.string = username
    }
    
    func save(modelContext: ModelContext) {
        guard !serviceName.isEmpty else {
            alertMessage = "サービス名を入力してください"
            showAlert = true
            return
        }
        
        do {
            let payload = SecretPayload(username: username, password: password, note: note)
            let jsonData = try JSONEncoder().encode(payload)
            let encryptedData = try EncryptionManager.shared.encrypt(jsonData)
            
            let newItem = VaultItem(title: serviceName, encryptedData: encryptedData)
            modelContext.insert(newItem)
            
            // 成功時の処理
            isSaved = true
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
        generatePassword()
        isSaved = false
    }
}
