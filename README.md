# double-arrow

Tap a modifier key twice or three times in a row to send another key, on
macOS. No Karabiner, no drivers, no dependencies. Built entirely on public
macOS frameworks (a CoreGraphics event tap) and compiled with the system's
own `swiftc`.

The default bindings, tuned for keyboards with no arrow cluster:

| Key (double-tap) | Sends |
|---|---|
| Left Control | Down |
| Left Option | Up |
| Right Option | Left |
| Right Control | Right |

A single press or a held modifier (Ctrl+C, Option+drag, etc.) is left
alone. Only a clean run of taps within 350ms is caught.

## Setup

**Download a prebuilt binary:** grab `double-arrow-macos-arm64.tar.gz` (Apple
Silicon) or `double-arrow-macos-x64.tar.gz` (Intel) from the
[Releases page](https://github.com/dandonarahul2002/double-arrow/releases),
extract it, and use the `double-arrow` binary inside in place of
`bin/double-arrow` below. Otherwise, build from source:

```
git clone git@github.com:dandonarahul2002/double-arrow.git
cd double-arrow
Scripts/setup.sh
```

The script builds the binary, code-signs it, and installs it as a
LaunchAgent that starts at login and restarts itself if it ever crashes.

It will also open System Settings for you. There, under
**Privacy & Security > Input Monitoring**, turn on the entry for
`double-arrow`. This is required for any app that reads raw key events.

Then restart the agent once so it picks up the new permission:

```
launchctl kickstart -k gui/$(id -u)/com.doublearrow.agent
```

That's it. Double-tap a modifier key to try it.

## Adding your own bindings

Any modifier key, either side (Control, Option, Shift, Command), can be
bound to any key, with either two or three taps. Use the interactive
`add` command, the same way macOS's own shortcut recorder works: it tells
you what to press, and captures it directly, no key codes to look up.

```
bin/double-arrow add
```

```
Press the trigger key: a modifier key, either side (control, option, shift, or command)...
Captured: right_shift
How many taps should trigger this? [2 or 3, default 2]: 3
Now press the key it should send...
Captured: escape
Saved: 3x right_shift -> escape
```

Other commands:

```
bin/double-arrow list             # show configured bindings, with their index
bin/double-arrow remove <index>   # remove one
bin/double-arrow reset            # restore the original four bindings
```

Any command that changes bindings prints the `launchctl kickstart` command
to run afterward so the change takes effect immediately.

Bindings live in `~/.config/double-arrow/config.json` if you'd rather
edit them by hand. `window` is the tap timing window in seconds.

### A note on triple-tap latency

Binding only double-tap, or only triple-tap, to a given key fires the
instant that count is reached, with no added delay. The one case that
does wait is binding **both** double and triple tap to the *same* key:
reaching two taps is then ambiguous with being partway through three, so
that action is held for the tap window (350ms by default) to see whether
a third tap follows. This only affects keys configured that way; every
other binding stays instant.

## Uninstall

```
Scripts/uninstall.sh
```

## How it works

Everything lives in `Sources/`:

- `KeyTapListener.swift` opens a `CGEventTap` on `flagsChanged` events at
  the HID level (the lowest-latency public tap point) and re-enables
  itself if macOS ever disables it.
- `DoubleArrowRemapper.swift` builds one `TapChainDetector` per configured
  trigger key from `Config`, and decides whether to swallow each event.
- `TapChainDetector.swift` is the only piece of real logic: a tap counter
  and a timestamp comparison, no macOS APIs involved.
- `Config.swift` loads and saves `~/.config/double-arrow/config.json`,
  seeding it with the default bindings on first run.
- `KeyCapture.swift` and `CLI.swift` implement the `add`/`list`/`remove`/
  `reset` commands.

On a completed tap sequence it posts a synthetic key event for the bound
target and swallows the real modifier event; everything else passes
through unmodified.

## Logs

```
tail -f ~/Library/Logs/com.doublearrow.agent.log
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to build, test, and
propose changes.

## License

MIT, see [LICENSE](LICENSE).
