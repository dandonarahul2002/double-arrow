#!/usr/bin/env bash
set -euo pipefail

LABEL="com.doublearrow.agent"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl unload "$PLIST_PATH" 2>/dev/null || true
rm -f "$PLIST_PATH"

echo "Uninstalled. Remove '$LABEL' from System Settings > Privacy & Security > Input Monitoring if you want to clean that up too."
