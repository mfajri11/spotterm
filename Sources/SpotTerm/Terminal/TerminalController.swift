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

    func clearBuffer() {
        terminalView.send(txt: "\u{000c}")
    }

    func focus() {
        terminalView.window?.makeFirstResponder(terminalView)
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
