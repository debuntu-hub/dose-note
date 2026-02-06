import Foundation
import LocalAuthentication
import UIKit

@Observable
class BiometricManager {
    var isLocked: Bool = true
    var errorMessage: String? = nil
    
    // シングルトン化も検討できるが、@ObservableなのでEnvironmentで渡すか、
    // App構造体でStateObject的に持つのが良い
    
    func unlock() {
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
        isLocked = true
        EncryptionManager.shared.clearKey()
    }
}
