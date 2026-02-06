import Foundation
import Security
import LocalAuthentication

enum KeychainError: Error {
    case accessControlSetupFailed
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case notFound
    case invalidData
}

class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.tapkey.app.keys"
    private let account = "master_key"
    
    private init() {}
    
    func saveKey(_ data: Data) throws {
        // 生体認証が必要なACL設定
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryAny, // FaceID / TouchID 必須
            &error
        ) else {
            throw KeychainError.accessControlSetupFailed
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: accessControl
        ]
        
        // 既存削除（上書きのため）
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    func loadKey() throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
            // kSecUseOperationPrompt is deprecated, but kSecUseAuthenticationContext requires more setup.
            // For MVP v0.1 targeting iOS 17, using BiometricManager to trigger context is safer or ignore prompt here
            // as accessControl handles it implicitly on read.
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.notFound
            }
            throw KeychainError.loadFailed(status: status)
        }
        
        guard let data = item as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    func deleteKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
