import Carbon

enum HotkeyPreset: String, CaseIterable, Sendable {
    case optionSpace = "option_space"
    case controlGrave = "control_grave"
    case commandShiftT = "command_shift_t"

    var title: String {
        switch self {
        case .optionSpace:
            return "⌥ Space (Option-Space)"
        case .controlGrave:
            return "⌃ ` (Control-Grave)"
        case .commandShiftT:
            return "⌘ ⇧ T (Command-Shift-T)"
        }
    }

    var shortDisplay: String {
        switch self {
        case .optionSpace:
            return "⌥Space"
        case .controlGrave:
            return "⌃`"
        case .commandShiftT:
            return "⌘⇧T"
        }
    }

    var keyCode: UInt32 {
        switch self {
        case .optionSpace:
            return UInt32(kVK_Space)
        case .controlGrave:
            return UInt32(kVK_ANSI_Grave)
        case .commandShiftT:
            return UInt32(kVK_ANSI_T)
        }
    }

    var modifiers: UInt32 {
        switch self {
        case .optionSpace:
            return UInt32(optionKey)
        case .controlGrave:
            return UInt32(controlKey)
        case .commandShiftT:
            return UInt32(cmdKey | shiftKey)
        }
    }
}
