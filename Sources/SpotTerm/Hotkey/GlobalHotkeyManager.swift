import Carbon
import Foundation

@MainActor
final class GlobalHotkeyManager {
    private static let hotKeySignature: OSType = 0x5350544D // 'SPTM'
    private static let hotKeyIdentifier: UInt32 = 1

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    private(set) var currentPreset: HotkeyPreset
    var onHotKeyTriggered: (() -> Void)?

    init(defaultPreset: HotkeyPreset = .optionSpace) {
        self.currentPreset = defaultPreset
    }

    func startListening() throws {
        try installCarbonHandler()
        try registerHotKey(for: currentPreset)
    }

    func updatePreset(_ newPreset: HotkeyPreset) throws {
        unregisterHotKey()
        self.currentPreset = newPreset
        try registerHotKey(for: newPreset)
    }

    private func installCarbonHandler() throws {
        guard eventHandlerRef == nil else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard let event, let userData else {
                    return OSStatus(eventNotHandledErr)
                }
                var hotKeyID = EventHotKeyID()
                let paramStatus = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard paramStatus == noErr else { return paramStatus }
                let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                Task { @MainActor in
                    manager.onHotKeyTriggered?()
                }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )

        guard status == noErr else {
            throw SpotTermError.eventHandlerInstallationFailed(osStatus: status)
        }
    }

    private func registerHotKey(for preset: HotkeyPreset) throws {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = Self.hotKeySignature
        hotKeyID.id = Self.hotKeyIdentifier

        let status = RegisterEventHotKey(
            preset.keyCode,
            preset.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            throw SpotTermError.hotkeyRegistrationFailed(osStatus: status)
        }
    }

    private func unregisterHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    func teardown() {
        unregisterHotKey()
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }
}
