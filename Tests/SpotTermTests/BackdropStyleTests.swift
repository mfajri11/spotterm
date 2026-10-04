import Foundation
@testable import SpotTerm
import Testing

struct BackdropStyleTests {
    @Test func allCasesHaveValidTitlesAndOpacities() {
        for style in BackdropStyle.allCases {
            #expect(!style.title.isEmpty)
            #expect(style.defaultOpacity >= 0.2 && style.defaultOpacity <= 1.0)
        }
    }

    @Test func solidStyleIsCompletelyOpaqueByDefault() {
        #expect(BackdropStyle.solid.defaultOpacity == 1.0)
    }

    @Test func frostedGlassHasSubtleDefaultOpacity() {
        #expect(BackdropStyle.frostedGlass.defaultOpacity == 0.70)
    }
}
