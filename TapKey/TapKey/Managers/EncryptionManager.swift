import Foundation
import CryptoKit

enum EncryptionError: Error {
    case keyNotReady
}

class EncryptionManager {
    static let shared = EncryptionManager()
    private var symmetricKey: SymmetricKey?
    
    /// Keychainへの保存時に生体認証ACLを付与するか（BiometricManagerから設定される）
    var requireBiometricForKeychain: Bool = false
    
    /// セッション中にキーのACL再保存を行ったかどうか
    private var hasReSavedACL = false
    
    private init() {}
    
    // アプリロック時などにメモリ上のキーを破棄する
    func clearKey() {
        self.symmetricKey = nil
        self.hasReSavedACL = false
    }
    
    // キーの準備（なければ生成して保存、あればロード）
    func prepareKey() throws {
        // すでにロード済みなら何もしない
        if symmetricKey != nil { return }
        
        do {
            let keyData = try KeychainHelper.shared.loadKey()
            self.symmetricKey = SymmetricKey(data: keyData)
            
            // ACLマイグレーション: 現在の設定に合わせてキーを再保存（セッション中1回のみ）
            if !hasReSavedACL {
                hasReSavedACL = true
                KeychainHelper.shared.deleteKey()
                try KeychainHelper.shared.saveKey(keyData, requireBiometric: requireBiometricForKeychain)
            }
        } catch KeychainError.notFound {
            // 新規生成
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            try KeychainHelper.shared.saveKey(keyData, requireBiometric: requireBiometricForKeychain)
            self.symmetricKey = newKey
            hasReSavedACL = true
        } catch {
            throw error
        }
    }
    
    /// 生体認証トグル変更時にキーのACLを切り替える
    func reSaveKey(requireBiometric: Bool) throws {
        try prepareKey()
        guard let key = symmetricKey else { return }
        let keyData = key.withUnsafeBytes { Data($0) }
        KeychainHelper.shared.deleteKey()
        try KeychainHelper.shared.saveKey(keyData, requireBiometric: requireBiometric)
        self.requireBiometricForKeychain = requireBiometric
        hasReSavedACL = true
    }
    
    func encrypt(_ data: Data) throws -> Data {
        if symmetricKey == nil {
            try prepareKey()
        }
        
        guard let key = symmetricKey else {
            throw EncryptionError.keyNotReady
        }
        
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.keyNotReady
        }
        return combined
    }
    
    func decrypt(_ combinedData: Data) throws -> Data {
        if symmetricKey == nil {
            try prepareKey()
        }
        
        guard let key = symmetricKey else {
            throw EncryptionError.keyNotReady
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }
}
