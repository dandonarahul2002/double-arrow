import CoreGraphics
import Foundation

/// Maps a physical modifier key to the arrow key it should send on double-tap.
private struct KeyMapping {
    let arrowKeyCode: CGKeyCode
    let detector = DoubleTapDetector()
}

/// Owns the four tracked key mappings and decides, per incoming
/// flagsChanged event, whether to swallow it and fire an arrow key instead.
final class DoubleArrowRemapper {
    private var mappings: [Int64: KeyMapping] = [
        KeyCode.leftControl: KeyMapping(arrowKeyCode: KeyCode.downArrow),
        KeyCode.leftOption: KeyMapping(arrowKeyCode: KeyCode.upArrow),
        KeyCode.rightOption: KeyMapping(arrowKeyCode: KeyCode.leftArrow),
        KeyCode.rightControl: KeyMapping(arrowKeyCode: KeyCode.rightArrow),
    ]
    private var currentlyDown: Set<Int64> = []

    /// Returns true if the original event should be swallowed (not passed on).
    func handleFlagsChanged(keyCode: Int64, timestamp: TimeInterval) -> Bool {
        guard let mapping = mappings[keyCode] else { return false }

        // A key can't repeat the same transition twice in a row, so each
        // flagsChanged event for this code strictly alternates press/release.
        let isPress = !currentlyDown.contains(keyCode)

        if isPress {
            currentlyDown.insert(keyCode)
            let isDoubleTap = mapping.detector.onPress(at: timestamp)
            if isDoubleTap { postArrowTap(mapping.arrowKeyCode) }
            return isDoubleTap
        } else {
            currentlyDown.remove(keyCode)
            return mapping.detector.onRelease()
        }
    }

    private func postArrowTap(_ keyCode: CGKeyCode) {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else { return }
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }
}
