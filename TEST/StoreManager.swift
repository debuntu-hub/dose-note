import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class StoreManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    
    // Product IDs (Must match App Store Connect)
    private let productDict: [String: String]
    
    init() {
        // Initialize with your product IDs
        self.productDict = [
            "premium_monthly": "com.tomokiyoshuuwa.TEST.premium.monthly",
            "premium_yearly": "com.tomokiyoshuuwa.TEST.premium.yearly"
        ]
        
        // Check initial entitlement
        Task {
            await updateCustomerProductStatus()
            await requestProducts()
        }
    }
    
    // MARK: - Purchasing
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is verified
            let transaction = try checkVerified(verification)
            
            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            // Always finish a transaction.
            await transaction.finish()
            
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateCustomerProductStatus()
    }
    
    // MARK: - Status Updates
    
    func updateCustomerProductStatus() async {
        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn't, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                // Check the type of product to the user.
                switch transaction.productType {
                case .autoRenewable:
                    if transaction.revocationDate == nil {
                        // The subscription is active.
                        isPremium = true
                        return // Found valid subscription
                    }
                default:
                    break
                }
            } catch {
                print(error)
            }
        }
        
        // If we get here, no valid subscription found
        isPremium = false
    }
    
    private func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productDict.keys)
            // Sort by price for display
            products = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to request products: \(error)")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
