import CoreGraphics

/// macOS virtual key codes (from HIToolbox/Events.h), hardcoded so no Carbon import is needed.
enum KeyCode {
    static let leftControl: Int64 = 59
    static let rightControl: Int64 = 62
    static let leftOption: Int64 = 58
    static let rightOption: Int64 = 61

    static let upArrow: CGKeyCode = 126
    static let downArrow: CGKeyCode = 125
    static let leftArrow: CGKeyCode = 123
    static let rightArrow: CGKeyCode = 124
}
