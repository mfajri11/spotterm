import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let panel = TerminalPanel(contentRect: NSRect(x: 0, y: 0, width: 820, height: 500))
    private let backdropView = BackdropView(frame: .zero)
    private let terminalController = TerminalController()
    private let hotkeyManager = GlobalHotkeyManager()
    private let loginService = LaunchAtLoginService()
    private lazy var settingsController = SettingsWindowController(delegate: self)

    private var outsideClickMonitor: Any?

    private(set) var currentHotkeyPreset: HotkeyPreset = .optionSpace
    private(set) var currentWindowLevel: WindowLevelSetting = .screenSaver
    private(set) var currentBackdropStyle: BackdropStyle = .frostedGlass
    private(set) var currentBackdropOpacity: Double = 0.70
    private(set) var isDismissOnOutsideClickEnabled: Bool = true
    private(set) var isDismissOnEscapeEnabled: Bool = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupBackdropAndTerminal()
        setupPanelCallbacks()
        setupTerminalCallbacks()
        setupHotkey()
        terminalController.startShellSession()
        summonHUD()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopOutsideClickMonitoring()
        hotkeyManager.teardown()
        terminalController.terminateProcess()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        summonHUD()
        return true
    }

    private func setupBackdropAndTerminal() {
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = backdropView

        let terminal = terminalController.terminalView
        backdropView.addSubview(terminal)

        NSLayoutConstraint.activate([
            terminal.leadingAnchor.constraint(equalTo: backdropView.leadingAnchor, constant: 12.0),
            terminal.trailingAnchor.constraint(equalTo: backdropView.trailingAnchor, constant: -12.0),
            terminal.bottomAnchor.constraint(equalTo: backdropView.bottomAnchor, constant: -12.0),
            terminal.topAnchor.constraint(equalTo: backdropView.topAnchor, constant: 32.0)
        ])

        backdropView.updateAppearanceSettings(
            style: currentBackdropStyle,
            opacity: currentBackdropOpacity
        )

        backdropView.onSettingsClicked = { [weak self] in
            self?.settingsController.showSettings()
        }
        backdropView.onResetClicked = { [weak self] in
            self?.terminalController.restartSession()
        }
        backdropView.onQuitClicked = { [weak self] in
            self?.didRequestQuit()
        }
    }

    private func setupPanelCallbacks() {
        panel.onEscapePressed = { [weak self] in
            guard let self, self.isDismissOnEscapeEnabled else { return }
            self.dismissHUD()
        }
        panel.onSettingsShortcutPressed = { [weak self] in
            self?.settingsController.showSettings()
        }
        panel.onQuitShortcutPressed = { [weak self] in
            self?.didRequestQuit()
        }
        panel.onResetShortcutPressed = { [weak self] in
            self?.terminalController.restartSession()
        }
    }

    private func setupTerminalCallbacks() {
        terminalController.onProcessTerminated = { [weak self] _ in
            guard let self else { return }
            self.dismissHUD()
            self.terminalController.restartSession()
        }
    }

    private func setupHotkey() {
        hotkeyManager.onHotKeyTriggered = { [weak self] in
            self?.toggleHUD()
        }
        do {
            try hotkeyManager.startListening()
        } catch {
            NSLog("Failed to register initial hotkey: \(error.localizedDescription)")
        }
    }

    func toggleHUD() {
        if panel.isVisible && panel.isKeyWindow {
            dismissHUD()
        } else {
            summonHUD()
        }
    }

    func summonHUD() {
        guard let screen = ScreenLocator.targetScreen(
            for: NSEvent.mouseLocation,
            availableScreens: NSScreen.screens
        ) else { return }

        let targetFrame = ScreenLocator.calculatePanelFrame(on: screen)
        panel.setFrame(targetFrame, display: true)
        panel.level = currentWindowLevel.windowLevel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        terminalController.focus()

        startOutsideClickMonitoring()
    }

    func dismissHUD() {
        stopOutsideClickMonitoring()
        panel.orderOut(nil)
    }

    private func startOutsideClickMonitoring() {
        guard outsideClickMonitor == nil, isDismissOnOutsideClickEnabled else { return }
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            guard let self else { return }
            let clickLocation = NSEvent.mouseLocation
            if !self.panel.frame.contains(clickLocation) {
                self.dismissHUD()
            }
        }
    }

    private func stopOutsideClickMonitoring() {
        if let outsideClickMonitor {
            NSEvent.removeMonitor(outsideClickMonitor)
            self.outsideClickMonitor = nil
        }
    }
}

extension AppDelegate: SettingsWindowDelegate {
    var isLaunchAtLoginEnabled: Bool {
        loginService.isEnabled
    }

    func didToggleLaunchAtLogin() {
        do {
            _ = try loginService.toggle()
        } catch {
            NSLog("Failed to toggle Launch at Login: \(error.localizedDescription)")
        }
    }

    func didSelectHotkeyPreset(_ preset: HotkeyPreset) {
        do {
            try hotkeyManager.updatePreset(preset)
            currentHotkeyPreset = preset
        } catch {
            NSLog("Failed to change hotkey: \(error.localizedDescription)")
        }
    }

    func didSelectWindowLevel(_ level: WindowLevelSetting) {
        currentWindowLevel = level
        panel.level = level.windowLevel
    }

    func didSelectBackdropStyle(_ style: BackdropStyle) {
        currentBackdropStyle = style
        currentBackdropOpacity = style.defaultOpacity
        backdropView.updateAppearanceSettings(style: style, opacity: currentBackdropOpacity)
    }

    func didChangeBackdropOpacity(_ opacity: Double) {
        currentBackdropOpacity = opacity
        backdropView.updateAppearanceSettings(style: currentBackdropStyle, opacity: opacity)
    }

    func didToggleDismissOnOutsideClick() {
        isDismissOnOutsideClickEnabled.toggle()
        if !isDismissOnOutsideClickEnabled {
            stopOutsideClickMonitoring()
        } else if panel.isVisible {
            startOutsideClickMonitoring()
        }
    }

    func didToggleDismissOnEscape() {
        isDismissOnEscapeEnabled.toggle()
    }

    func didRequestResetShell() {
        terminalController.restartSession()
    }

    func didRequestQuit() {
        stopOutsideClickMonitoring()
        hotkeyManager.teardown()
        terminalController.terminateProcess()
        NSApp.terminate(nil)
    }
}
