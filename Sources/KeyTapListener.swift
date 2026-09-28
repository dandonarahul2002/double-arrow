import CoreGraphics
import Foundation

/// Installs a low-level CGEventTap on the HID event stream and forwards
/// every flagsChanged event to a DoubleArrowRemapper, swallowing the ones
/// it converts into arrow key presses.
final class KeyTapListener {
    private let remapper: DoubleArrowRemapper
    private var eventTap: CFMachPort?

    init(remapper: DoubleArrowRemapper) {
        self.remapper = remapper
    }

    /// Creates the tap and blocks forever pumping the run loop. Exits the
    /// process with an error if the tap can't be created (missing
    /// Input Monitoring permission).
    func run() -> Never {
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                guard let refcon else { return Unmanaged.passRetained(event) }
                let listener = Unmanaged<KeyTapListener>.fromOpaque(refcon).takeUnretainedValue()
                return listener.handle(type: type, event: event)
            },
            userInfo: selfPointer
        ) else {
            FileHandle.standardError.write(Data("Failed to create event tap. Grant Input Monitoring permission to this binary and retry.\n".utf8))
            exit(1)
        }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        CFRunLoopRun()
        fatalError("CFRunLoopRun returned unexpectedly")
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // macOS disables a tap if its callback is ever too slow; re-enable
        // immediately so the remap keeps working without a restart.
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passRetained(event)
        }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let timestamp = TimeInterval(event.timestamp) / 1_000_000_000
        let shouldSwallow = remapper.handleFlagsChanged(keyCode: keyCode, timestamp: timestamp)
        return shouldSwallow ? nil : Unmanaged.passRetained(event)
    }
}
