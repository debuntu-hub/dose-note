import SwiftUI

struct LockView: View {
    var manager: BiometricManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            Text("TapKey is Locked")
                .font(.title)
                .bold()
            
            if let error = manager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Button(action: {
                manager.unlock()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: 200)
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            // 画面表示時に自動で認証を試みる
            // 少し遅延させないとViewの描画と衝突してプロンプトが出ないことがある
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if manager.isLocked {
                    manager.unlock()
                }
            }
        }
    }
}
