import AppKit
import Foundation
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

    @Test @MainActor func terminalControllerClearScreenAndBufferExecution() {
        let controller = TerminalController()
        controller.terminalView.feed(text: "Prompt line 1\r\nPrompt line 2\r\n")
        controller.clearScreen()
        controller.clearBuffer()

        let terminal = controller.terminalView.getTerminal()
        #expect(terminal.buffer.x == 0)
        #expect(terminal.buffer.y == 0)
    }

    @Test @MainActor func terminalControllerCopyAndPasteBehavior() {
        let controller = TerminalController()
        let pasteboard = NSPasteboard.general

        // Before any selection, copySelection should not overwrite existing clipboard
        pasteboard.clearContents()
        pasteboard.setString("Preserved Clipboard", forType: .string)
        controller.copySelection()
        #expect(pasteboard.string(forType: .string) == "Preserved Clipboard")

        // Feed some text and select all
        controller.terminalView.feed(text: "Hello SpotTerm\r\n")
        controller.selectAllText()
        controller.copySelection()

        // Clipboard should now contain selected text
        let copied = pasteboard.string(forType: .string)
        #expect(copied?.contains("Hello SpotTerm") == true)

        // Paste should execute cleanly without error
        controller.pasteClipboard()
    }

    @Test @MainActor func terminalControllerContextMenuItems() {
        let controller = TerminalController()
        guard let menu = controller.terminalView.menu else {
            Issue.record("Expected terminalView to have context menu")
            return
        }

        let titles = menu.items.map(\.title)
        #expect(titles.contains("Copy"))
        #expect(titles.contains("Paste"))
        #expect(titles.contains("Select All"))
        #expect(titles.contains("Clear Screen"))
        #expect(titles.contains("Reset Session"))
    }
}
