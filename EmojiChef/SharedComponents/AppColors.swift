import SwiftUI

// MARK: - Color Theme Manager
struct AppColors {
    static func cardBack(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.indigo.opacity(0.8) : Color.blue
    }
    
    static func cardMatched(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.green.opacity(0.4) : Color.green.opacity(0.3)
    }
    
    static func selectedCharacter(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2)
    }
    
    static func surfaceBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(.systemGray6) : Color.gray.opacity(0.1)
    }
    
    static func cardFaceUp(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(.systemGray5) : Color.white
    }
}
