import CoreGraphics

/// macOS virtual key codes (from HIToolbox/Events.h), hardcoded so no Carbon
/// import is needed, with human-readable names for the config file and CLI.
enum KeyCode {
    static let byName: [String: Int64] = [
        "left_control": 59, "right_control": 62,
        "left_option": 58, "right_option": 61,
        "left_shift": 56, "right_shift": 60,
        "left_command": 55, "right_command": 54,

        "up_arrow": 126, "down_arrow": 125, "left_arrow": 123, "right_arrow": 124,
        "escape": 53, "space": 49, "tab": 48, "return": 36, "delete": 51,

        "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97,
        "f7": 98, "f8": 100, "f9": 101, "f10": 109, "f11": 103, "f12": 111,

        "a": 0, "b": 11, "c": 8, "d": 2, "e": 14, "f": 3, "g": 5, "h": 4,
        "i": 34, "j": 38, "k": 40, "l": 37, "m": 46, "n": 45, "o": 31,
        "p": 35, "q": 12, "r": 15, "s": 1, "t": 17, "u": 32, "v": 9,
        "w": 13, "x": 7, "y": 16, "z": 6,

        "0": 29, "1": 18, "2": 19, "3": 20, "4": 21, "5": 23,
        "6": 22, "7": 26, "8": 28, "9": 25,
    ]

    /// Keys that generate flagsChanged events and can be used as a trigger.
    static let modifierNames: Set<String> = [
        "left_control", "right_control", "left_option", "right_option",
        "left_shift", "right_shift", "left_command", "right_command",
    ]

    static func name(for code: Int64) -> String? {
        byName.first { $0.value == code }?.key
    }
}
