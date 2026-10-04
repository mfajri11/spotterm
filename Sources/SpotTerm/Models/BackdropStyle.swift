import Foundation

enum BackdropStyle: String, CaseIterable, Sendable {
    case frostedGlass
    case translucent
    case solid

    var title: String {
        switch self {
        case .frostedGlass:
            return "Frosted Glass (Blur)"
        case .translucent:
            return "Translucent (Blur + Tint)"
        case .solid:
            return "Solid / Classic Terminal (100% Opaque)"
        }
    }

    var defaultOpacity: Double {
        switch self {
        case .frostedGlass:
            return 0.70
        case .translucent:
            return 0.85
        case .solid:
            return 1.00
        }
    }
}
