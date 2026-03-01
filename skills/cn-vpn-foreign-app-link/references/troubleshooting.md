# Troubleshooting Matrix

## Preferred network fix

Use full-route mode first so Node websocket traffic is tunneled:
- Clash for Windows: enable `TUN` or switch mode to `Global`.
- Other VPN clients: enable system-level tunnel, not browser-only proxy.

Then retry:

```powershell
openclaw channels login --channel whatsapp --verbose
```

## Symptom -> Action

1. `status=408 Request Time-out WebSocket Error (Opening handshake has timed out)`
- Direct blocked. Check proxy path with `scripts/check_connectivity.ps1`.
- If proxy works, use network fix; fallback to runtime patch script.

2. `unauthorized: gateway token missing` in dashboard logs
- Control UI is missing token.
- Open dashboard and paste `gateway.auth.token` in Control UI settings.
- Do not regenerate token unless user requests rotation.

3. `gateway.bind=loopback` and mobile pairing cannot connect
- Set bind to LAN:
```powershell
openclaw config set gateway.bind lan
openclaw gateway restart
```

4. QR prints as garbled blocks in terminal
- This is terminal encoding only.
- Login still works; scan with phone camera.

## Safety notes

- Keep user API keys/tokens out of issue reports and git commits.
- Prefer rollback script before reinstalling OpenClaw.
- Reinstalling OpenClaw does not erase `~/.openclaw` by default, but still avoid unnecessary reinstall.
