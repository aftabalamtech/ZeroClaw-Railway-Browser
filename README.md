# ZeroClaw Railway Browser

Railway deployment wrapper for ZeroClaw with the `agent-browser` CLI and a headless Chrome for Testing installation.

## What this image contains

- Upstream ZeroClaw Debian runtime image (configurable with `ZEROCLAW_IMAGE`).
- Node.js 24 and the `agent-browser` CLI.
- Chrome for Testing and Linux browser dependencies installed during the Docker build.
- Browser files in `/opt/agent-browser`, readable by the non-root ZeroClaw runtime user.
- Browser automation enabled with the `agent_browser` backend.
- Railway's injected `PORT` mapped to `ZEROCLAW_gateway__port`.
- Persistent application data under `/zeroclaw-data`.

This project extends the upstream runtime image; it does not fork or rebuild the ZeroClaw Rust application.

## Deploy on Railway

1. Connect this GitHub repository to a Railway service.
2. Set the builder to Dockerfile (Railway detects `railway.json` automatically).
3. Add a Railway Volume mounted at `/zeroclaw-data`.
4. Set your provider credentials and model settings in Railway Variables.
5. Generate a Railway public domain and deploy.

Railway provides `PORT` automatically. Do not hard-code a different gateway port in Railway.

### Example provider variables

Use the provider/model identifier supported by your own ZeroClaw configuration:

```env
ZEROCLAW_providers__models__openrouter__default__api_key=YOUR_OPENROUTER_API_KEY
ZEROCLAW_providers__models__openrouter__default__model=anthropic/claude-sonnet-4-20250514
```

## Browser settings

These defaults are already present in the image; they can be overridden in Railway:

```env
ZEROCLAW_browser__enabled=true
ZEROCLAW_browser__automation_enabled=true
ZEROCLAW_browser__backend=agent_browser
ZEROCLAW_browser__headed=false
```

Restrict browsing to the domains your agent actually needs:

```env
ZEROCLAW_browser__allowed_domains=["github.com","google.com","docs.zeroclaw.com"]
```

Avoid wildcard access for agents that can use authenticated browser sessions.

## Browser CLI smoke test

When you have shell access to a running container:

```bash
agent-browser --version
agent-browser open https://example.com
agent-browser get title
agent-browser snapshot -i
agent-browser close
```

You can also ask the ZeroClaw agent to open `https://example.com` and report its title and visible text.

## Local build

```bash
docker build -t zeroclaw-railway-browser:local .
```

Local run:

```bash
mkdir -p ./zeroclaw-data

docker run --rm \
  -p 42617:42617 \
  -e PORT=42617 \
  -v "$PWD/zeroclaw-data:/zeroclaw-data" \
  zeroclaw-railway-browser:local
```

## Graphical browser / VNC

This image runs the browser headlessly for agent automation. It does not expose a public VNC/noVNC desktop. A live interactive browser should be deployed separately behind authentication or a private network—not exposed as an unauthenticated Railway port.

## Upstream references

- [ZeroClaw repository](https://github.com/zeroclaw-labs/zeroclaw)
- [ZeroClaw v0.8.7 browser documentation](https://docs.zeroclaw.com/v0.8.7/en/tools/browser.html)
- [agent-browser](https://github.com/vercel-labs/agent-browser)
