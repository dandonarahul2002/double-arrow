import CoreGraphics
import Foundation

/// Captures exactly one key press for interactive setup, the same way
/// macOS's own shortcut recorder fields work: blocks until a key is
/// pressed, swallows that keypress so it doesn't leak into the terminal,
/// and returns its virtual key code.
enum KeyCapture {
    static func waitForModifierKey() -> Int64? { capture(eventType: .flagsChanged) }
    static func waitForAnyKey() -> Int64? { capture(eventType: .keyDown) }

    private final class Box { var code: Int64? }

    private static func capture(eventType: CGEventType) -> Int64? {
        let box = Box()
        let boxPointer = Unmanaged.passUnretained(box).toOpaque()
        let mask = CGEventMask(1 << eventType.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, _, event, refcon in
                if let refcon {
                    Unmanaged<Box>.fromOpaque(refcon).takeUnretainedValue().code =
                        event.getIntegerValueField(.keyboardEventKeycode)
                }
                CFRunLoopStop(CFRunLoopGetCurrent())
                return nil // swallow so it doesn't reach the terminal
            },
            userInfo: boxPointer
        ) else { return nil }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        CFRunLoopRun()
        CGEvent.tapEnable(tap: tap, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        return box.code
    }
}
