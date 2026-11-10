# syntax=docker/dockerfile:1.7

# Build the browser runtime on Debian Bookworm. Keep the ZeroClaw runtime
# image configurable so operators can pin a verified upstream tag or digest.
FROM node:24-bookworm-slim AS node-runtime

ARG ZEROCLAW_IMAGE=ghcr.io/zeroclaw-labs/zeroclaw:debian
FROM ${ZEROCLAW_IMAGE} AS runtime

# This ARG must be redeclared inside the stage before it can be used.
ARG ZEROCLAW_IMAGE

USER root

# Copy the Node.js distribution and npm global modules from the official Node
# image. The agent-browser package is installed below in the ZeroClaw runtime.
COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules

# Recreate npm/npx shims explicitly; the Node image stores their JS entrypoints
# in the npm global module tree.
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install browser OS dependencies and agent-browser as root during build.
# Chrome is downloaded into a stable shared path readable by UID 65534.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/agent-browser
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    npm install --global agent-browser; \
    agent-browser install --with-deps; \
    chmod -R a+rX /opt/agent-browser; \
    agent-browser --version; \
    node --version; \
    npm --version; \
    rm -rf /var/lib/apt/lists/*

ENV HOME=/zeroclaw-data \
    ZEROCLAW_DATA_DIR=/zeroclaw-data/data \
    PLAYWRIGHT_BROWSERS_PATH=/opt/agent-browser \
    ZEROCLAW_browser__enabled=true \
    ZEROCLAW_browser__automation_enabled=true \
    ZEROCLAW_browser__backend=agent_browser \
    ZEROCLAW_browser__headed=false \
    ZEROCLAW_gateway__host=0.0.0.0 \
    ZEROCLAW_gateway__allow_public_bind=true \
    ZEROCLAW_gateway__require_pairing=true

COPY --chmod=755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

# Ensure the persistent data directory exists and remains writable by the
# upstream non-root user. Browser binaries remain read/execute-only.
RUN mkdir -p /zeroclaw-data/data /zeroclaw-data/.zeroclaw \
    && chown -R 65534:65534 /zeroclaw-data \
    && chmod -R a+rX /opt/agent-browser

USER 65534:65534
WORKDIR /zeroclaw-data

EXPOSE 42617

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["daemon"]
