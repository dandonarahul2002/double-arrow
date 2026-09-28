# double-arrow

Double-tap a modifier key to send an arrow key. No Karabiner, no drivers,
no dependencies — one Swift file set, compiled with `swiftc` and built
entirely on public macOS frameworks (CoreGraphics event taps).

| Key (double-tap) | Sends |
|---|---|
| Left Control | Down |
| Left Option | Up |
| Right Option | Left |
| Right Control | Right |

A single press or a held modifier (e.g. Ctrl+C, Option+drag) is untouched —
only a second clean tap within 350ms is intercepted and converted.

## How it works

- `Sources/KeyTapListener.swift` opens a `CGEventTap` on `flagsChanged`
  events at the HID level (lowest-latency public tap point) and re-enables
  itself if macOS ever disables it.
- `Sources/DoubleArrowRemapper.swift` tracks per-key down/up state and asks
  a `DoubleTapDetector` whether a press is the second tap of a pair.
- `Sources/DoubleTapDetector.swift` is the only piece of actual logic — no
  macOS APIs, just a timestamp comparison — and is the piece to change if
  you want a different window or mapping.
- On a double-tap it posts a synthetic arrow key event and swallows the
  real modifier event; everything else passes through unmodified.

## Setup

```
Scripts/setup.sh
```

This builds the binary, ad-hoc code-signs it (a stable identifier so you
won't need to re-grant permission on every rebuild), installs it as a
LaunchAgent (starts at login, restarts if it crashes), and opens
System Settings so you can grant it **Input Monitoring** permission
(required for any app that reads raw key events). After granting it,
restart the agent once:

```
launchctl kickstart -k gui/$(id -u)/com.doublearrow.agent
```

## Uninstall

```
Scripts/uninstall.sh
```

## Logs

```
tail -f ~/Library/Logs/com.doublearrow.agent.log
```
