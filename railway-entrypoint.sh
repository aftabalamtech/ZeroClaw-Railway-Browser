#!/bin/sh
set -eu

# Railway mounts a fresh volume at /zeroclaw-data. A Dockerfile chown cannot
# change the mounted volume's ownership, so fix it at container startup.
mkdir -p /zeroclaw-data/data /zeroclaw-data/.zeroclaw/data
chown -R 65534:65534 /zeroclaw-data

# Browser binaries are baked into the image, outside the mounted volume.
export HOME=/opt/agent-browser-home
export ZEROCLAW_DATA_DIR="${ZEROCLAW_DATA_DIR:-/zeroclaw-data/data}"
export ZEROCLAW_gateway__host="${ZEROCLAW_gateway__host:-0.0.0.0}"
export ZEROCLAW_gateway__port="${PORT:-${ZEROCLAW_gateway__port:-42617}}"

export ZEROCLAW_browser__enabled="${ZEROCLAW_browser__enabled:-true}"
export ZEROCLAW_browser__automation_enabled="${ZEROCLAW_browser__automation_enabled:-true}"
export ZEROCLAW_browser__backend="${ZEROCLAW_browser__backend:-agent_browser}"
export ZEROCLAW_browser__headed="${ZEROCLAW_browser__headed:-false}"

exec gosu 65534:65534 /usr/local/bin/zeroclaw "$@"
