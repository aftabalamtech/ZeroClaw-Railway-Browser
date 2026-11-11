#!/bin/sh
set -eu

# Railway mounts a fresh volume at /zeroclaw-data. Repair volume ownership
# before dropping privileges to the dedicated non-root ZeroClaw user.
mkdir -p /zeroclaw-data/data /zeroclaw-data/.zeroclaw/data
chown -R 65534:65534 /zeroclaw-data

# agent-browser's daemon socket must live in a writable runtime directory.
# Keep it outside the persistent volume and browser cache.
export HOME=/opt/agent-browser-home
export XDG_RUNTIME_DIR=/tmp/zeroclaw-runtime
export AGENT_BROWSER_SOCKET_DIR=/tmp/agent-browser-sockets
mkdir -p "$XDG_RUNTIME_DIR" "$AGENT_BROWSER_SOCKET_DIR"
chown -R 65534:65534 "$XDG_RUNTIME_DIR" "$AGENT_BROWSER_SOCKET_DIR"
chmod 700 "$XDG_RUNTIME_DIR" "$AGENT_BROWSER_SOCKET_DIR"

export ZEROCLAW_DATA_DIR="${ZEROCLAW_DATA_DIR:-/zeroclaw-data/data}"
export ZEROCLAW_gateway__host="${ZEROCLAW_gateway__host:-0.0.0.0}"
export ZEROCLAW_gateway__port="${PORT:-${ZEROCLAW_gateway__port:-42617}}"

export ZEROCLAW_browser__enabled="${ZEROCLAW_browser__enabled:-true}"
export ZEROCLAW_browser__automation_enabled="${ZEROCLAW_browser__automation_enabled:-true}"
export ZEROCLAW_browser__backend="${ZEROCLAW_browser__backend:-agent_browser}"
export ZEROCLAW_browser__headed="${ZEROCLAW_browser__headed:-false}"

exec gosu 65534:65534 /usr/local/bin/zeroclaw "$@"
