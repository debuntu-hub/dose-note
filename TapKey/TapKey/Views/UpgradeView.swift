import SwiftUI
import StoreKit

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "0F172A"),
                        Color(hex: "1E1B4B"),
                        Color(hex: "312E81")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Circle()
                    .fill(Color(hex: "F59E0B").opacity(0.06))
                    .frame(width: 300, height: 300)
                    .offset(x: 130, y: -250)
                    .blur(radius: 70)
                
                ScrollView {
                    VStack(spacing: 28) {
                        Spacer(minLength: 20)
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "F59E0B").opacity(0.15))
                                .frame(width: 120, height: 120)
                                .scaleEffect(isAnimating ? 1.08 : 1.0)
                                .animation(
                                    .easeInOut(duration: 2).repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(hex: "F59E0B").opacity(0.3), radius: 10)
                        }
                        
                        VStack(spacing: 8) {
                            Text("TapKey Premium")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("保存上限（\(PurchaseManager.freeLimit)件）を解除")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        VStack(spacing: 16) {
                            PremiumFeatureRow(icon: "infinity", text: "パスワード保存 無制限", active: true)
                        }
                        .padding(.horizontal, 8)
                        
                        Spacer(minLength: 10)
                        
                        if let product = purchaseManager.product {
                            VStack(spacing: 4) {
                                Text("買い切り \(product.displayPrice)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("一度の購入で永久に使えます")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                        
                        Button(action: {
                            Task { await purchaseManager.purchase() }
                        }) {
                            if purchaseManager.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            } else {
                                Text("Premium を購入")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "1E1B4B"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            }
                        }
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "F59E0B").opacity(0.3), radius: 12, x: 0, y: 6)
                        .disabled(purchaseManager.isPurchasing || purchaseManager.product == nil)
                        .padding(.horizontal, 8)
                        
                        Button("購入を復元") {
                            Task { await purchaseManager.restorePurchases() }
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .onChange(of: purchaseManager.isPremium) { _, newValue in
                if newValue { dismiss() }
            }
            .onAppear { isAnimating = true }
        }
    }
}

private struct PremiumFeatureRow: View {
    let icon: String
    let text: String
    let active: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(active ? Color(hex: "F59E0B") : .white.opacity(0.3))
                .frame(width: 28)
            
            Text(text)
                .font(.body)
                .foregroundStyle(active ? .white : .white.opacity(0.3))
            
            Spacer()
            
            if !active {
                Text("将来")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.white.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(active ? 0.08 : 0.03))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
