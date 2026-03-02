## Summary
OpenClaw channel linking to foreign app fails in CN network and needs explicit proxy routing for websocket.

## Environment
- openclaw version: 2026.2.26
- host: web.whatsapp.com
- proxy: http://127.0.0.1:7899

## Repro
1. Run: openclaw channels login --channel whatsapp --verbose
2. Observe timeout/handshake failure in CN network without full-route VPN.

## Connectivity Probe
`json
{
    "timestamp":  "2026-03-01T13:17:02",
    "host":  "web.whatsapp.com",
    "proxy_url":  "http://127.0.0.1:7899",
    "direct_ok":  true,
    "proxy_ok":  true,
    "advice":  "Direct path works. Do not patch OpenClaw runtime."
}
`

## Current Status
`	ext
OpenClaw status

Overview
┌─────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Item            │ Value                                                                                             │
├─────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Dashboard       │ http://192.168.1.213:18789/                                                                       │
│ OS              │ windows 10.0.19045 (x64) · node 22.22.0                                                           │
│ Tailscale       │ off                                                                                               │
│ Channel         │ stable (default)                                                                                  │
│ Update          │ pnpm · npm latest 2026.2.26                                                                       │
│ Gateway         │ local · ws://127.0.0.1:18789 (local loopback) · unreachable (connect failed: connect              │
│                 │ ECONNREFUSED 127.0.0.1:18789)                                                                     │
│ Gateway service │ Scheduled Task installed · registered · unknown                                                   │
│ Node service    │ Scheduled Task not installed                                                                      │
│ Agents          │ 1 · 1 bootstrap file present · sessions 39 · default main active 23m ago                          │
│ Memory          │ 0 files · 0 chunks · sources memory · plugin memory-core · vector unknown · fts ready · cache on  │
│                 │ (0)                                                                                               │
│ Probes          │ skipped (use --deep)                                                                              │
│ Events          │ none                                                                                              │
│ Heartbeat       │ 15m (main)                                                                                        │
│ Sessions        │ 39 active · default qwen3.5-plus (1000k ctx) · ~\.openclaw\agents\main\sessions\sessions.json     │
└─────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────┘

Security audit
Summary: 1 critical · 7 warn · 1 info
  CRITICAL DANGEROUS: Host-header origin fallback enabled
    gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback=true enables Host-header origin fallback for Control UI/WebChat websocket checks and weakens DNS reb…
    Fix: Disable gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback and configure explicit gateway.controlUi.allowedOrigins.
  WARN Insecure or dangerous config flags enabled
    Detected 1 enabled flag(s): gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback=true.
    Fix: Disable these flags when not actively debugging, or keep deployment scoped to trusted/local-only networks.
  WARN Gateway token looks short
    gateway auth token is 21 chars; prefer a long random token.
  WARN No auth rate limiting configured
    gateway.bind is not loopback but no gateway.auth.rateLimit is configured. Without rate limiting, brute-force auth attacks are not mitigated.
    Fix: Set gateway.auth.rateLimit (e.g. { maxAttempts: 10, windowMs: 60000, lockoutMs: 300000 }).
  WARN Some gateway.nodes.denyCommands entries are ineffective
    gateway.nodes.denyCommands uses exact node command-name matching only (for example `system.run`), not shell-text filtering inside a command payload. - Unknown …
    Fix: Use exact command names (for example: canvas.present, canvas.hide, canvas.navigate, canvas.eval, canvas.snapshot, canvas.a2ui.push, canvas.a2ui.pushJSONL, canvas.a2ui.reset). If you need broader restrictions, remove risky command IDs from allowCommands/default workflows and tighten tools.exec policy.
  WARN State dir is readable by others
    C:\Users\davemelo\.openclaw acl=LAPTOP-R86V51HJ\CodexSandboxUsers:(I)(OI)(CI)(RX); consider restricting to 700.
    Fix: icacls "C:\Users\davemelo\.openclaw" /inheritance:r /grant:r "LAPTOP-R86V51HJ\davemelo:(OI)(CI)F" /grant:r "SYSTEM:(OI)(CI)F"
… +2 more
Full report: openclaw security audit
Deep probe: openclaw security audit --deep

Channels
┌──────────┬─────────┬────────┬───────────────────────────────────────────────────────────────────────────────────────┐
│ Channel  │ Enabled │ State  │ Detail                                                                                │
├──────────┼─────────┼────────┼───────────────────────────────────────────────────────────────────────────────────────┤
└──────────┴─────────┴────────┴───────────────────────────────────────────────────────────────────────────────────────┘

Sessions
┌──────────────────────────────────────────────────────────────┬────────┬─────────┬──────────────┬────────────────────┐
│ Key                                                          │ Kind   │ Age     │ Model        │ Tokens             │
├──────────────────────────────────────────────────────────────┼────────┼─────────┼──────────────┼────────────────────┤
│ agent:main:main                                              │ direct │ 23m ago │ qwen3.5-plus │ 93k/1000k (9%)     │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 23m ago │ qwen3.5-plus │ 14k/1000k (1%)     │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 23m ago │ qwen3.5-plus │ 14k/1000k (1%)     │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 58m ago │ qwen3.5-plus │ 14k/1000k (1%)     │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 1h ago  │ qwen3.5-plus │ 13k/1000k (1%)     │
│ agent:main:cron:8f6549fe-ee8c-4…                             │ direct │ 4h ago  │ qwen3.5-plus │ unknown/1000k (?%) │
│ agent:main:cron:8f6549fe-ee8c-4…                             │ direct │ 4h ago  │ qwen3.5-plus │ unknown/1000k (?%) │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 5h ago  │ qwen3.5-plus │ 16k/1000k (2%)     │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 8h ago  │ qwen3.5-plus │ 16k/1000k (2%)     │
│ agent:main:cron:11b71bf0-e7f0-4…                             │ direct │ 8h ago  │ qwen3.5-plus │ 14k/1000k (1%)     │
└──────────────────────────────────────────────────────────────┴────────┴─────────┴──────────────┴────────────────────┘

FAQ: https://docs.openclaw.ai/faq
Troubleshooting: https://docs.openclaw.ai/troubleshooting

Next steps:
  Need to share?      openclaw status --all
  Need to debug live? openclaw logs --follow
  Fix reachability first: openclaw gateway probe
`

## Expected
OpenClaw should support stable proxy routing for channel websocket login without manual dist patching.