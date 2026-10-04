import AppKit
import Foundation

enum ScreenLocator {
    static let defaultHUDSize = NSSize(width: 820, height: 500)

    static func targetScreen(
        for mousePoint: NSPoint,
        availableScreens: [NSScreen],
        fallbackMain: NSScreen? = NSScreen.main
    ) -> NSScreen? {
        if let matching = availableScreens.first(where: { $0.frame.contains(mousePoint) }) {
            return matching
        }

        if let fallbackMain {
            return fallbackMain
        }

        return availableScreens.first
    }

    static func calculatePanelFrame(
        on screen: NSScreen,
        preferredSize: NSSize = defaultHUDSize
    ) -> NSRect {
        let visible = screen.visibleFrame
        let width = min(preferredSize.width, max(400.0, visible.width - 48.0))
        let height = min(preferredSize.height, max(250.0, visible.height - 48.0))

        let originX = visible.origin.x + (visible.width - width) / 2.0
        let topOffset = max(28.0, visible.height * 0.12)
        let originY = visible.origin.y + visible.height - height - topOffset

        return NSRect(
            x: floor(originX),
            y: floor(originY),
            width: floor(width),
            height: floor(height)
        )
    }
}
