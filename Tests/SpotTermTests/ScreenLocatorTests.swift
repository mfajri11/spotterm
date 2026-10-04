import AppKit
@testable import SpotTerm
import Testing

struct ScreenLocatorTests {
    @Test func targetScreenFindsScreenContainingPoint() {
        let screens = NSScreen.screens
        guard let firstScreen = screens.first else { return }

        let midpoint = NSPoint(
            x: firstScreen.frame.midX,
            y: firstScreen.frame.midY
        )
        let found = ScreenLocator.targetScreen(
            for: midpoint,
            availableScreens: screens,
            fallbackMain: firstScreen
        )

        #expect(found?.frame == firstScreen.frame)
    }

    @Test func targetScreenFallsBackWhenPointIsOutside() {
        let screens = NSScreen.screens
        guard let firstScreen = screens.first else { return }

        let outsidePoint = NSPoint(x: -99999, y: -99999)
        let found = ScreenLocator.targetScreen(
            for: outsidePoint,
            availableScreens: screens,
            fallbackMain: firstScreen
        )

        #expect(found?.frame == firstScreen.frame)
    }

    @Test func calculatePanelFrameIsCenteredHorizontally() {
        guard let screen = NSScreen.screens.first else { return }
        let frame = ScreenLocator.calculatePanelFrame(
            on: screen,
            preferredSize: NSSize(width: 800, height: 480)
        )

        let visible = screen.visibleFrame
        let expectedX = floor(visible.origin.x + (visible.width - frame.width) / 2.0)
        #expect(frame.origin.x == expectedX)
        #expect(frame.width <= visible.width)
        #expect(frame.height <= visible.height)
    }
}
