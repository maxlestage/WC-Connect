import SwiftUI

/// Palette et petits helpers d'interface communs à l'iPhone, la Watch et les widgets.
public enum WCTheme {
    public static let accent = Color(red: 0.20, green: 0.66, blue: 0.97)
    public static let accentDeep = Color(red: 0.11, green: 0.40, blue: 0.78)
    public static let mint = Color(red: 0.24, green: 0.80, blue: 0.68)
    public static let warn = Color(red: 0.98, green: 0.71, blue: 0.24)

    public static var gradient: LinearGradient {
        LinearGradient(colors: [accent, accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    public static func color(for kind: SessionKind) -> Color {
        switch kind {
        case .quick: return mint
        case .standard: return accent
        case .long: return warn
        }
    }
}
