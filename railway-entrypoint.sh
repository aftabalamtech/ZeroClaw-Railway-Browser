#!/bin/sh
set -eu

# Railway injects PORT at runtime. ZeroClaw's gateway must listen on that port.
export HOME="${HOME:-/zeroclaw-data}"
export ZEROCLAW_DATA_DIR="${ZEROCLAW_DATA_DIR:-/zeroclaw-data/data}"
export ZEROCLAW_gateway__host="${ZEROCLAW_gateway__host:-0.0.0.0}"
export ZEROCLAW_gateway__port="${PORT:-${ZEROCLAW_gateway__port:-42617}}"

# Browser automation is opt-in in upstream ZeroClaw. This deployment enables
# the agent-browser backend while preserving explicit operator overrides.
export ZEROCLAW_browser__enabled="${ZEROCLAW_browser__enabled:-true}"
export ZEROCLAW_browser__automation_enabled="${ZEROCLAW_browser__automation_enabled:-true}"
export ZEROCLAW_browser__backend="${ZEROCLAW_browser__backend:-agent_browser}"
export ZEROCLAW_browser__headed="${ZEROCLAW_browser__headed:-false}"
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-/opt/agent-browser}"

exec /usr/local/bin/zeroclaw "$@"
