### Summary
In CN networks, channel login to foreign apps (especially WhatsApp) can fail with websocket handshake timeout even when HTTPS via local proxy works.

### Affected Version
- OpenClaw: 2026.2.26
- OS: Windows 10 x64

### Repro Steps
1. Configure OpenClaw normally (`gateway` healthy, dashboard reachable).
2. Ensure direct outbound is restricted but local proxy is available (example: Clash mixed-port `127.0.0.1:7899`).
3. Run:
   ```bash
   openclaw channels login --channel whatsapp --verbose
   ```
4. Observe:
   - `status=408 Request Time-out WebSocket Error (Opening handshake has timed out)`

### Network Observation
- `https://web.whatsapp.com` is reachable via proxy (`curl -x http://127.0.0.1:7899 ...` returns 200).
- Direct path may fail/timeout depending on route.
- Current channel websocket path does not consistently honor proxy routing in this setup.

### Temporary Workaround (validated)
Inject explicit `HttpsProxyAgent` into OpenClaw whatsapp session socket creation (`makeWASocket` options `agent: wsAgent`) and use:
- `OPENCLAW_WHATSAPP_PROXY=http://127.0.0.1:7899`

After this, QR can be generated and login proceeds.

### Expected
Official proxy support for channel websocket login without dist patching.

### Proposal
1. Add config key for channel websocket proxy, e.g.:
   - `channels.whatsapp.proxyUrl`
2. Or consistently honor `HTTPS_PROXY`/`HTTP_PROXY`/`ALL_PROXY` for channel websocket connections.
3. Add troubleshooting hint in docs for CN network + VPN/proxy cases.

### Why this matters
Many CN users can access foreign services only through VPN/proxy. Without first-class proxy handling for websocket channel login, channel setup appears broken even when proxy path is healthy.