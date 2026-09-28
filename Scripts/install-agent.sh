#!/usr/bin/env bash
set -euo pipefail

# Signs a double-arrow binary, installs it as a LaunchAgent, and prompts
# for Input Monitoring permission. Shared by Scripts/setup.sh (building
# from source) and the binary released on GitHub (already built), which
# is why the binary path is a parameter instead of always being built.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_PATH="${1:-$SCRIPT_DIR/double-arrow}"
LABEL="com.doublearrow.agent"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_PATH="$HOME/Library/Logs/$LABEL.log"

if [ ! -x "$BIN_PATH" ]; then
    echo "No binary at $BIN_PATH" >&2
    exit 1
fi

echo "==> Signing (ad-hoc, stable identifier so permission survives rebuilds)"
codesign --force -s - --identifier "$LABEL" "$BIN_PATH"

echo "==> Installing launch agent"
cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key><array><string>$BIN_PATH</string></array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>StandardErrorPath</key><string>$LOG_PATH</string>
</dict>
</plist>
PLIST

launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo ""
echo "==> One manual step: grant Input Monitoring permission"
echo "    System Settings will open. Find '$BIN_PATH' in the list"
echo "    (or click + and add it) and turn it on."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"

echo ""
echo "==> After granting permission, run this to restart the agent:"
echo "    launchctl kickstart -k gui/\$(id -u)/$LABEL"
echo ""
echo "Check it's working: tail -f $LOG_PATH"
echo ""
echo "==> Current bindings"
"$BIN_PATH" list
echo ""
echo "Add your own with: $BIN_PATH add"
