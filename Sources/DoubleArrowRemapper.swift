import CoreGraphics
import Foundation

/// Owns one TapChainDetector per configured trigger key and decides, per
/// incoming flagsChanged event, whether to swallow it and fire its bound
/// key press instead.
final class DoubleArrowRemapper {
    private var detectors: [Int64: TapChainDetector] = [:]
    private var currentlyDown: Set<Int64> = []

    init(config: Config) {
        let grouped = Dictionary(grouping: config.bindings, by: { $0.trigger })
        for (triggerName, bindings) in grouped {
            guard let triggerCode = KeyCode.byName[triggerName] else {
                warn("Unknown trigger key '\(triggerName)', skipping.")
                continue
            }
            var actions: [Int: () -> Void] = [:]
            for binding in bindings {
                guard let targetCode = KeyCode.byName[binding.target] else {
                    warn("Unknown target key '\(binding.target)', skipping.")
                    continue
                }
                actions[binding.taps] = { [weak self] in
                    self?.postKeyTap(CGKeyCode(targetCode))
                }
            }
            guard !actions.isEmpty else { continue }
            detectors[triggerCode] = TapChainDetector(window: config.window, actions: actions)
        }
    }

    /// Returns true if the original event should be swallowed (not passed on).
    func handleFlagsChanged(keyCode: Int64, timestamp: TimeInterval) -> Bool {
        guard let detector = detectors[keyCode] else { return false }

        // A key can't repeat the same transition twice in a row, so each
        // flagsChanged event for this code strictly alternates press/release.
        let isPress = !currentlyDown.contains(keyCode)

        if isPress {
            currentlyDown.insert(keyCode)
            return detector.onPress(at: timestamp)
        } else {
            currentlyDown.remove(keyCode)
            return detector.onRelease()
        }
    }

    private func postKeyTap(_ keyCode: CGKeyCode) {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else { return }
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }

    private func warn(_ message: String) {
        FileHandle.standardError.write(Data((message + "\n").utf8))
    }
}
