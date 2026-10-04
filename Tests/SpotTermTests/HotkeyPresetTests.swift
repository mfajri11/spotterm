import Carbon
@testable import SpotTerm
import Testing

struct HotkeyPresetTests {
    @Test func allPresetsHaveValidKeyCodesAndModifiers() {
        for preset in HotkeyPreset.allCases {
            #expect(preset.keyCode < 256)
            #expect(preset.modifiers > 0)
            #expect(!preset.title.isEmpty)
            #expect(!preset.shortDisplay.isEmpty)
        }
    }

    @Test func optionSpaceAttributes() {
        let preset = HotkeyPreset.optionSpace
        #expect(preset.keyCode == UInt32(kVK_Space))
        #expect(preset.modifiers == UInt32(optionKey))
        #expect(preset.shortDisplay == "⌥Space")
    }

    @Test func controlGraveAttributes() {
        let preset = HotkeyPreset.controlGrave
        #expect(preset.keyCode == UInt32(kVK_ANSI_Grave))
        #expect(preset.modifiers == UInt32(controlKey))
        #expect(preset.shortDisplay == "⌃`")
    }

    @Test func commandShiftTAttributes() {
        let preset = HotkeyPreset.commandShiftT
        #expect(preset.keyCode == UInt32(kVK_ANSI_T))
        #expect(preset.modifiers == UInt32(cmdKey | shiftKey))
        #expect(preset.shortDisplay == "⌘⇧T")
    }
}
