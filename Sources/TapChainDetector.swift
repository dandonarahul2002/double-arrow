import Dispatch
import Foundation

/// Tracks consecutive taps of one physical key and fires the bound action
/// once the running count matches a configured tap count.
///
/// The common case (one tap count bound per key) fires the instant that
/// count is reached, with no added latency. The only case that waits is
/// when a shorter count is bound alongside a longer one on the same key
/// (e.g. both double-tap and triple-tap are bound) -- there, reaching the
/// shorter count is ambiguous with being partway through the longer one,
/// so it's held for `window` to see whether the sequence continues.
final class TapChainDetector {
    private let window: TimeInterval
    private let actions: [Int: () -> Void]
    private let maxBoundCount: Int

    private var count = 0
    private var lastPressTime: TimeInterval = -.infinity
    private var isSwallowingCurrentPress = false
    private var pendingFire: DispatchWorkItem?

    init(window: TimeInterval, actions: [Int: () -> Void]) {
        self.window = window
        self.actions = actions
        self.maxBoundCount = actions.keys.max() ?? 0
    }

    /// Call on key-down. Returns true if this press should be swallowed.
    func onPress(at time: TimeInterval) -> Bool {
        pendingFire?.cancel()
        pendingFire = nil

        count = (time - lastPressTime <= window) ? count + 1 : 1
        lastPressTime = time

        guard let action = actions[count] else {
            isSwallowingCurrentPress = false
            return false
        }

        isSwallowingCurrentPress = true
        if count == maxBoundCount {
            count = 0
            action()
        } else {
            scheduleFire(for: count, action: action)
        }
        return true
    }

    /// Call on key-up. Returns true if this release pairs with a swallowed press.
    func onRelease() -> Bool {
        defer { isSwallowingCurrentPress = false }
        return isSwallowingCurrentPress
    }

    private func scheduleFire(for capturedCount: Int, action: @escaping () -> Void) {
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.count == capturedCount else { return }
            self.count = 0
            action()
        }
        pendingFire = work
        DispatchQueue.main.asyncAfter(deadline: .now() + window, execute: work)
    }
}
