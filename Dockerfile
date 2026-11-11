# syntax=docker/dockerfile:1.7

ARG ZEROCLAW_IMAGE=ghcr.io/zeroclaw-labs/zeroclaw:debian

FROM node:24-bookworm-slim AS node-runtime
FROM ${ZEROCLAW_IMAGE} AS runtime

USER root

COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

ENV HOME=/opt/agent-browser-home
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gosu; \
    npm install --global agent-browser; \
    agent-browser install --with-deps; \
    test -x "$(find /opt/agent-browser-home/.agent-browser/browsers -type f -name chrome -print -quit)"; \
    chmod -R a+rX /opt/agent-browser-home/.agent-browser; \
    agent-browser --version; \
    node --version; \
    npm --version; \
    rm -rf /var/lib/apt/lists/*

ENV HOME=/opt/agent-browser-home \
    XDG_RUNTIME_DIR=/tmp/zeroclaw-runtime \
    AGENT_BROWSER_SOCKET_DIR=/tmp/agent-browser-sockets \
    ZEROCLAW_DATA_DIR=/zeroclaw-data/data \
    PLAYWRIGHT_BROWSERS_PATH=/opt/agent-browser-home/.agent-browser/browsers \
    ZEROCLAW_browser__enabled=true \
    ZEROCLAW_browser__automation_enabled=true \
    ZEROCLAW_browser__backend=agent_browser \
    ZEROCLAW_browser__headed=false \
    ZEROCLAW_gateway__host=0.0.0.0 \
    ZEROCLAW_gateway__allow_public_bind=true \
    ZEROCLAW_gateway__require_pairing=true

COPY --chmod=755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

RUN mkdir -p /zeroclaw-data/data /zeroclaw-data/.zeroclaw/data \
    /opt/agent-browser-home/.agent-browser \
    /tmp/zeroclaw-runtime /tmp/agent-browser-sockets \
    && chown -R 65534:65534 /zeroclaw-data /opt/agent-browser-home \
    /tmp/zeroclaw-runtime /tmp/agent-browser-sockets \
    && chmod -R a+rX /opt/agent-browser-home/.agent-browser \
    && chmod 700 /tmp/zeroclaw-runtime /tmp/agent-browser-sockets

USER root
WORKDIR /zeroclaw-data

EXPOSE 42617
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["daemon"]
