import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isAnimating = false
    
    var body: some View {
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
                .fill(AppTheme.accent.opacity(0.06))
                .frame(width: 350, height: 350)
                .offset(x: 150, y: -300)
                .blur(radius: 80)
            
            Circle()
                .fill(Color(hex: "8B5CF6").opacity(0.08))
                .frame(width: 280, height: 280)
                .offset(x: -130, y: 300)
                .blur(radius: 60)
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 20, x: 0, y: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
                    
                    Image(systemName: "key.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isAnimating ? 0 : -30))
                        .animation(.spring(response: 0.8, dampingFraction: 0.5), value: isAnimating)
                }
                
                VStack(spacing: 12) {
                    Text("TapKey")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("考えずに作って、すぐ保存")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 18) {
                    OnboardingRow(
                        icon: "wand.and.stars",
                        text: "起動すると、安全なパスワードがすでに生成されています",
                        color: Color(hex: "F59E0B")
                    )
                    OnboardingRow(
                        icon: "doc.on.doc",
                        text: "コピーして使い、名前を付けて保存するだけ",
                        color: Color(hex: "10B981")
                    )
                    OnboardingRow(
                        icon: "lock.shield",
                        text: "すべてのデータは端末内に暗号化して保存",
                        color: AppTheme.accent
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: {
                    hasCompletedOnboarding = true
                }) {
                    Text("すぐ始める")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct OnboardingRow: View {
    let icon: String
    let text: String
    var color: Color = .blue
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}
