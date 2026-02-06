import Foundation
import SwiftData

@Model
final class VaultItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var encryptedData: Data
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, encryptedData: Data) {
        self.id = UUID()
        self.title = title
        self.encryptedData = encryptedData
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
