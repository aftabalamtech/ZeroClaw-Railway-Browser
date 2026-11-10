# syntax=docker/dockerfile:1.7

# Global build argument: it must be declared before the first FROM to be
# available for variable expansion in a later FROM instruction.
ARG ZEROCLAW_IMAGE=ghcr.io/zeroclaw-labs/zeroclaw:debian

FROM node:24-bookworm-slim AS node-runtime

FROM ${ZEROCLAW_IMAGE} AS runtime

USER root

# Copy Node.js and npm from the official Node image.
COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

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

RUN mkdir -p /zeroclaw-data/data /zeroclaw-data/.zeroclaw \
    && chown -R 65534:65534 /zeroclaw-data \
    && chmod -R a+rX /opt/agent-browser

USER 65534:65534
WORKDIR /zeroclaw-data

EXPOSE 42617
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["daemon"]
