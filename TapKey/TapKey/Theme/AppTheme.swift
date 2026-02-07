import SwiftUI

// MARK: - TapKey Design System

enum AppTheme {
    // MARK: Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "06B6D4"), Color(hex: "3B82F6")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color(hex: "1E1B4B").opacity(0.08), Color(hex: "312E81").opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lockGradient = LinearGradient(
        colors: [Color(hex: "0F172A"), Color(hex: "1E1B4B"), Color(hex: "312E81")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let buttonGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: Colors
    static let accent = Color(hex: "6366F1")
    static let accentLight = Color(hex: "818CF8")
    static let surface = Color(hex: "F8FAFC")
    static let surfaceDark = Color(hex: "1E293B")
    
    // MARK: Spacing
    static let cornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom View Modifiers

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var disabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                disabled ? AnyShapeStyle(Color.gray.opacity(0.4)) : AnyShapeStyle(AppTheme.buttonGradient)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ServiceInitialsView: View {
    let title: String
    let size: CGFloat
    
    private var initials: String {
        let words = title.prefix(2)
        return String(words).uppercased()
    }
    
    private var color: Color {
        let colors: [Color] = [
            Color(hex: "6366F1"),
            Color(hex: "EC4899"),
            Color(hex: "F59E0B"),
            Color(hex: "10B981"),
            Color(hex: "3B82F6"),
            Color(hex: "8B5CF6"),
            Color(hex: "EF4444"),
            Color(hex: "06B6D4"),
        ]
        let hash = title.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[hash % colors.count]
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Text(initials)
                .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
