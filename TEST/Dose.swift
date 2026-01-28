import Foundation

struct Dose: Identifiable, Codable {
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
