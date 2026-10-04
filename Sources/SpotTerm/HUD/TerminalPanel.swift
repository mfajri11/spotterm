import AppKit

final class TerminalPanel: NSPanel {
    var onEscapePressed: (() -> Void)?

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        false
    }

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        configurePanel()
    }

    private func configurePanel() {
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .screenSaver

        collectionBehavior = [
            .canJoinAllSpaces,
            .canJoinAllApplications,
            .fullScreenAuxiliary,
            .transient,
            .ignoresCycle
        ]
    }

    override func cancelOperation(_ sender: Any?) {
        if let onEscapePressed {
            onEscapePressed()
        } else {
            super.cancelOperation(sender)
        }
    }
}
