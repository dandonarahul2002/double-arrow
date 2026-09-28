# double-arrow

Double-tap a modifier key to send an arrow key on macOS. No Karabiner, no
drivers, no dependencies. Built entirely on public macOS frameworks
(a CoreGraphics event tap) and compiled with the system's own `swiftc`.

| Key (double-tap) | Sends |
|---|---|
| Left Control | Down |
| Left Option | Up |
| Right Option | Left |
| Right Control | Right |

A single press or a held modifier (Ctrl+C, Option+drag, etc.) is left
alone. Only a second clean tap within 350ms is caught and turned into an
arrow key press.

## Setup

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

## Uninstall

```
Scripts/uninstall.sh
```

## Changing the mapping or timing

Everything lives in `Sources/`:

- `DoubleTapDetector.swift` decides if a press counts as a double-tap. Its
  `window` parameter (default 0.35 seconds) sets how fast the second tap
  must land.
- `DoubleArrowRemapper.swift` has the table mapping each key to the arrow
  it sends.
- `KeyTapListener.swift` is the low level plumbing that reads key events
  and posts the arrow key. You shouldn't need to touch this.

After editing, run `Scripts/setup.sh` again to rebuild and reinstall.

## Logs

```
tail -f ~/Library/Logs/com.doublearrow.agent.log
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to build, test, and
propose changes.

## License

MIT, see [LICENSE](LICENSE).
