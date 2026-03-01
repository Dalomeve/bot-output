---
name: cn-vpn-foreign-app-link
description: Fix OpenClaw connectivity to foreign apps for users in China without resetting existing tasks or tokens. Use when WhatsApp/Telegram/Discord linking fails with WebSocket timeout or handshake errors (for example status=408 Request Time-out, Opening handshake has timed out), when direct outbound access is blocked but VPN/proxy is available, or when OpenClaw can reach local dashboard but channels remain "Not linked".
---

# CN VPN Foreign App Link

## Goal

Keep current OpenClaw config and session data intact while restoring channel login for foreign apps.

Prioritize network-level fixes first, then use runtime proxy patch only as fallback.

## Execution Contract

1. Preserve user data:
- Do not regenerate `gateway.auth.token` unless user explicitly asks.
- Do not delete `~/.openclaw` content.

2. Evidence-first:
- After each step, provide command outcome summary and next action.
- Do not stop at "I will now..."; always execute.

3. Fix order:
- Step A: diagnose direct vs proxy reachability.
- Step B: prefer VPN TUN/global mode.
- Step C: only then patch OpenClaw runtime websocket proxy.
- Step D: verify channel link state.

## Workflow

### 1) Baseline checks

Run:

```powershell
openclaw status
openclaw channels list
```

Then run connectivity probe:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check_connectivity.ps1 -TargetHost web.whatsapp.com -ProxyUrl http://127.0.0.1:7899
```

Interpretation:
- `direct_ok=true`: network path is open; do not patch runtime.
- `direct_ok=false` and `proxy_ok=true`: route issue exists; continue.
- both false: stop and ask user to fix VPN/proxy itself.

### 2) Preferred fix (network layer)

Read [references/troubleshooting.md](references/troubleshooting.md), section `Preferred network fix`.

Apply OS/VPN routing first (TUN or global mode) so all Node websocket traffic is tunneled.

### 3) Fallback fix (runtime proxy patch)

If VPN cannot provide TUN/global, apply deterministic patch:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/apply_openclaw_ws_proxy_patch.ps1 -ProxyUrl http://127.0.0.1:7899
openclaw channels login --channel whatsapp --verbose
```

If needed, rollback:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/rollback_openclaw_ws_proxy_patch.ps1
```

### 4) Verify done state

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_link_state.ps1 -Channel whatsapp
```

Done criteria:
- QR can be produced or account is already linked.
- `openclaw status` channel detail no longer shows `gateway: Not linked`.

### 5) Optional issue report for upstream

Generate a sanitized report:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_issue_report.ps1 -OutFile .\openclaw-foreign-app-link-issue.md
```

Use this report body when creating an issue in `openclaw/openclaw`.
