#!/usr/bin/env python3
"""Write all redesigned TapKey view files."""
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # workspace root
TAPKEY = os.path.join(BASE, "TapKey", "TapKey")

files = {}

# LockView
files[os.path.join(TAPKEY, "Views", "LockView.swift")] = r'''import SwiftUI

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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if manager.isLocked {
                    manager.unlock()
                }
            }
        }
    }
}
'''

# OnboardingView
files[os.path.join(TAPKEY, "Views", "OnboardingView.swift")] = r'''import SwiftUI

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
'''

# VaultListView
files[os.path.join(TAPKEY, "Views", "VaultListView.swift")] = r'''import SwiftUI
import SwiftData

struct VaultListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VaultItem.createdAt, order: .reverse) private var items: [VaultItem]
    @State private var searchText = ""
    @State private var copiedItemId: UUID?
    
    var filteredItems: [VaultItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "key.slash")
                            .font(.system(size: 56))
                            .foregroundStyle(AppTheme.accent.opacity(0.3))
                        
                        Text("パスワードがまだありません")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("ホーム画面でパスワードを生成して\n保存しましょう")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: VaultDetailView(item: item)) {
                                HStack(spacing: 14) {
                                    ServiceInitialsView(title: item.title, size: 44)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.title)
                                            .font(.body.weight(.semibold))
                                        Text(item.createdAt.formatted(date: .numeric, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        copyPassword(for: item)
                                    }) {
                                        Image(systemName: copiedItemId == item.id ? "checkmark.circle.fill" : "doc.on.doc")
                                            .font(.body)
                                            .foregroundStyle(copiedItemId == item.id ? .green : AppTheme.accent)
                                            .padding(8)
                                            .background(
                                                (copiedItemId == item.id ? Color.green : AppTheme.accent).opacity(0.1)
                                            )
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteItems(item)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    copyUsername(for: item)
                                } label: {
                                    Label("IDコピー", systemImage: "person.crop.circle")
                                }
                                .tint(AppTheme.accent)
                            }
                        }
                        
                        if !searchText.isEmpty && filteredItems.isEmpty {
                            ContentUnavailableView.search
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("保管庫")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "サービス名で検索")
        }
    }
    
    private func deleteItems(_ item: VaultItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
    
    private func copyPassword(for item: VaultItem) {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let payload = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            ClipboardManager.shared.copy(payload.primaryPassword)
            withAnimation(.spring(response: 0.3)) {
                copiedItemId = item.id
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring(response: 0.3)) {
                    if copiedItemId == item.id {
                        copiedItemId = nil
                    }
                }
            }
        } catch {
        }
    }
    
    private func copyUsername(for item: VaultItem) {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let payload = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            ClipboardManager.shared.copy(payload.username)
        } catch {
        }
    }
}

#Preview {
    VaultListView()
        .modelContainer(for: VaultItem.self, inMemory: true)
}
'''

# VaultDetailView
files[os.path.join(TAPKEY, "Views", "VaultDetailView.swift")] = r'''import SwiftUI
import SwiftData

struct VaultDetailView: View {
    let item: VaultItem
    @State private var payload: SecretPayload?
    @State private var errorMessage: String?
    @State private var visiblePasswords: Set<UUID> = []
    @State private var showEditSheet: Bool = false
    @State private var copiedId: UUID?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    ServiceInitialsView(title: item.title, size: 64)
                    
                    Text(item.title)
                        .font(.title2.weight(.bold))
                    
                    if let payload = payload {
                        Text(payload.username)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .glassCard()
                
                if let payload = payload {
                    VStack(spacing: 0) {
                        // Username row
                        HStack(spacing: 14) {
                            Image(systemName: "person.fill")
                                .font(.callout)
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ユーザーID")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(payload.username)
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                ClipboardManager.shared.copy(payload.username)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.callout)
                                    .foregroundStyle(AppTheme.accent)
                                    .padding(6)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        ForEach(payload.passwords) { entry in
                            Divider().padding(.leading, 48)
                            
                            HStack(spacing: 14) {
                                Image(systemName: "key.fill")
                                    .font(.callout)
                                    .foregroundStyle(AppTheme.accent)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    if payload.passwords.count > 1 {
                                        Text(entry.label)
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.accentLight)
                                    }
                                    
                                    if visiblePasswords.contains(entry.id) {
                                        Text(entry.value)
                                            .font(.system(.body, design: .monospaced))
                                    } else {
                                        Text(String(repeating: "\u{2022}", count: 16))
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.2)) {
                                        if visiblePasswords.contains(entry.id) {
                                            visiblePasswords.remove(entry.id)
                                        } else {
                                            visiblePasswords.insert(entry.id)
                                        }
                                    }
                                }) {
                                    Image(systemName: visiblePasswords.contains(entry.id) ? "eye.slash" : "eye")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                        .padding(6)
                                }
                                
                                Button(action: {
                                    ClipboardManager.shared.copy(entry.value)
                                    withAnimation(.spring(response: 0.2)) {
                                        copiedId = entry.id
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { copiedId = nil }
                                    }
                                }) {
                                    Image(systemName: copiedId == entry.id ? "checkmark.circle.fill" : "doc.on.doc")
                                        .font(.callout)
                                        .foregroundStyle(copiedId == entry.id ? .green : AppTheme.accent)
                                        .padding(6)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        
                        if !payload.note.isEmpty {
                            Divider().padding(.leading, 48)
                            
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: "note.text")
                                    .font(.callout)
                                    .foregroundStyle(.orange)
                                    .frame(width: 24)
                                
                                Text(payload.note)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    
                } else if let error = errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        Text("復号に失敗しました")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .glassCard()
                } else {
                    ProgressView("復号中...")
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .glassCard()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { showEditSheet = true }) {
                Text("編集")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditVaultItemView(item: item)
        }
        .onChange(of: item.updatedAt) { _, _ in
            loadData()
        }
        .task {
            loadData()
        }
    }
    
    private func loadData() {
        do {
            let decryptedData = try EncryptionManager.shared.decrypt(item.encryptedData)
            let decoded = try JSONDecoder().decode(SecretPayload.self, from: decryptedData)
            self.payload = decoded
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
'''

# SettingsView
files[os.path.join(TAPKEY, "Views", "SettingsView.swift")] = r'''import SwiftUI

struct SettingsView: View {
    @AppStorage("clipboardClearSeconds") private var clipboardClearSeconds: Int = 30
    @AppStorage("autoLockSeconds") private var autoLockSeconds: Int = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    let clipboardOptions = [10, 15, 30, 60, 90, 120]
    let autoLockOptions = [0, 5, 15, 30, 60, 300]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "faceid", color: Color(hex: "10B981"))
                        Text("生体認証ロック")
                        Spacer()
                        Text("ON")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(.green.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "lock.fill", color: AppTheme.accent)
                        Picker("自動ロック", selection: $autoLockSeconds) {
                            ForEach(autoLockOptions, id: \.self) { sec in
                                Text(autoLockLabel(sec)).tag(sec)
                            }
                        }
                    }
                } header: {
                    Label("セキュリティ", systemImage: "shield.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                
                Section {
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "clipboard.fill", color: Color(hex: "F59E0B"))
                        Picker("自動クリア", selection: $clipboardClearSeconds) {
                            ForEach(clipboardOptions, id: \.self) { sec in
                                Text("\(sec)秒").tag(sec)
                            }
                        }
                    }
                    
                    Text("コピー後、指定秒数でクリップボードを自動クリアします")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .listRowBackground(Color.clear)
                } header: {
                    Label("クリップボード", systemImage: "doc.on.clipboard.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "F59E0B"))
                }
                
                Section {
                    HStack(spacing: 14) {
                        SettingsIcon(icon: "square.and.arrow.up", color: .secondary)
                        Text("エクスポート / インポート")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("v1.0")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                } header: {
                    Label("データ管理", systemImage: "cylinder.split.1x2.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    InfoRow(label: "バージョン", value: "v0.1")
                    InfoRow(label: "データ保存", value: "ローカルのみ")
                    InfoRow(label: "暗号化", value: "AES-256-GCM")
                } header: {
                    Label("アプリ情報", systemImage: "info.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        HStack(spacing: 14) {
                            SettingsIcon(icon: "questionmark.circle", color: Color(hex: "8B5CF6"))
                            Text("ガイダンスを再表示")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("設定")
        }
    }
    
    private func autoLockLabel(_ seconds: Int) -> String {
        switch seconds {
        case 0: return "即時"
        case 5: return "5秒"
        case 15: return "15秒"
        case 30: return "30秒"
        case 60: return "1分"
        case 300: return "5分"
        default: return "\(seconds)秒"
        }
    }
}

private struct SettingsIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.callout)
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
'''

# UpgradeView
files[os.path.join(TAPKEY, "Views", "UpgradeView.swift")] = r'''import SwiftUI
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
                            PremiumFeatureRow(icon: "rectangle.and.pencil.and.ellipsis", text: "iOS Password AutoFill", active: false)
                            PremiumFeatureRow(icon: "number.circle", text: "TOTP 2段階認証", active: false)
                            PremiumFeatureRow(icon: "square.and.arrow.up", text: "エクスポート / インポート", active: false)
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
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content.lstrip('\n'))
    print(f"OK: {os.path.relpath(path, BASE)}")

print("\nAll files written successfully!")
