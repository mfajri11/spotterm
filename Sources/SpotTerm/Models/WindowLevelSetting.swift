import AppKit

enum WindowLevelSetting: String, CaseIterable, Sendable {
    case floating
    case screenSaver

    var title: String {
        switch self {
        case .floating:
            return "Standard Float (.floating)"
        case .screenSaver:
            return "Above Full-Screen Apps (.screenSaver)"
        }
    }

    var windowLevel: NSWindow.Level {
        switch self {
        case .floating:
            return .floating
        case .screenSaver:
            return .screenSaver
        }
    }
}
