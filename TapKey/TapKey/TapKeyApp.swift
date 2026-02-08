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
                    
                    if biometricManager.isBiometricEnabled && biometricManager.isLocked {
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
                // FaceID/TouchIDダイアログ表示時もinactiveになるため、
                // ここでlock()すると認証が2重に要求されるバグが発生する。
                // ロックはbackground遷移時のみとする。
                break
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
}
