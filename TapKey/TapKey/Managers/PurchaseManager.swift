import Foundation
import StoreKit

/// TapKey 課金管理 (§8 収益化設計)
/// フリーミアム + 買い切り課金（1回課金）
@Observable
class PurchaseManager {
    static let shared = PurchaseManager()
    
    /// 無料プランの保存上限
    nonisolated static let freeLimit = 10
    
    /// 買い切り製品ID
    nonisolated static let premiumProductID = "com.tapkey.app.premium"
    
    /// プレミアム解放済みか
    var isPremium: Bool = false
    
    /// StoreKit製品
    var product: Product?
    
    /// 購入中フラグ
    var isPurchasing: Bool = false
    
    /// エラーメッセージ
    var errorMessage: String?
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        // 購入状態の復元
        isPremium = UserDefaults.standard.bool(forKey: "tapkey_premium_unlocked")
        
        // トランザクション監視
        transactionListener = listenForTransactions()
        
        // 製品情報取得
        Task { await loadProduct() }
        
        // 購入履歴の確認
        Task { await checkPurchaseHistory() }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// 保存可能かどうか判定
    func canSave(currentCount: Int) -> Bool {
        if isPremium { return true }
        return currentCount < PurchaseManager.freeLimit
    }
    
    /// 残り保存可能件数
    func remainingSlots(currentCount: Int) -> Int {
        if isPremium { return Int.max }
        return max(0, PurchaseManager.freeLimit - currentCount)
    }
    
    // MARK: - StoreKit
    
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [PurchaseManager.premiumProductID])
            await MainActor.run {
                self.product = products.first
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "製品情報の取得に失敗しました"
            }
        }
    }
    
    func purchase() async {
        guard let product = product else { return }
        
        await MainActor.run { isPurchasing = true }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await MainActor.run {
                    isPremium = true
                    UserDefaults.standard.set(true, forKey: "tapkey_premium_unlocked")
                    isPurchasing = false
                }
            case .userCancelled:
                await MainActor.run { isPurchasing = false }
            case .pending:
                await MainActor.run { isPurchasing = false }
            @unknown default:
                await MainActor.run { isPurchasing = false }
            }
        } catch {
            await MainActor.run {
                errorMessage = "購入に失敗しました"
                isPurchasing = false
            }
        }
    }
    
    func restorePurchases() async {
        await checkPurchaseHistory()
    }
    
    // MARK: - Private
    
    private func checkPurchaseHistory() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == PurchaseManager.premiumProductID {
                    await MainActor.run {
                        isPremium = true
                        UserDefaults.standard.set(true, forKey: "tapkey_premium_unlocked")
                    }
                }
            }
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == PurchaseManager.premiumProductID {
                        await MainActor.run {
                            self.isPremium = true
                            UserDefaults.standard.set(true, forKey: "tapkey_premium_unlocked")
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    enum StoreError: Error {
        case verificationFailed
    }
}
