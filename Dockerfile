# syntax=docker/dockerfile:1.7

# Keep Node in a separate stage so the ZeroClaw runtime stays based on the
# upstream Debian image instead of replacing its Rust binary or config layout.
FROM node:24-bookworm-slim AS node-runtime

ARG ZEROCLAW_IMAGE=ghcr.io/zeroclaw-labs/zeroclaw:debian
FROM ${ZEROCLAW_IMAGE} AS runtime

USER root

# Copy the official Node.js distribution into the upstream Debian runtime.
COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node-runtime /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules

# Install agent-browser and its managed Chrome for Testing runtime.
# Browser binaries are placed outside /root so the non-root ZeroClaw user can
# read them at runtime.
RUN set -eux; \
    mkdir -p /opt/agent-browser; \
    npm install --global agent-browser; \
    PLAYWRIGHT_BROWSERS_PATH=/opt/agent-browser agent-browser install --with-deps; \
    chmod -R a+rX /opt/agent-browser; \
    agent-browser --version; \
    node --version; \
    npm --version

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

# The official image creates /zeroclaw-data for UID/GID 65534.
# Keep the browser runtime read-only to the application user.
RUN chmod -R a+rX /opt/agent-browser

USER 65534:65534

WORKDIR /zeroclaw-data

EXPOSE 42617

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["daemon"]
