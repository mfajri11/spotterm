import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enable: Bool) throws {
        if enable {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        }
    }

    func toggle() throws -> Bool {
        let newState = !isEnabled
        try setEnabled(newState)
        return newState
    }
}
