import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: "key.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Title
            Text("考えずに作って、すぐ保存")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                OnboardingRow(
                    icon: "wand.and.stars",
                    text: "起動すると、安全なパスワードがすでに生成されています"
                )
                OnboardingRow(
                    icon: "doc.on.doc",
                    text: "コピーして使い、名前を付けて保存するだけ"
                )
                OnboardingRow(
                    icon: "lock.shield",
                    text: "すべてのデータは端末内に暗号化して保存"
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("すぐ始める")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

struct OnboardingRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}
