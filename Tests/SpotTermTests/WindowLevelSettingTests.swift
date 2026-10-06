import AppKit
@testable import SpotTerm
import Testing

struct WindowLevelSettingTests {
    @Test func windowLevelsMatchExpectedAppKitLevels() {
        #expect(WindowLevelSetting.floating.windowLevel == .floating)
        #expect(WindowLevelSetting.screenSaver.windowLevel == .screenSaver)
    }

    @Test func allCasesContainExpectedTitles() {
        for setting in WindowLevelSetting.allCases {
            #expect(!setting.title.isEmpty)
        }
    }

    @Test func settingsWindowLevelIsHigherThanHUDLevel() {
        for setting in WindowLevelSetting.allCases {
            let higherLevel = NSWindow.Level(setting.windowLevel.rawValue + 1)
            #expect(higherLevel.rawValue > setting.windowLevel.rawValue)
        }
    }
}
