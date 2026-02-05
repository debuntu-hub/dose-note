import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    var store: DoseStore?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header Image/Icon
                VStack(spacing: 20) {
                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.yellow)
                        .padding(.top, 40)
                    
                    Text("Premium Plan".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Premium Desc".localized)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                
                // Comparison Table
                VStack(spacing: 0) {
                    benefitRow(title: "History Access".localized, free: "Recent 30 Days".localized, premium: "Unlimited".localized)
                    Divider()
                    benefitRow(title: "Avg Interval Display".localized, free: "Not Included".localized, premium: "Included".localized)
                    Divider()
                    benefitRow(title: "All Time Stats".localized, free: "Not Included".localized, premium: "Included".localized)
                    Divider()
                    benefitRow(title: "Ad Free".localized, free: "None".localized, premium: "None".localized)
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Plans
                if let errorMessage = storeManager.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Failed to load plans")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await storeManager.requestProducts()
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 4)
                    }
                    .padding()
                } else {
                    // Debug info (Hidden in production, useful for TestFlight)
                    // Text("Products: \(storeManager.products.count)")
                    //    .font(.caption2)
                    //    .foregroundStyle(.tertiary)
                    
                    ForEach(storeManager.products) { product in
                        Button(action: {
                            print("[PaywallView] Button tapped for product: \(product.id)")
                            Task {
                                do {
                                    try await storeManager.purchase(product)
                                } catch {
                                    // Error is handled in StoreManager and exposed via errorMessage
                                    print("Purchase failed: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.displayName)
                                        .font(.headline)
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                
                                if storeManager.isPurchasing {
                                    ProgressView()
                                } else {
                                    Text(product.displayPrice)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        }
                        .disabled(storeManager.isPurchasing)
                        .padding(.horizontal)
                    }
                }
                
                // Disclaimer
                VStack(spacing: 10) {
                    Text("Disclaimer Title".localized)
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("Disclaimer Text".localized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        
                    // Subscription Info & Links
                    VStack(spacing: 8) {
                        Text("Auto Renew Title".localized)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        Text("Auto Renew Text".localized)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            
                        HStack(spacing: 20) {
                            Link("Terms".localized, destination: URL(string: "https://github.com/debuntu-hub/dose-note/blob/main/docs/TERMS.md")!)
                            Link("Privacy".localized, destination: URL(string: "https://github.com/debuntu-hub/dose-note/blob/main/docs/PRIVACY.md")!)
                        }
                        .font(.caption)
                        .padding(.top, 5)
                        
                        Link("Manage Sub".localized, destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                            .font(.caption)
                            .padding(.top, 2)
                            
                        // Debug Status (Temporary for troubleshooting)
                        Text(storeManager.debugStatus)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Restore & Cancel
                VStack(spacing: 20) {
                    HStack {
                        Button("Restore".localized) {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }
                        .font(.caption)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            
                        Button("Close".localized) {
                            dismiss()
                        }
                        .font(.caption)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onChange(of: storeManager.isPremium) { newValue in
            if newValue {
                print("[PaywallView] Premium status active. Dismissing.")
                dismiss()
            }
        }
        .onChange(of: storeManager.purchaseErrorMessage) { newValue in
            if newValue != nil {
                print("[PaywallView] Purchase error detected: \(newValue ?? "")")
            }
        }
        .alert("Purchase Failed", isPresented: Binding<Bool>(
            get: { storeManager.purchaseErrorMessage != nil },
            set: { if !$0 { storeManager.purchaseErrorMessage = nil } }
        ), actions: {
            Button("OK", role: .cancel) { storeManager.purchaseErrorMessage = nil }
        }, message: {
            Text(storeManager.purchaseErrorMessage ?? "Unknown Error")
        })
    }
    
    private func benefitRow(title: String, free: String, premium: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(free)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 80)
            
            Text(premium)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 80)
        }
        .padding()
    }
}
