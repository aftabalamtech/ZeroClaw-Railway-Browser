# ZeroClaw Railway Browser

A Railway-oriented deployment wrapper for the official [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw) Debian container, with the `agent-browser` CLI and Chrome for Testing installed in the **runtime image**.

This repository does not fork or vendor the ZeroClaw source tree. It extends the upstream Debian runtime image so upstream's ZeroClaw binary, dashboard assets, configuration layout, and startup behavior remain intact.

## Features

- Official ZeroClaw Debian runtime image as the base.
- Node.js 24 and `agent-browser` CLI.
- Chrome for Testing installed during the Docker build.
- Browser binaries stored in `/opt/agent-browser`, readable by ZeroClaw's non-root runtime user.
- Browser automation enabled with the `agent_browser` backend.
- Headless browser mode suitable for Railway containers.
- Railway's runtime `PORT` is mapped to the ZeroClaw gateway port.
- Gateway pairing remains enabled.
- Persistent ZeroClaw data stays under `/zeroclaw-data`.

## Architecture

```text
Railway
  |
  +-- Docker image
        |
        +-- Upstream ZeroClaw Debian image
        |     +-- zeroclaw binary
        |     +-- dashboard assets
        |     +-- upstream config/data layout
        |
        +-- Node.js 24
        +-- agent-browser CLI
        +-- Chrome for Testing
        |
        +-- railway-entrypoint.sh
              +-- reads Railway PORT
              +-- enables browser automation
              +-- starts `zeroclaw daemon`
```

## Deploy to Railway

1. Create a new GitHub repository and upload/push the contents of this project.
2. In Railway, choose **New Project → Deploy from GitHub repo**.
3. Select this repository. Railway detects `railway.json` and builds with the included Dockerfile.
4. Add a Railway Volume mounted at:

   ```text
   /zeroclaw-data
   ```

   This is important: ZeroClaw configuration, workspace data, sessions, and other state must survive container replacement.

5. Add your model provider credentials as Railway environment variables. For example, OpenRouter:

   ```text
   ZEROCLAW_providers__models__openrouter__default__api_key=YOUR_OPENROUTER_API_KEY
   ZEROCLAW_providers__models__openrouter__default__model=anthropic/claude-sonnet-4-20250514
   ```

6. Generate a public domain for the service. Railway supplies `PORT` automatically; the entrypoint maps it to the ZeroClaw gateway.
7. Deploy and inspect the build/deploy logs.

> Do not add a second `PORT` value manually. Railway owns that variable.

## Browser configuration

Browser automation is enabled by default in this deployment:

```text
ZEROCLAW_browser__enabled=true
ZEROCLAW_browser__automation_enabled=true
ZEROCLAW_browser__backend=agent_browser
ZEROCLAW_browser__headed=false
```

These are ZeroClaw's v0.8.x environment-variable overrides. You can override them in Railway Variables.

### Domain restrictions

ZeroClaw's browser `allowed_domains` default is `["*"]`. For a safer deployment, set a narrow allowlist in Railway, using a JSON/TOML array string:

```text
ZEROCLAW_browser__allowed_domains=["github.com","google.com","docs.zeroclaw.com"]
```

Add only the domains your agent genuinely needs. The browser tool can access logged-in sessions, so do not grant broad access casually.

### Test the browser

After deployment, use Railway's service shell/command interface (if available for the selected image) or connect through your configured ZeroClaw channel and ask the agent:

```text
Open https://example.com and tell me the page title and the visible text.
```

The upstream CLI checks, when a shell is available, are:

```bash
agent-browser --version
agent-browser open https://example.com
agent-browser get title
agent-browser snapshot -i
agent-browser close
```

ZeroClaw integration test:

```bash
echo "Open https://example.com and tell me what it says" | zeroclaw agent -a assistant
```

The exact agent alias may differ in your configuration.

## Gateway security

- `ZEROCLAW_gateway__require_pairing=true` is retained.
- Do not disable pairing on a public Railway deployment.
- Do not add `"browser"` to a risk profile's `auto_approve` list unless you explicitly accept unattended browser actions.
- Restrict `ZEROCLAW_browser__allowed_domains`.
- Never commit API keys, cookies, browser profiles, or `.env` files.
- Treat any website content as untrusted input. Do not let webpage instructions override the agent's system policy.

To pair a client, use the pairing flow exposed by the ZeroClaw dashboard/CLI for your installed version. Keep the generated pairing credential private.

## Versioning and upstream updates

The Dockerfile defaults to:

```text
ghcr.io/zeroclaw-labs/zeroclaw:debian
```

This is the official Debian runtime tag. It is intentionally used instead of the distroless image because this deployment needs a package manager during image construction and a shell-capable runtime for diagnostics.

For reproducible production deployments, pin the base image to a verified upstream release tag or immutable digest. You can override the Docker build argument `ZEROCLAW_IMAGE` in your build configuration. Do not assume a tag exists without checking the upstream GHCR package.

The browser documentation this wrapper targets is ZeroClaw v0.8.7. Review the upstream release notes and browser/config docs before changing the base image version.

## Local build

```bash
docker build \
  --build-arg ZEROCLAW_IMAGE=ghcr.io/zeroclaw-labs/zeroclaw:debian \
  -t zeroclaw-railway-browser:local .
```

Run locally with a persistent data directory:

```bash
mkdir -p ./zeroclaw-data

docker run --rm \
  -p 42617:42617 \
  -e PORT=42617 \
  -e ZEROCLAW_providers__models__openrouter__default__api_key="$OPENROUTER_API_KEY" \
  -e ZEROCLAW_providers__models__openrouter__default__model="anthropic/claude-sonnet-4-20250514" \
  -v "$PWD/zeroclaw-data:/zeroclaw-data" \
  zeroclaw-railway-browser:local
```

## Important scope note: graphical browser

This first version provides **headless browser automation** for the AI agent. It does not expose a public VNC/noVNC desktop. A live graphical browser should be added as a separately authenticated feature (for example, behind a password-protected reverse proxy or private network), not exposed as an unauthenticated public port.

## Upstream documentation

- [ZeroClaw official repository](https://github.com/zeroclaw-labs/zeroclaw)
- [Browser Automation — v0.8.7](https://docs.zeroclaw.com/v0.8.7/en/tools/browser.html)
- [Configuration Reference — v0.8.7](https://docs.zeroclaw.com/v0.8.7/en/reference/config.html)
- [agent-browser](https://github.com/vercel-labs/agent-browser)

## License

This deployment wrapper's original files are provided under the MIT License. ZeroClaw remains a separate upstream project, dual-licensed under MIT OR Apache-2.0. See the upstream repository for its complete license and attribution notices.
