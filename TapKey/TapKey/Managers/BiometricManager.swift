import Foundation
import LocalAuthentication
import UIKit

@Observable
class BiometricManager {
    var isLocked: Bool = true
    var errorMessage: String? = nil
    
    /// 生体認証ロックの有効/無効設定（UserDefaultsで永続化）
    var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isBiometricEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "isBiometricEnabled")
            if !newValue {
                // OFFにしたら即ロック解除
                isLocked = false
            }
        }
    }
    
    init() {
        // 初回起動時はデフォルトON
        if UserDefaults.standard.object(forKey: "isBiometricEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "isBiometricEnabled")
        }
        // 生体認証が無効ならロック解除状態で開始
        if !isBiometricEnabled {
            isLocked = false
        }
    }
    
    func unlock() {
        // 生体認証がOFFなら即解除（Keychain認証をスキップ）
        guard isBiometricEnabled else {
            self.isLocked = false
            self.errorMessage = nil
            return
        }
        
        // キーの準備（Keychainアクセス）を試みることで認証とする
        // EncryptionManagerがKeychainにアクセスする際、アクセス制御によりFaceID/TouchIDが求められる
        do {
            try EncryptionManager.shared.prepareKey()
            self.isLocked = false
            self.errorMessage = nil
            // 成功時のHaptics
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Unlock failed: \(error)")
            self.errorMessage = "認証できませんでした。もう一度お試しください。"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    func lock() {
        // 生体認証が無効ならロックしない
        guard isBiometricEnabled else { return }
        isLocked = true
        EncryptionManager.shared.clearKey()
    }
}
