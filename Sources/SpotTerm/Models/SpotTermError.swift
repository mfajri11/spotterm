import Foundation

enum SpotTermError: Error, LocalizedError, Sendable, Equatable {
    case shellExecutableNotFound(path: String)
    case hotkeyRegistrationFailed(osStatus: Int32)
    case eventHandlerInstallationFailed(osStatus: Int32)
    case loginItemFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .shellExecutableNotFound(let path):
            return "Shell executable was not found or is not executable at path: \(path)"
        case .hotkeyRegistrationFailed(let osStatus):
            return "Failed to register global hotkey with Carbon OSStatus: \(osStatus)"
        case .eventHandlerInstallationFailed(let osStatus):
            return "Failed to install Carbon event handler with OSStatus: \(osStatus)"
        case .loginItemFailed(let reason):
            return "Launch at Login operation failed: \(reason)"
        }
    }
}
