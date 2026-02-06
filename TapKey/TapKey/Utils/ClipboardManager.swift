import Foundation
import UIKit

/// クリップボード管理ユーティリティ
/// 仕様§2.4: コピー後、指定秒数で自動クリア
class ClipboardManager {
    static let shared = ClipboardManager()
    
    private var clearTimer: Timer?
    
    private init() {}
    
    /// クリップボードにコピーし、設定秒数後に自動クリア
    func copy(_ text: String) {
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        scheduleClear()
    }
    
    /// 即時クリア
    func clearNow() {
        clearTimer?.invalidate()
        clearTimer = nil
        UIPasteboard.general.string = ""
    }
    
    /// 設定秒数後にクリアするタイマーをセット
    private func scheduleClear() {
        clearTimer?.invalidate()
        let seconds = UserDefaults.standard.integer(forKey: "clipboardClearSeconds")
        let interval = TimeInterval(seconds > 0 ? seconds : 30) // デフォルト30秒
        
        clearTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            UIPasteboard.general.string = ""
            self?.clearTimer = nil
        }
    }
}
