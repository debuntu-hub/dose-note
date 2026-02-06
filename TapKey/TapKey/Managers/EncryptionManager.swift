import Foundation
import CryptoKit

enum EncryptionError: Error {
    case keyNotReady
}

class EncryptionManager {
    static let shared = EncryptionManager()
    private var symmetricKey: SymmetricKey?
    
    private init() {}
    
    // アプリロック時などにメモリ上のキーを破棄する
    func clearKey() {
        self.symmetricKey = nil
    }
    
    // キーの準備（なければ生成して保存、あればロード）
    func prepareKey() throws {
        // すでにロード済みなら何もしない
        if symmetricKey != nil { return }
        
        do {
            let keyData = try KeychainHelper.shared.loadKey()
            self.symmetricKey = SymmetricKey(data: keyData)
        } catch KeychainError.notFound {
            // 新規生成
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            try KeychainHelper.shared.saveKey(keyData)
            self.symmetricKey = newKey
        } catch {
            throw error
        }
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
