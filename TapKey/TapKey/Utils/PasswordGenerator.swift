import Foundation

struct PasswordGenerator {
    // 視認性の悪い文字（l, I, 1, O, 0）を除外した文字セット
    private static let characters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%^&*"
    
    static func generate(length: Int = 16) -> String {
        return String((0..<length).map { _ in characters.randomElement()! })
    }
}
