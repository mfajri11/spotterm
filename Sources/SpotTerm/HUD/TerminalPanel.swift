import AppKit

final class TerminalPanel: NSPanel {
    var onEscapePressed: (() -> Void)?
    var onSettingsShortcutPressed: (() -> Void)?
    var onQuitShortcutPressed: (() -> Void)?
    var onResetShortcutPressed: (() -> Void)?

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

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.modifierFlags.contains(.command) else {
            return super.performKeyEquivalent(with: event)
        }
        if event.charactersIgnoringModifiers == "," {
            onSettingsShortcutPressed?()
            return true
        }
        if event.charactersIgnoringModifiers == "q" {
            onQuitShortcutPressed?()
            return true
        }
        if event.charactersIgnoringModifiers == "r" {
            onResetShortcutPressed?()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}
