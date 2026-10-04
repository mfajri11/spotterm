import Foundation
@testable import SpotTerm
import Testing

struct SpotTermErrorTests {
    @Test func localizedDescriptionsAreAccurate() {
        let shellError = SpotTermError.shellExecutableNotFound(path: "/custom/bad/path")
        #expect(shellError.errorDescription?.contains("/custom/bad/path") == true)

        let hotkeyError = SpotTermError.hotkeyRegistrationFailed(osStatus: -9800)
        #expect(hotkeyError.errorDescription?.contains("-9800") == true)

        let handlerError = SpotTermError.eventHandlerInstallationFailed(osStatus: -9801)
        #expect(handlerError.errorDescription?.contains("-9801") == true)

        let loginError = SpotTermError.loginItemFailed(reason: "Permission denied")
        #expect(loginError.errorDescription?.contains("Permission denied") == true)
    }

    @Test func errorEquatableConformance() {
        let err1 = SpotTermError.hotkeyRegistrationFailed(osStatus: 42)
        let err2 = SpotTermError.hotkeyRegistrationFailed(osStatus: 42)
        let err3 = SpotTermError.hotkeyRegistrationFailed(osStatus: 99)

        #expect(err1 == err2)
        #expect(err1 != err3)
    }
}
