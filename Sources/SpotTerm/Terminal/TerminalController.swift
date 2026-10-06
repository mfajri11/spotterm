import AppKit
import Foundation
import SwiftTerm

@MainActor
final class TerminalController: NSObject {
    // Soft off-white (~91% luminance, #E8EAED): crisp & clear without 100% piercing white glare
    static let softWhiteTextColor = NSColor(red: 0.91, green: 0.92, blue: 0.93, alpha: 1.0)
    static let softDarkTextColor = NSColor(red: 0.16, green: 0.17, blue: 0.18, alpha: 1.0)

    let terminalView: LocalProcessTerminalView
    var onProcessTerminated: ((Int32?) -> Void)?
    var onTitleChanged: ((String) -> Void)?
    private(set) var hasActiveProcess: Bool = false

    override init() {
        self.terminalView = LocalProcessTerminalView(frame: .zero)
        super.init()
        setupTerminalView()
    }

    private func setupTerminalView() {
        terminalView.processDelegate = self
        terminalView.nativeBackgroundColor = .clear
        terminalView.nativeForegroundColor = Self.softWhiteTextColor
        terminalView.caretColor = Self.softWhiteTextColor.withAlphaComponent(0.85)
        terminalView.font = NSFont.monospacedSystemFont(ofSize: 13.0, weight: .regular)
        terminalView.translatesAutoresizingMaskIntoConstraints = false
        setupContextMenu()
    }

    private func setupContextMenu() {
        let menu = NSMenu(title: "Terminal")
        menu.delegate = self

        let copyItem = NSMenuItem(
            title: "Copy",
            action: #selector(contextCopyAction),
            keyEquivalent: "c"
        )
        copyItem.target = self
        menu.addItem(copyItem)

        let pasteItem = NSMenuItem(
            title: "Paste",
            action: #selector(contextPasteAction),
            keyEquivalent: "v"
        )
        pasteItem.target = self
        menu.addItem(pasteItem)

        let selectAllItem = NSMenuItem(
            title: "Select All",
            action: #selector(contextSelectAllAction),
            keyEquivalent: "a"
        )
        selectAllItem.target = self
        menu.addItem(selectAllItem)

        menu.addItem(NSMenuItem.separator())

        let clearItem = NSMenuItem(
            title: "Clear Screen",
            action: #selector(contextClearAction),
            keyEquivalent: "k"
        )
        clearItem.target = self
        menu.addItem(clearItem)

        let resetItem = NSMenuItem(
            title: "Reset Session",
            action: #selector(contextResetAction),
            keyEquivalent: "r"
        )
        resetItem.target = self
        menu.addItem(resetItem)

        terminalView.menu = menu
    }

    func applyAppearance(isDark: Bool) {
        let fgColor = isDark ? Self.softWhiteTextColor : Self.softDarkTextColor
        terminalView.nativeForegroundColor = fgColor
        terminalView.caretColor = fgColor.withAlphaComponent(0.85)
    }

    func startShellSession() {
        let shell = ShellEnvironment.resolveShell()
        let env = ShellEnvironment.buildEnvironment()
        let workingDirectory = ShellEnvironment.defaultWorkingDirectory()

        terminalView.startProcess(
            executable: shell,
            args: ["-l"],
            environment: env,
            execName: nil,
            currentDirectory: workingDirectory
        )
        hasActiveProcess = true
    }

    func restartSession() {
        startShellSession()
    }

    func terminateProcess() {
        terminalView.process.terminate()
        hasActiveProcess = false
    }

    func clearScreen() {
        terminalView.clearScrollback()
        terminalView.feed(text: "\u{1b}[3J\u{1b}[H\u{1b}[2J")
        terminalView.scroll(toPosition: 0.0)
        terminalView.needsDisplay = true
        terminalView.send(txt: "\u{000c}")
    }

    func clearBuffer() {
        clearScreen()
    }

    func copySelection() {
        guard let selection = terminalView.selection, selection.active else { return }
        let text = selection.getSelectedText()
        guard !text.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func pasteClipboard() {
        terminalView.paste(self)
    }

    func selectAllText() {
        terminalView.selectAll(self)
    }

    func focus() {
        terminalView.window?.makeFirstResponder(terminalView)
    }

    @objc private func contextCopyAction() {
        copySelection()
    }

    @objc private func contextPasteAction() {
        pasteClipboard()
    }

    @objc private func contextSelectAllAction() {
        selectAllText()
    }

    @objc private func contextClearAction() {
        clearScreen()
    }

    @objc private func contextResetAction() {
        restartSession()
    }
}

extension TerminalController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        for item in menu.items {
            switch item.action {
            case #selector(contextCopyAction):
                let hasSelection = terminalView.selection?.active == true
                let hasText = !(terminalView.selection?.getSelectedText().isEmpty ?? true)
                item.isEnabled = hasSelection && hasText
            case #selector(contextPasteAction):
                item.isEnabled = NSPasteboard.general.string(forType: .string)?.isEmpty == false
            case #selector(contextSelectAllAction),
                 #selector(contextClearAction),
                 #selector(contextResetAction):
                item.isEnabled = true
            default:
                break
            }
        }
    }
}

extension TerminalController: @preconcurrency LocalProcessTerminalViewDelegate {
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        onTitleChanged?(title)
    }

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        hasActiveProcess = false
        onProcessTerminated?(exitCode)
    }
}
