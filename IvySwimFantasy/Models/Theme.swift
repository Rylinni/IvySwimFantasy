import SwiftUI

struct AppTheme {
    // Sleeper-inspired dark theme colors
    static let background = Color(hex: "#1A1A2E")
    static let cardBackground = Color(hex: "#252542")
    static let cardBackgroundLight = Color(hex: "#2D2D4A")
    static let accent = Color(hex: "#00D4AA")
    static let accentSecondary = Color(hex: "#7C5CFF")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#8E8E9A")
    static let textMuted = Color(hex: "#5C5C6E")
    static let success = Color(hex: "#00D4AA")
    static let warning = Color(hex: "#FFB800")
    static let error = Color(hex: "#FF4757")
    static let gold = Color(hex: "#FFD700")
    static let silver = Color(hex: "#C0C0C0")
    static let bronze = Color(hex: "#CD7F32")

    static let avatarColors: [Color] = [
        Color(hex: "#FF6B6B"),
        Color(hex: "#4ECDC4"),
        Color(hex: "#45B7D1"),
        Color(hex: "#96CEB4"),
        Color(hex: "#FFEAA7"),
        Color(hex: "#DDA0DD"),
        Color(hex: "#98D8C8"),
        Color(hex: "#F7DC6F"),
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
    }
}

struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.accent)
            .foregroundColor(AppTheme.background)
            .cornerRadius(12)
            .fontWeight(.semibold)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
