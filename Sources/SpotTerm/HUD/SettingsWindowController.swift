import AppKit
import Foundation

@MainActor
protocol SettingsWindowDelegate: AnyObject {
    var isLaunchAtLoginEnabled: Bool { get }
    var currentHotkeyPreset: HotkeyPreset { get }
    var currentWindowLevel: WindowLevelSetting { get }
    var currentBackdropStyle: BackdropStyle { get }
    var currentBackdropOpacity: Double { get }
    var isDismissOnOutsideClickEnabled: Bool { get }
    var isDismissOnEscapeEnabled: Bool { get }

    func didToggleLaunchAtLogin()
    func didSelectHotkeyPreset(_ preset: HotkeyPreset)
    func didSelectWindowLevel(_ level: WindowLevelSetting)
    func didSelectBackdropStyle(_ style: BackdropStyle)
    func didChangeBackdropOpacity(_ opacity: Double)
    func didToggleDismissOnOutsideClick()
    func didToggleDismissOnEscape()
    func didRequestResetShell()
    func didRequestQuit()
}

@MainActor
final class SettingsWindowController: NSWindowController {
    private weak var delegate: SettingsWindowDelegate?

    private let launchAtLoginCheckbox = NSButton(
        checkboxWithTitle: "Launch at Login",
        target: nil,
        action: nil
    )
    private let outsideClickCheckbox = NSButton(
        checkboxWithTitle: "Dismiss HUD when clicking outside",
        target: nil,
        action: nil
    )
    private let escapeCheckbox = NSButton(
        checkboxWithTitle: "Dismiss HUD when pressing Escape",
        target: nil,
        action: nil
    )
    private let hotkeyPopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private let windowLevelPopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private let stylePopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private let opacitySlider = NSSlider(value: 0.70, minValue: 0.20, maxValue: 1.0, target: nil, action: nil)
    private let opacityValueLabel = NSTextField(labelWithString: "70%")

    init(delegate: SettingsWindowDelegate) {
        self.delegate = delegate
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "SpotTerm Settings"
        window.isReleasedWhenClosed = false
        window.animationBehavior = .default
        super.init(window: window)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupContentView() {
        guard let window else { return }
        let container = NSStackView()
        container.orientation = .vertical
        container.alignment = .leading
        container.spacing = 14.0
        container.edgeInsets = NSEdgeInsets(top: 18, left: 24, bottom: 18, right: 24)
        container.translatesAutoresizingMaskIntoConstraints = false

        addGeneralSection(to: container)
        addAppearanceSection(to: container)
        addBehaviorSection(to: container)
        addActionsSection(to: container)

        let root = NSView()
        root.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            container.topAnchor.constraint(equalTo: root.topAnchor),
            container.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])

        window.contentView = root
        refreshValues()
    }

    private func addGeneralSection(to stack: NSStackView) {
        let title = makeHeaderLabel(title: "General & Hotkeys")
        stack.addArrangedSubview(title)

        launchAtLoginCheckbox.target = self
        launchAtLoginCheckbox.action = #selector(launchAtLoginToggled)
        stack.addArrangedSubview(launchAtLoginCheckbox)

        let hotkeyRow = makePopUpRow(label: "Summon Hotkey:", popUp: hotkeyPopUp)
        setupHotkeyPopUp()
        stack.addArrangedSubview(hotkeyRow)

        let levelRow = makePopUpRow(label: "Window Level:", popUp: windowLevelPopUp)
        setupLevelPopUp()
        stack.addArrangedSubview(levelRow)
    }

    private func addAppearanceSection(to stack: NSStackView) {
        let title = makeHeaderLabel(title: "Appearance & Opacity")
        stack.addArrangedSubview(title)

        let styleRow = makePopUpRow(label: "Backdrop Style:", popUp: stylePopUp)
        setupStylePopUp()
        stack.addArrangedSubview(styleRow)

        let sliderRow = NSStackView()
        sliderRow.orientation = .horizontal
        sliderRow.spacing = 8.0

        let label = NSTextField(labelWithString: "Opacity:")
        label.alignment = .right
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        opacitySlider.target = self
        opacitySlider.action = #selector(opacitySliderChanged)
        opacitySlider.isContinuous = true

        opacityValueLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)
        opacityValueLabel.textColor = NSColor.secondaryLabelColor

        sliderRow.addArrangedSubview(label)
        sliderRow.addArrangedSubview(opacitySlider)
        sliderRow.addArrangedSubview(opacityValueLabel)
        stack.addArrangedSubview(sliderRow)
    }

    private func addBehaviorSection(to stack: NSStackView) {
        let title = makeHeaderLabel(title: "Dismissal Behavior")
        stack.addArrangedSubview(title)

        outsideClickCheckbox.target = self
        outsideClickCheckbox.action = #selector(outsideClickToggled)
        stack.addArrangedSubview(outsideClickCheckbox)

        escapeCheckbox.target = self
        escapeCheckbox.action = #selector(escapeToggled)
        stack.addArrangedSubview(escapeCheckbox)
    }

    private func addActionsSection(to stack: NSStackView) {
        let separator = NSBox()
        separator.boxType = .separator
        stack.addArrangedSubview(separator)

        let buttonRow = NSStackView()
        buttonRow.orientation = .horizontal
        buttonRow.spacing = 12.0

        let resetButton = NSButton(
            title: "Reset Shell Session",
            target: self,
            action: #selector(resetShellClicked)
        )
        let quitButton = NSButton(
            title: "Quit SpotTerm",
            target: self,
            action: #selector(quitClicked)
        )
        quitButton.hasDestructiveAction = true

        buttonRow.addArrangedSubview(resetButton)
        buttonRow.addArrangedSubview(quitButton)
        stack.addArrangedSubview(buttonRow)
    }

    private func makeHeaderLabel(title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.boldSystemFont(ofSize: 13.0)
        label.textColor = NSColor.labelColor
        return label
    }

    private func makePopUpRow(label text: String, popUp: NSPopUpButton) -> NSStackView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 8.0

        let label = NSTextField(labelWithString: text)
        label.alignment = .right
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        row.addArrangedSubview(label)
        row.addArrangedSubview(popUp)
        return row
    }

    private func setupHotkeyPopUp() {
        hotkeyPopUp.removeAllItems()
        for preset in HotkeyPreset.allCases {
            hotkeyPopUp.addItem(withTitle: preset.title)
        }
        hotkeyPopUp.target = self
        hotkeyPopUp.action = #selector(hotkeySelected)
    }

    private func setupLevelPopUp() {
        windowLevelPopUp.removeAllItems()
        for level in WindowLevelSetting.allCases {
            windowLevelPopUp.addItem(withTitle: level.title)
        }
        windowLevelPopUp.target = self
        windowLevelPopUp.action = #selector(levelSelected)
    }

    private func setupStylePopUp() {
        stylePopUp.removeAllItems()
        for style in BackdropStyle.allCases {
            stylePopUp.addItem(withTitle: style.title)
        }
        stylePopUp.target = self
        stylePopUp.action = #selector(styleSelected)
    }

    func showSettings() {
        refreshValues()
        guard let window else { return }
        if !window.isVisible {
            window.center()
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func refreshValues() {
        guard let delegate else { return }
        launchAtLoginCheckbox.state = delegate.isLaunchAtLoginEnabled ? .on : .off
        outsideClickCheckbox.state = delegate.isDismissOnOutsideClickEnabled ? .on : .off
        escapeCheckbox.state = delegate.isDismissOnEscapeEnabled ? .on : .off

        let hotkeyIndex = HotkeyPreset.allCases.firstIndex(of: delegate.currentHotkeyPreset) ?? 0
        hotkeyPopUp.selectItem(at: hotkeyIndex)

        let levelIndex = WindowLevelSetting.allCases.firstIndex(of: delegate.currentWindowLevel) ?? 0
        windowLevelPopUp.selectItem(at: levelIndex)

        let styleIndex = BackdropStyle.allCases.firstIndex(of: delegate.currentBackdropStyle) ?? 0
        stylePopUp.selectItem(at: styleIndex)

        let opacity = delegate.currentBackdropOpacity
        opacitySlider.doubleValue = opacity
        opacityValueLabel.stringValue = "\(Int(round(opacity * 100)))%"
    }

    @objc private func launchAtLoginToggled() {
        delegate?.didToggleLaunchAtLogin()
        refreshValues()
    }

    @objc private func outsideClickToggled() {
        delegate?.didToggleDismissOnOutsideClick()
    }

    @objc private func escapeToggled() {
        delegate?.didToggleDismissOnEscape()
    }

    @objc private func hotkeySelected() {
        let index = hotkeyPopUp.indexOfSelectedItem
        guard index >= 0, index < HotkeyPreset.allCases.count else { return }
        delegate?.didSelectHotkeyPreset(HotkeyPreset.allCases[index])
    }

    @objc private func levelSelected() {
        let index = windowLevelPopUp.indexOfSelectedItem
        guard index >= 0, index < WindowLevelSetting.allCases.count else { return }
        delegate?.didSelectWindowLevel(WindowLevelSetting.allCases[index])
    }

    @objc private func styleSelected() {
        let index = stylePopUp.indexOfSelectedItem
        guard index >= 0, index < BackdropStyle.allCases.count else { return }
        let style = BackdropStyle.allCases[index]
        delegate?.didSelectBackdropStyle(style)
        refreshValues()
    }

    @objc private func opacitySliderChanged() {
        let opacity = opacitySlider.doubleValue
        opacityValueLabel.stringValue = "\(Int(round(opacity * 100)))%"
        delegate?.didChangeBackdropOpacity(opacity)
    }

    @objc private func resetShellClicked() {
        delegate?.didRequestResetShell()
    }

    @objc private func quitClicked() {
        delegate?.didRequestQuit()
    }
}
