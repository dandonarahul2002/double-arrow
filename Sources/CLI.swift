import Foundation

/// Command dispatch for the `double-arrow` binary. `run` (or no arguments)
/// is what the LaunchAgent invokes; the rest are for configuring bindings
/// from the terminal.
enum CLI {
    static func run(arguments: [String]) {
        switch arguments.first ?? "run" {
        case "run": runDaemon()
        case "add": addBinding()
        case "list": listBindings()
        case "remove": removeBinding(arguments: Array(arguments.dropFirst()))
        case "reset": resetBindings()
        default: printUsage()
        }
    }

    private static func runDaemon() -> Never {
        let remapper = DoubleArrowRemapper(config: Config.load())
        KeyTapListener(remapper: remapper).run()
    }

    private static func addBinding() {
        print("Press the trigger key: a modifier key, either side (control, option, shift, or command)...")
        guard let triggerCode = KeyCapture.waitForModifierKey(),
              let triggerName = KeyCode.name(for: triggerCode),
              KeyCode.modifierNames.contains(triggerName) else {
            print("That wasn't a recognized modifier key. Try again.")
            return
        }
        print("Captured: \(triggerName)")

        print("How many taps should trigger this? [2 or 3, default 2]: ", terminator: "")
        let taps = Int(readLine() ?? "") ?? 2
        guard taps == 2 || taps == 3 else {
            print("Only 2 or 3 taps are supported.")
            return
        }

        print("Now press the key it should send...")
        guard let targetCode = KeyCapture.waitForAnyKey(),
              let targetName = KeyCode.name(for: targetCode) else {
            print("Unrecognized key. Try again.")
            return
        }
        print("Captured: \(targetName)")

        var config = Config.load()
        config.bindings.removeAll { $0.trigger == triggerName && $0.taps == taps }
        config.bindings.append(Binding(trigger: triggerName, taps: taps, target: targetName))
        save(config)

        print("Saved: \(taps)x \(triggerName) -> \(targetName)")
        printRestartHint()
    }

    private static func listBindings() {
        let bindings = Config.load().bindings
        guard !bindings.isEmpty else {
            print("No bindings configured.")
            return
        }
        for (index, binding) in bindings.enumerated() {
            print("\(index): \(binding.taps)x \(binding.trigger) -> \(binding.target)")
        }
    }

    private static func removeBinding(arguments: [String]) {
        guard let index = arguments.first.flatMap(Int.init) else {
            print("Usage: double-arrow remove <index>   (see indices via `double-arrow list`)")
            return
        }
        var config = Config.load()
        guard config.bindings.indices.contains(index) else {
            print("No binding at index \(index).")
            return
        }
        let removed = config.bindings.remove(at: index)
        save(config)
        print("Removed: \(removed.taps)x \(removed.trigger) -> \(removed.target)")
        printRestartHint()
    }

    private static func resetBindings() {
        save(Config.defaultConfig)
        print("Restored default bindings.")
        printRestartHint()
    }

    private static func save(_ config: Config) {
        do {
            try config.save()
        } catch {
            print("Failed to save config: \(error)")
        }
    }

    private static func printRestartHint() {
        print("Run this to apply it: launchctl kickstart -k gui/$(id -u)/com.doublearrow.agent")
    }

    private static func printUsage() {
        print("""
        Usage: double-arrow <command>

        Commands:
          run              Start the remapper (this is what the LaunchAgent runs)
          add              Interactively add a tap binding
          list             Show configured bindings
          remove <index>   Remove a binding by its list index
          reset            Restore the default bindings
        """)
    }
}
