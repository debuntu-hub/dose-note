import Foundation

// nonisolated: @MainActor デフォルト分離の影響を受けないようにし、
// Codable の合成メソッド (init(from:) / encode(to:)) が
// JSONEncoder/JSONDecoder から安全に呼び出せるようにする
nonisolated struct Dose: Identifiable, Codable, Sendable {
    let id: UUID
    var date: Date
    
    // Helper to format date for display
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日(E) H:mm"
        return formatter.string(from: date)
    }
}
