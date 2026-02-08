import SwiftUI

struct LockView: View {
    var manager: BiometricManager
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
                .fill(AppTheme.accent.opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .blur(radius: 60)
            
            Circle()
                .fill(Color(hex: "8B5CF6").opacity(0.1))
                .frame(width: 250, height: 250)
                .offset(x: 120, y: 200)
                .blur(radius: 50)
            
            VStack(spacing: 36) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 2).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Circle()
                        .fill(AppTheme.accent.opacity(0.08))
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.15 : 0.95)
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "818CF8"), Color(hex: "6366F1")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("TapKey")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("ロックされています")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                if let error = manager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.red.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Button(action: {
                    manager.unlock()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.title3)
                        Text("ロック解除")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 260)
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
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isAnimating = true
            // ユーザーが「ロック解除」ボタンをタップするまでFaceIDを自動起動しない
        }
    }
}
