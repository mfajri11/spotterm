import AppKit
@testable import SpotTerm
import Testing

struct TerminalControllerTests {
    @Test @MainActor func softWhiteTextColorAttributes() {
        let color = TerminalController.softWhiteTextColor
        guard let srgb = color.usingColorSpace(.sRGB) else {
            Issue.record("Expected sRGB convertible color")
            return
        }

        // Must be in soft-white range: >= 0.88 (not dimmed) and <= 0.95 (not glaringly/piercingly 100% white)
        #expect(srgb.redComponent >= 0.88 && srgb.redComponent <= 0.95)
        #expect(srgb.greenComponent >= 0.88 && srgb.greenComponent <= 0.95)
        #expect(srgb.blueComponent >= 0.88 && srgb.blueComponent <= 0.95)
        #expect(srgb.alphaComponent == 1.0)
    }

    @Test @MainActor func softDarkTextColorAttributes() {
        let color = TerminalController.softDarkTextColor
        guard let srgb = color.usingColorSpace(.sRGB) else {
            Issue.record("Expected sRGB convertible color")
            return
        }

        #expect(srgb.redComponent >= 0.10 && srgb.redComponent <= 0.25)
        #expect(srgb.alphaComponent == 1.0)
    }

    @Test @MainActor func terminalControllerAppliesSoftWhiteInDarkMode() {
        let controller = TerminalController()
        controller.applyAppearance(isDark: true)
        #expect(controller.terminalView.nativeForegroundColor == TerminalController.softWhiteTextColor)
    }

    @Test @MainActor func terminalControllerAppliesDarkInLightMode() {
        let controller = TerminalController()
        controller.applyAppearance(isDark: false)
        #expect(controller.terminalView.nativeForegroundColor == TerminalController.softDarkTextColor)
    }
}
