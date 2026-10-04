import AppKit

@MainActor
protocol StatusBarDelegate: AnyObject {
    var currentHotkeyPreset: HotkeyPreset { get }
    var currentWindowLevel: WindowLevelSetting { get }
    var isDismissOnOutsideClickEnabled: Bool { get }
    var isDismissOnEscapeEnabled: Bool { get }
    var isLaunchAtLoginEnabled: Bool { get }

    func didRequestToggleHUD()
    func didRequestOpenSettings()
    func didRequestResetShell()
    func didRequestClearBuffer()
    func didSelectWindowLevel(_ level: WindowLevelSetting)
    func didSelectHotkeyPreset(_ preset: HotkeyPreset)
    func didToggleDismissOnOutsideClick()
    func didToggleDismissOnEscape()
    func didToggleLaunchAtLogin()
    func didRequestQuit()
}

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private weak var delegate: StatusBarDelegate?
    private let menu = NSMenu()

    init(delegate: StatusBarDelegate) {
        self.delegate = delegate
        super.init()
        setupStatusItem()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let image = NSImage(
                systemSymbolName: "apple.terminal.fill",
                accessibilityDescription: "SpotTerm"
            )
            image?.isTemplate = true
            button.image = image
            button.toolTip = "SpotTerm - Floating Terminal HUD"
        }
        item.menu = menu
        menu.delegate = self
        self.statusItem = item
        rebuildMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
    }

    private func rebuildMenu() {
        menu.removeAllItems()
        guard let delegate else { return }

        let toggleTitle = "Toggle SpotTerm (\(delegate.currentHotkeyPreset.shortDisplay))"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleHUDAction), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())

        addShellActions()
        menu.addItem(.separator())
        addSettingsSubmenus(delegate: delegate)
        addBehaviorToggles(delegate: delegate)
        menu.addItem(.separator())
        addLaunchAtLogin(delegate: delegate)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit SpotTerm", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    private func addShellActions() {
        let resetItem = NSMenuItem(
            title: "Reset Shell Session",
            action: #selector(resetShellAction),
            keyEquivalent: "r"
        )
        resetItem.target = self
        menu.addItem(resetItem)

        let clearItem = NSMenuItem(
            title: "Clear Terminal Buffer",
            action: #selector(clearBufferAction),
            keyEquivalent: "k"
        )
        clearItem.target = self
        menu.addItem(clearItem)
    }

    private func addSettingsSubmenus(delegate: StatusBarDelegate) {
        let levelMenu = NSMenu()
        for level in WindowLevelSetting.allCases {
            let item = NSMenuItem(title: level.title, action: #selector(selectLevelAction(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = level
            item.state = (level == delegate.currentWindowLevel) ? .on : .off
            levelMenu.addItem(item)
        }
        let levelParent = NSMenuItem(title: "Window Level", action: nil, keyEquivalent: "")
        levelParent.submenu = levelMenu
        menu.addItem(levelParent)

        let hotkeyMenu = NSMenu()
        for preset in HotkeyPreset.allCases {
            let item = NSMenuItem(title: preset.title, action: #selector(selectHotkeyAction(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = preset
            item.state = (preset == delegate.currentHotkeyPreset) ? .on : .off
            hotkeyMenu.addItem(item)
        }
        let hotkeyParent = NSMenuItem(title: "Global Hotkey", action: nil, keyEquivalent: "")
        hotkeyParent.submenu = hotkeyMenu
        menu.addItem(hotkeyParent)
    }

    private func addBehaviorToggles(delegate: StatusBarDelegate) {
        let outsideItem = NSMenuItem(
            title: "Dismiss on Outside Click",
            action: #selector(toggleOutsideClickAction),
            keyEquivalent: ""
        )
        outsideItem.target = self
        outsideItem.state = delegate.isDismissOnOutsideClickEnabled ? .on : .off
        menu.addItem(outsideItem)

        let escItem = NSMenuItem(
            title: "Dismiss on Escape",
            action: #selector(toggleEscapeAction),
            keyEquivalent: ""
        )
        escItem.target = self
        escItem.state = delegate.isDismissOnEscapeEnabled ? .on : .off
        menu.addItem(escItem)
    }

    private func addLaunchAtLogin(delegate: StatusBarDelegate) {
        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLoginAction),
            keyEquivalent: ""
        )
        loginItem.target = self
        loginItem.state = delegate.isLaunchAtLoginEnabled ? .on : .off
        menu.addItem(loginItem)
    }

    @objc private func toggleHUDAction() {
        delegate?.didRequestToggleHUD()
    }

    @objc private func openSettingsAction() {
        delegate?.didRequestOpenSettings()
    }

    @objc private func resetShellAction() {
        delegate?.didRequestResetShell()
    }

    @objc private func clearBufferAction() {
        delegate?.didRequestClearBuffer()
    }

    @objc private func selectLevelAction(_ sender: NSMenuItem) {
        guard let level = sender.representedObject as? WindowLevelSetting else { return }
        delegate?.didSelectWindowLevel(level)
    }

    @objc private func selectHotkeyAction(_ sender: NSMenuItem) {
        guard let preset = sender.representedObject as? HotkeyPreset else { return }
        delegate?.didSelectHotkeyPreset(preset)
    }

    @objc private func toggleOutsideClickAction() {
        delegate?.didToggleDismissOnOutsideClick()
    }

    @objc private func toggleEscapeAction() {
        delegate?.didToggleDismissOnEscape()
    }

    @objc private func toggleLaunchAtLoginAction() {
        delegate?.didToggleLaunchAtLogin()
    }

    @objc private func quitAction() {
        delegate?.didRequestQuit()
    }
}
