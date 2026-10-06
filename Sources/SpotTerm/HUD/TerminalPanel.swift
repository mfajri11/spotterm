import AppKit

final class TerminalPanel: NSPanel {
    var onEscapePressed: (() -> Void)?
    var onSettingsShortcutPressed: (() -> Void)?
    var onQuitShortcutPressed: (() -> Void)?
    var onResetShortcutPressed: (() -> Void)?
    var onClearShortcutPressed: (() -> Void)?
    var onCopyShortcutPressed: (() -> Void)?
    var onPasteShortcutPressed: (() -> Void)?
    var onSelectAllShortcutPressed: (() -> Void)?

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
        let flags = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard flags == .command, let char = event.charactersIgnoringModifiers?.lowercased() else {
            return super.performKeyEquivalent(with: event)
        }
        if handleCommandShortcut(character: char) {
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    private func handleCommandShortcut(character: String) -> Bool {
        switch character {
        case ",":
            onSettingsShortcutPressed?()
            return true
        case "q":
            onQuitShortcutPressed?()
            return true
        case "r":
            onResetShortcutPressed?()
            return true
        case "k":
            onClearShortcutPressed?()
            return true
        case "c":
            return dispatchShortcut(onCopyShortcutPressed)
        case "v":
            return dispatchShortcut(onPasteShortcutPressed)
        case "a":
            return dispatchShortcut(onSelectAllShortcutPressed)
        default:
            return false
        }
    }

    private func dispatchShortcut(_ action: (() -> Void)?) -> Bool {
        guard let action else { return false }
        action()
        return true
    }
}
