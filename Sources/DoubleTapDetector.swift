import Foundation

/// Tracks press/release timing for one physical key and decides when two
/// clean taps landed within the double-tap window. Pure logic, no macOS
/// event APIs, so it can be reasoned about (and tested) in isolation.
final class DoubleTapDetector {
    private let window: TimeInterval
    private var lastPressTime: TimeInterval = -.infinity
    private var isSwallowing = false

    init(window: TimeInterval = 0.35) {
        self.window = window
    }

    /// Call on key-down. Returns true if this press is the second tap of a
    /// double-tap and should be swallowed (converted to the mapped action).
    func onPress(at time: TimeInterval) -> Bool {
        if time - lastPressTime <= window {
            lastPressTime = -.infinity
            isSwallowing = true
            return true
        }
        lastPressTime = time
        isSwallowing = false
        return false
    }

    /// Call on key-up. Returns true if this release pairs with a swallowed
    /// press and should be swallowed too.
    func onRelease() -> Bool {
        guard isSwallowing else { return false }
        isSwallowing = false
        return true
    }
}
