# ZeroClaw Railway Browser

Railway deployment wrapper for the upstream ZeroClaw Debian runtime with Node.js 24, `agent-browser`, and headless Chrome for Testing.

## Included

- Upstream ZeroClaw Debian runtime image.
- Node.js 24 and global `agent-browser` CLI.
- Chrome for Testing and Linux dependencies installed at image-build time.
- Browser cache stored under `/opt/agent-browser-home/.agent-browser/browsers`, outside the Railway volume mount.
- ZeroClaw data stored separately under `/zeroclaw-data/data`.
- Railway's injected `PORT` mapped to the ZeroClaw gateway port.
- Non-root runtime user (UID/GID 65534).

## Deploy on Railway

1. Connect this repository as a Railway service using the Dockerfile builder.
2. Add a Railway Volume mounted at `/zeroclaw-data`.
3. Add your model provider credentials and model settings as Railway Variables.
4. Generate a public domain and deploy. Railway supplies `PORT`; do not set it manually.

Example OpenRouter variables (use a model ID supported by your ZeroClaw version):

```env
ZEROCLAW_providers__models__openrouter__default__api_key=YOUR_OPENROUTER_API_KEY
ZEROCLAW_providers__models__openrouter__default__model=anthropic/claude-sonnet-4-20250514
```

## Browser configuration

The image enables these settings by default:

```env
ZEROCLAW_browser__enabled=true
ZEROCLAW_browser__automation_enabled=true
ZEROCLAW_browser__backend=agent_browser
ZEROCLAW_browser__headed=false
```

Set a restricted domain allowlist for production:

```env
ZEROCLAW_browser__allowed_domains=["github.com","google.com","docs.zeroclaw.com"]
```

## Browser smoke test

In a shell inside the running container:

```bash
agent-browser --version
agent-browser open https://example.com
agent-browser get title
agent-browser snapshot -i
agent-browser close
```

## Local Docker build

```bash
docker build -t zeroclaw-railway-browser:local .
```

## Important

This is headless browser automation; it does not provide a VNC/noVNC graphical desktop. Do not expose a browser desktop publicly without authentication and network restrictions.

## Upstream

- [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw)
- [ZeroClaw browser docs v0.8.7](https://docs.zeroclaw.com/v0.8.7/en/tools/browser.html)
- [agent-browser installation](https://agent-browser.dev/installation)
- [agent-browser configuration](https://agent-browser.dev/configuration)
