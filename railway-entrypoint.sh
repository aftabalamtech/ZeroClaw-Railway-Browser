#!/bin/sh
set -eu

# Repair ownership of the mounted Railway volume before dropping privileges.
mkdir -p /zeroclaw-data/data /zeroclaw-data/.zeroclaw/data
chown -R 65534:65534 /zeroclaw-data

# agent-browser socket and runtime directories must be writable by ZeroClaw.
export HOME=/opt/agent-browser-home
export XDG_RUNTIME_DIR=/tmp/zeroclaw-runtime
export AGENT_BROWSER_SOCKET_DIR=/tmp/agent-browser-sockets
mkdir -p "$XDG_RUNTIME_DIR" "$AGENT_BROWSER_SOCKET_DIR"
chown -R 65534:65534 "$XDG_RUNTIME_DIR" "$AGENT_BROWSER_SOCKET_DIR"
chmod 700 "$XDG_RUNTIME_DIR" "$AGENT_BROWSER_SOCKET_DIR"

# Do not rely on HOME-based Chrome discovery: ZeroClaw or its child process
# may run with HOME=/nonexistent. Pass the exact browser binary baked in image.
if [ -r /etc/agent-browser-chrome-path ]; then
  CHROME_BIN="$(cat /etc/agent-browser-chrome-path)"
  if [ -x "$CHROME_BIN" ]; then
    export AGENT_BROWSER_EXECUTABLE_PATH="$CHROME_BIN"
  else
    echo "Configured Chrome binary is missing or not executable: $CHROME_BIN" >&2
    exit 1
  fi
else
  echo "Chrome path manifest missing: /etc/agent-browser-chrome-path" >&2
  exit 1
fi

export ZEROCLAW_DATA_DIR="${ZEROCLAW_DATA_DIR:-/zeroclaw-data/data}"
export ZEROCLAW_gateway__host="${ZEROCLAW_gateway__host:-0.0.0.0}"
export ZEROCLAW_gateway__port="${PORT:-${ZEROCLAW_gateway__port:-42617}}"

export ZEROCLAW_browser__enabled="${ZEROCLAW_browser__enabled:-true}"
export ZEROCLAW_browser__automation_enabled="${ZEROCLAW_browser__automation_enabled:-true}"
export ZEROCLAW_browser__backend="${ZEROCLAW_browser__backend:-agent_browser}"
export ZEROCLAW_browser__headed="${ZEROCLAW_browser__headed:-false}"

exec gosu 65534:65534 /usr/local/bin/zeroclaw "$@"
