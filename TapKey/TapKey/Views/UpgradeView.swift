import SwiftUI

/// アップグレード案内画面 (§8.6)
/// 保存件数上限到達時に表示
struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("TapKey Premium")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("無料プランの保存上限（\(PurchaseManager.freeLimit)件）に達しました")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                // 機能一覧
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "infinity", text: "パスワード保存件数 無制限", highlight: true)
                    FeatureRow(icon: "rectangle.and.pencil.and.ellipsis", text: "iOS Password AutoFill（将来）", highlight: false)
                    FeatureRow(icon: "number.circle", text: "TOTP 2段階認証（将来）", highlight: false)
                    FeatureRow(icon: "square.and.arrow.up", text: "エクスポート / インポート（将来）", highlight: false)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 買い切り価格表示
                if let product = purchaseManager.product {
                    Text("買い切り \(product.displayPrice)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("一度の購入で永久に使えます。サブスクリプションではありません。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // 購入ボタン
                Button(action: {
                    Task { await purchaseManager.purchase() }
                }) {
                    if purchaseManager.isPurchasing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("Premium を購入")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .disabled(purchaseManager.isPurchasing || purchaseManager.product == nil)
                .padding(.horizontal, 32)
                
                // 復元ボタン
                Button("購入を復元") {
                    Task { await purchaseManager.restorePurchases() }
                }
                .font(.caption)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .onChange(of: purchaseManager.isPremium) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let highlight: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(highlight ? .blue : .secondary)
                .frame(width: 24)
            Text(text)
                .font(.body)
                .foregroundStyle(highlight ? .primary : .secondary)
        }
    }
}
