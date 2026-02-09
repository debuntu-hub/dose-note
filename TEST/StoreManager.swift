import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class StoreManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    @Published var errorMessage: String? = nil
    @Published var purchaseErrorMessage: String? = nil
    @Published var isPurchasing: Bool = false
    @Published var debugStatus: String = "Ready" // For debugging
    
    // Product IDs (Must match App Store Connect)
    private let productDict: [String: String]
    
    private var updateListenerTask: Task<Void, Error>? = nil

    init() {
        // Initialize with your product IDs
        self.productDict = [
            "premium_monthly": "com.tomokiyoshuuwa.dosenote.premium.monthly",
            "premium_yearly": "com.tomokiyoshuuwa.dosenote.premium.yearly"
        ]
        
        // Start a transaction listener as close to app launch as possible
        updateListenerTask = listenForTransactions()
        
        // Check initial entitlement
        Task {
            await updateCustomerProductStatus()
            await requestProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // The transaction is verified. Deliver content to the user.
                    await self.updateCustomerProductStatus()
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed")
                }
            }
        }
    }
    
    // MARK: - Purchasing
    
    func purchase(_ product: Product) async throws {
        debugStatus = "Starting purchase..."
        
        // Prevent multiple simultaneous purchase attempts
        guard !isPurchasing else {
            print("[StoreManager] Purchase already in progress")
            return
        }
        
        isPurchasing = true
        purchaseErrorMessage = nil
        debugStatus = "Purchasing..."
        
        // Ensure isPurchasing is reset after the function returns (even if it throws)
        defer {
            isPurchasing = false
            print("[StoreManager] Purchase flow ended")
            // Do NOT overwrite debugStatus here, so we can see the result (Success/Failed/Cancelled)
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("[StoreManager] Purchase result: success")
                debugStatus = "Purchase success. Verifying..."
                
                // Check if the transaction is verified
                let transaction = try checkVerified(verification)
                
                // TRUST THE TRANSACTION IMMEDIATELY
                self.isPremium = true 
                self.debugStatus = "Purchase confirmed. Updating Entitlements..."

                // The transaction is verified. Deliver content to the user.
                await updateCustomerProductStatus()
                
                // Always finish a transaction.
                await transaction.finish()
                print("[StoreManager] Transaction finished successfully")
                debugStatus = "Transaction finished. Premium: \(isPremium)"
                
            case .userCancelled:
                print("[StoreManager] Purchase result: userCancelled")
                debugStatus = "Result: User Cancelled (Check StoreKit config)"
                break
            case .pending:
                print("[StoreManager] Purchase result: pending")
                debugStatus = "Result: Pending (Parental control?)"
                break
            @unknown default:
                print("[StoreManager] Purchase result: unknown")
                debugStatus = "Result: Unknown"
                break
            }
        } catch {
            print("[StoreManager] Purchase error: \(error.localizedDescription)")
            // Update error message so the View can display it
            self.purchaseErrorMessage = error.localizedDescription
            debugStatus = "Error: \(error.localizedDescription)"
            self.purchaseErrorMessage = error.localizedDescription
            throw error
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateCustomerProductStatus()
    }
    
    // MARK: - Status Updates
    
    func updateCustomerProductStatus() async {
        // Iterate through all of the user's purchased products.
        var foundActive = false
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn't, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                print("[StoreManager] Found entitlement: \(transaction.productID), type: \(transaction.productType)")
                
                // Check if matches our products OR is autoRenewable
                if (transaction.productType == .autoRenewable || self.productDict.values.contains(transaction.productID)) && transaction.revocationDate == nil {
                     foundActive = true
                     // Continue loop to print all, or break? Let's break if found.
                     break
                }
            } catch {
                print(error)
            }
        }
        
        let finalStatus = foundActive
        self.isPremium = finalStatus
        print("[StoreManager] updateCustomerProductStatus complete. isPremium: \(finalStatus)")
    }
    
    func requestProducts() async {
        print("[StoreManager] Requesting products: \(productDict.values)")
        do {
            let storeProducts = try await Product.products(for: productDict.values)
            print("[StoreManager] Products fetched: \(storeProducts.map { $0.id })")
            // Sort by price for display
            products = storeProducts.sorted(by: { $0.price < $1.price })
            
            if products.isEmpty {
                print("[StoreManager] No products found matching IDs")
                errorMessage = "No products found. Expected: \(productDict.values.joined(separator: ", "))"
            } else {
                errorMessage = nil
            }
        } catch {
            print("Failed to request products: \(error)")
            errorMessage = error.localizedDescription
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
