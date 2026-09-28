import Foundation

/// One binding: tapping `trigger` this many times in a row sends `target`.
struct Binding: Codable {
    let trigger: String
    let taps: Int
    let target: String
}

struct Config: Codable {
    var window: TimeInterval
    var bindings: [Binding]

    static let path = URL(fileURLWithPath: NSHomeDirectory())
        .appendingPathComponent(".config/double-arrow/config.json")

    static let defaultConfig = Config(
        window: 0.35,
        bindings: [
            Binding(trigger: "left_control", taps: 2, target: "down_arrow"),
            Binding(trigger: "left_option", taps: 2, target: "up_arrow"),
            Binding(trigger: "right_option", taps: 2, target: "left_arrow"),
            Binding(trigger: "right_control", taps: 2, target: "right_arrow"),
        ]
    )

    /// Loads the config file, seeding it with the defaults on first run.
    static func load() -> Config {
        guard let data = try? Data(contentsOf: path),
              let config = try? JSONDecoder().decode(Config.self, from: data) else {
            try? defaultConfig.save()
            return defaultConfig
        }
        return config
    }

    func save() throws {
        try FileManager.default.createDirectory(
            at: Config.path.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(self).write(to: Config.path, options: .atomic)
    }
}
