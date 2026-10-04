import AppKit
import Foundation
import SwiftTerm

@MainActor
final class TerminalController: NSObject {
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
        terminalView.font = NSFont.monospacedSystemFont(ofSize: 13.0, weight: .regular)
        terminalView.translatesAutoresizingMaskIntoConstraints = false
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
