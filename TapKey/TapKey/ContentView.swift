import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("生成", systemImage: "wand.and.stars")
                }
                .tag(0)
            
            VaultListView()
                .tabItem {
                    Label("保管庫", systemImage: "lock.shield.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    ContentView()
}
