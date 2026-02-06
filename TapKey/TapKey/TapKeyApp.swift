//
//  TapKeyApp.swift
//  TapKey
//
//  Created by 友清秀和 on 2026/02/06.
//

import SwiftUI
import SwiftData

@main
struct TapKeyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var biometricManager = BiometricManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VaultItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    ContentView()
                        .environment(biometricManager)
                    
                    if biometricManager.isLocked {
                        LockView(manager: biometricManager)
                            .transition(.opacity)
                            .zIndex(100)
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .background:
                // バックグラウンド移行時に即ロック＆クリップボードクリア
                biometricManager.lock()
                ClipboardManager.shared.clearNow()
            case .inactive:
                // アプリスイッチャー表示中などは画面を隠すためにロック状態へ
                // ただし、バックグラウンドではないのでクリップボードクリアまではしないかもしれないが
                // 安全側に倒してロックはする
                biometricManager.lock()
            case .active:
                // 復帰時に自動認証を試みる処理はLockView.onAppearで行う
                break
            @unknown default:
                break
            }
        }
    }
}
