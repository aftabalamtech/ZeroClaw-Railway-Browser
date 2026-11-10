#!/bin/sh
set -eu

# Keep agent-browser's HOME outside /zeroclaw-data because Railway mounts a
# persistent volume at /zeroclaw-data and that mount would hide baked files.
export HOME="${HOME:-/opt/agent-browser-home}"
export ZEROCLAW_DATA_DIR="${ZEROCLAW_DATA_DIR:-/zeroclaw-data/data}"
export ZEROCLAW_gateway__host="${ZEROCLAW_gateway__host:-0.0.0.0}"
export ZEROCLAW_gateway__port="${PORT:-${ZEROCLAW_gateway__port:-42617}}"

export ZEROCLAW_browser__enabled="${ZEROCLAW_browser__enabled:-true}"
export ZEROCLAW_browser__automation_enabled="${ZEROCLAW_browser__automation_enabled:-true}"
export ZEROCLAW_browser__backend="${ZEROCLAW_browser__backend:-agent_browser}"
export ZEROCLAW_browser__headed="${ZEROCLAW_browser__headed:-false}"

exec /usr/local/bin/zeroclaw "$@"
