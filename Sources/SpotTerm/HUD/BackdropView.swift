import AppKit

final class BackdropView: NSVisualEffectView {
    private static let cornerRadiusValue: CGFloat = 16.0
    private static let borderWidthValue: CGFloat = 1.0

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

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        setupHeader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
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

    private func setupHeader() {
        addSubview(statusIndicator)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            statusIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 11.0),
            statusIndicator.widthAnchor.constraint(equalToConstant: 7.0),
            statusIndicator.heightAnchor.constraint(equalToConstant: 7.0),

            titleLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 8.0),
            titleLabel.centerYAnchor.constraint(equalTo: statusIndicator.centerYAnchor)
        ])
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateBorderColor()
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
}
