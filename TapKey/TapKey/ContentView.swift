//
//  ContentView.swift
//  TapKey
//
//  Created by 友清秀和 on 2026/02/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("Generate", systemImage: "key.fill")
                }
                .tag(0)
            
            VaultListView()
                .tabItem {
                    Label("Vault", systemImage: "tray.full.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
