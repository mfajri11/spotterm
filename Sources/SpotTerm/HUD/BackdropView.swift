import AppKit

final class BackdropView: NSVisualEffectView {
    private static let cornerRadiusValue: CGFloat = 16.0
    private static let borderWidthValue: CGFloat = 1.0

    var onSettingsClicked: (() -> Void)?
    var onResetClicked: (() -> Void)?
    var onQuitClicked: (() -> Void)?

    private var currentStyle: BackdropStyle = .frostedGlass
    private var currentOpacity: Double = 0.70

    private let solidOverlay: NSBox = {
        let box = NSBox()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.boxType = .custom
        box.borderWidth = 0
        box.cornerRadius = cornerRadiusValue
        return box
    }()

    private let titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "SpotTerm")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11.0, weight: .semibold)
        label.textColor = NSColor.secondaryLabelColor
        label.isEditable = false
        label.isSelectable = false
        return label
    }()

    private let statusIndicator: NSBox = {
        let box = NSBox()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.boxType = .custom
        box.borderWidth = 0
        box.cornerRadius = 3.5
        box.fillColor = NSColor.systemGreen.withAlphaComponent(0.75)
        return box
    }()

    private lazy var resetButton = makeHeaderButton(
        symbolName: "arrow.clockwise",
        tooltip: "Reset Shell Session (⌘R)",
        action: #selector(resetClicked)
    )

    private lazy var settingsButton = makeHeaderButton(
        symbolName: "gearshape",
        tooltip: "Settings (⌘,)",
        action: #selector(settingsClicked)
    )

    private lazy var quitButton = makeHeaderButton(
        symbolName: "xmark.circle",
        tooltip: "Quit SpotTerm (⌘Q)",
        action: #selector(quitClicked)
    )

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        setupOverlay()
        setupHeader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupOverlay()
        setupHeader()
    }

    private func setupView() {
        blendingMode = .behindWindow
        material = .hudWindow
        state = .active
        wantsLayer = true

        guard let layer else { return }
        layer.cornerRadius = Self.cornerRadiusValue
        layer.masksToBounds = true
        layer.borderWidth = Self.borderWidthValue
        updateBorderColor()
    }

    private func setupOverlay() {
        addSubview(solidOverlay)
        NSLayoutConstraint.activate([
            solidOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            solidOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            solidOverlay.topAnchor.constraint(equalTo: topAnchor),
            solidOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupHeader() {
        addSubview(statusIndicator)
        addSubview(titleLabel)

        let actionStack = NSStackView(views: [resetButton, settingsButton, quitButton])
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.orientation = .horizontal
        actionStack.spacing = 10.0
        addSubview(actionStack)

        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            statusIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 11.0),
            statusIndicator.widthAnchor.constraint(equalToConstant: 7.0),
            statusIndicator.heightAnchor.constraint(equalToConstant: 7.0),

            titleLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 8.0),
            titleLabel.centerYAnchor.constraint(equalTo: statusIndicator.centerYAnchor),

            actionStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
            actionStack.centerYAnchor.constraint(equalTo: statusIndicator.centerYAnchor)
        ])
    }

    private func makeHeaderButton(symbolName: String, tooltip: String, action: Selector) -> NSButton {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.title = ""
        let config = NSImage.SymbolConfiguration(pointSize: 11.0, weight: .medium)
        button.image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: tooltip
        )?.withSymbolConfiguration(config)
        button.contentTintColor = NSColor.secondaryLabelColor
        button.toolTip = tooltip
        button.target = self
        button.action = action
        return button
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        applyAppearance()
    }

    func updateAppearanceSettings(style: BackdropStyle, opacity: Double) {
        self.currentStyle = style
        self.currentOpacity = min(1.0, max(0.2, opacity))
        applyAppearance()
    }

    private func applyAppearance() {
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        updateBorderColor()

        switch currentStyle {
        case .frostedGlass:
            state = .active
            material = .hudWindow
            let tintAlpha = (1.0 - currentOpacity) * 0.3
            solidOverlay.fillColor = isDark
                ? NSColor.black.withAlphaComponent(tintAlpha)
                : NSColor.white.withAlphaComponent(tintAlpha)

        case .translucent:
            state = .active
            material = .hudWindow
            solidOverlay.fillColor = isDark
                ? NSColor(white: 0.10, alpha: currentOpacity)
                : NSColor(white: 0.95, alpha: currentOpacity)

        case .solid:
            state = .inactive
            solidOverlay.fillColor = isDark
                ? NSColor(red: 0.11, green: 0.12, blue: 0.13, alpha: currentOpacity)
                : NSColor(red: 0.97, green: 0.97, blue: 0.98, alpha: currentOpacity)
        }
    }

    private func updateBorderColor() {
        guard let layer else { return }
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let borderColor = isDark
            ? NSColor.white.withAlphaComponent(0.18)
            : NSColor.black.withAlphaComponent(0.12)
        layer.borderColor = borderColor.cgColor
    }

    func setStatusColor(_ color: NSColor) {
        statusIndicator.fillColor = color
    }

    @objc private func resetClicked() {
        onResetClicked?()
    }

    @objc private func settingsClicked() {
        onSettingsClicked?()
    }

    @objc private func quitClicked() {
        onQuitClicked?()
    }
}
