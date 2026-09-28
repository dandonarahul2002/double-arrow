#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_PATH="$ROOT_DIR/bin/double-arrow"
LABEL="com.doublearrow.agent"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_PATH="$HOME/Library/Logs/$LABEL.log"

echo "==> Building"
mkdir -p "$ROOT_DIR/bin"
swiftc -O "$ROOT_DIR"/Sources/*.swift -o "$BIN_PATH"

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
