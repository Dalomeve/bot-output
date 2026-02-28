---
name: openclaw-growth-pack
version: 1.0.0
description: High-impact onboarding skill for fresh OpenClaw users. Proven setup for model routing, gateway hardening, autonomy loops, and continuous improvement.
metadata:
  openclaw:
    emoji: "🚀"
    category: onboarding
    tags:
      - setup
      - onboarding
      - best-practices
      - autonomy
      - hardening
---

# OpenClaw Growth Pack 🚀

**The Ultimate Onboarding Skill for Fresh OpenClaw Users**

Get your OpenClaw instance production-ready in minutes with our proven setup. This skill combines battle-tested configurations for model routing, gateway security, autonomous execution, and continuous self-improvement.

## Why This Skill?

New OpenClaw users often struggle with:
- ❌ Inconsistent model routing causing failures
- ❌ Gateway token mismatches breaking authentication
- ❌ Missing heartbeat hardening leading to stalls
- ❌ No autonomy setup requiring constant prompting
- ❌ Lack of self-healing mechanisms for repeated failures
- ❌ No verification or rollback procedures

**Growth Pack solves all of these** with a single, integrated setup.

## What You Get

| Component | Purpose | Time Saved |
|-----------|---------|------------|
| Model Routing Setup | Reliable bailian/qwen3-coder-plus routing | 30+ min |
| Gateway Token Consistency | Prevent auth failures across CLI/UI/runtime | 45+ min |
| HEARTBEAT Hardening | Anti-stall execution with evidence requirements | 60+ min |
| Autonomy Cron Setup | Scheduled self-improvement and task execution | 90+ min |
| Memory Self-Heal Integration | Auto-recover from repeated failure patterns | 120+ min |
| Evidence Link Auditor | Pre-merge validation and quality assurance | 45+ min |
| Verification Checklist | Ensure setup completeness | 30+ min |
| Rollback Plan | Safe recovery from misconfigurations | 60+ min |
| Daily/Weekly Improvement Loop | Continuous optimization | Ongoing |

**Total Time Saved: 6+ hours of trial-and-error**

## Quick Start

```powershell
# Install the skill
openclaw skill install openclaw-growth-pack

# Run the setup wizard
openclaw skill run openclaw-growth-pack --mode setup

# Verify installation
openclaw skill run openclaw-growth-pack --mode verify
```

## Component 1: Strong Model Routing Setup

### Configuration

Ensure `~/.openclaw/openclaw.json` contains:

```json
{
  "models": {
    "providers": {
      "bailian": {
        "baseUrl": "https://coding.dashscope.aliyuncs.com/v1",
        "apiKey": "${BAILIAN_API_KEY}"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "bailian/qwen3-coder-plus",
        "fallback": "bailian/qwen3.5-plus"
      }
    }
  }
}
```

### Verification Steps

```powershell
# Check model routing
openclaw config get | Select-Object -ExpandProperty models

# Test model connectivity
openclaw sessions spawn --task "Test connection" --model bailian/qwen3-coder-plus

# Verify fallback works
openclaw sessions spawn --task "Fallback test" --model bailian/qwen3.5-plus
```

### Common Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Wrong base URL | 404 errors on model calls | Set to `https://coding.dashscope.aliyuncs.com/v1` |
| Missing API key | "unconfigured" errors | Run `openclaw configure --section models` |
| Model name typo | "model not found" | Use exact name `bailian/qwen3-coder-plus` |

## Component 2: Gateway Token Consistency Checks

### Token Locations

Gateway token must be consistent across:

1. `~/.openclaw/openclaw.json` → `gateway.auth.token`
2. `~/.openclaw/openclaw.json` → `gateway.remote.token`
3. `~/.openclaw/gateway.cmd` → `OPENCLAW_GATEWAY_TOKEN` environment variable
4. `~/.openclaw/agents/main/agent/models.json` (if exists) → must not override

### Consistency Check Script

```powershell
# Run token consistency audit
$configToken = (Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json).gateway.auth.token
$remoteToken = (Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json).gateway.remote.token
$envToken = [Environment]::GetEnvironmentVariable("OPENCLAW_GATEWAY_TOKEN", "User")

Write-Host "Config token: $configToken"
Write-Host "Remote token: $remoteToken"
Write-Host "Env token: $envToken"

if ($configToken -ne $remoteToken) {
    Write-Warning "Token mismatch: config != remote"
}
if ($configToken -ne $envToken) {
    Write-Warning "Token mismatch: config != env"
}
```

### Fix Command

```powershell
# Generate new token and apply consistently
$newToken = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})

# Update config
$config = Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json
$config.gateway.auth.token = $newToken
$config.gateway.remote.token = $newToken
$config | ConvertTo-Json -Depth 10 | Set-Content ~/.openclaw/openclaw.json

# Update environment
[Environment]::SetEnvironmentVariable("OPENCLAW_GATEWAY_TOKEN", $newToken, "User")

# Restart gateway
openclaw gateway restart
```

## Component 3: AGENTS HEARTBEAT Hardening

### HEARTBEAT.md Requirements

Ensure `HEARTBEAT.md` contains:

```markdown
# HEARTBEAT.md

## Heartbeat Policy

Keep each heartbeat cheap and useful. Do at most 1-2 checks per cycle.
Heartbeat must produce either execution evidence or `HEARTBEAT_OK`.

## Rotation Checklist

1. Check whether there is any unfinished task that can be advanced automatically.
2. Check gateway/model health only if there was a recent failure signal.
3. Check for blockers that require minimal user input.
4. Re-check constraints in `CAPABILITIES.md` before choosing work.
5. Read `tasks/QUEUE.md`, pick one highest-priority actionable item, execute one concrete step, and write evidence.

## Evidence Requirement

When heartbeat executes work, append a compact proof to `memory/YYYY-MM-DD.md`:

- action executed
- artifact path/url/id
- verification command summary

If no actionable item exists, reply exactly `HEARTBEAT_OK`.
```

### Anti-Stall Rules

- Planning-only replies allowed once at most
- Next reply must contain execution evidence or concrete blocker
- Never end with "I will now..." without showing tool result
- Require DONE_CHECKLIST + EVIDENCE block for multi-step tasks

## Component 4: Autonomy Cron Setup

### Recommended Cron Jobs

```json
{
  "jobs": [
    {
      "name": "daily-heartbeat-check",
      "schedule": { "kind": "cron", "expr": "0 9 * * *", "tz": "Asia/Shanghai" },
      "payload": { "kind": "systemEvent", "text": "HEARTBEAT: Check for unfinished tasks and blocked items" },
      "sessionTarget": "main",
      "enabled": true
    },
    {
      "name": "weekly-self-improvement",
      "schedule": { "kind": "cron", "expr": "0 10 * * 0", "tz": "Asia/Shanghai" },
      "payload": { "kind": "systemEvent", "text": "SELF-IMPROVE: Review last 7 days of memory, identify friction patterns, update skills/local/" },
      "sessionTarget": "main",
      "enabled": true
    },
    {
      "name": "hourly-queue-check",
      "schedule": { "kind": "every", "everyMs": 3600000 },
      "payload": { "kind": "systemEvent", "text": "QUEUE: Check tasks/QUEUE.md for actionable items" },
      "sessionTarget": "main",
      "enabled": true
    }
  ]
}
```

### Setup Commands

```powershell
# Add daily heartbeat check
openclaw cron add --job '{
  "name": "daily-heartbeat-check",
  "schedule": { "kind": "cron", "expr": "0 9 * * *", "tz": "Asia/Shanghai" },
  "payload": { "kind": "systemEvent", "text": "HEARTBEAT: Check for unfinished tasks and blocked items" },
  "sessionTarget": "main",
  "enabled": true
}'

# Add weekly self-improvement
openclaw cron add --job '{
  "name": "weekly-self-improvement",
  "schedule": { "kind": "cron", "expr": "0 10 * * 0", "tz": "Asia/Shanghai" },
  "payload": { "kind": "systemEvent", "text": "SELF-IMPROVE: Review last 7 days of memory, identify friction patterns, update skills/local/" },
  "sessionTarget": "main",
  "enabled": true
}'

# List cron jobs to verify
openclaw cron list
```

## Component 5: Memory Self-Heal Integration

### Integration Steps

1. **Install memory-self-heal skill** (already in bot-output)
2. **Configure trigger patterns** in `memory/self-heal-config.md`
3. **Set up blocked-items tracking** in `memory/blocked-items.md`
4. **Enable automatic pattern detection** on task failures

### Trigger Patterns

| Pattern | Detection | Auto-Fix |
|---------|-----------|----------|
| PowerShell syntax error | exec fails with bash flags | Retry with native cmdlets |
| Missing API key | Tool error mentions "unconfigured" | Prompt with exact config command |
| Login wall | Browser shows auth form | Switch profile or request attach |
| Context exhausted | Error mentions token limit | Split task or reduce payload |
| False completion | No EVIDENCE block | Require checklist before done |

### Memory File Structure

```
memory/
├── YYYY-MM-DD.md          # Daily lessons and execution logs
├── tasks.md               # Task state tracking
├── blocked-items.md       # Documented blockers with unblock inputs
├── self-heal-config.md    # Pattern detection configuration
└── friction-patterns.md   # Repeated failure patterns and fixes
```

## Component 6: Evidence Link Auditor Integration

### Pre-Merge Validation

Before marking any task complete:

```powershell
# Run evidence link audit
openclaw skill run evidence-link-auditor --target ./outputs/latest

# Check for unresolved markers
openclaw skill run evidence-link-auditor --markers-only

# Verify all links are accessible
openclaw skill run evidence-link-auditor --links-only
```

### Pass/Fail Criteria

**PASS** (all must be true):
- All external links return HTTP 200 or valid redirect
- All internal links resolve to existing files
- No unresolved markers (PENDING, TODO, TBD) in deliverables
- Commit hashes exist in repository
- Screenshot/artifact links are still hosted

**FAIL** (any triggers failure):
- Any link returns 404, 403, or 5xx error
- Internal reference points to non-existent file
- Unresolved markers found in claimed-complete work
- SSL certificate errors on HTTPS links

## Verification Checklist

Run this checklist after setup:

### Model Routing
- [ ] `openclaw config get` shows correct bailian baseUrl
- [ ] Primary model is `bailian/qwen3-coder-plus`
- [ ] Test session spawns successfully with primary model
- [ ] Fallback model works if primary fails

### Gateway Token
- [ ] Config token matches remote token
- [ ] Config token matches environment variable
- [ ] Gateway restarts without auth errors
- [ ] CLI and UI can both connect

### Heartbeat
- [ ] HEARTBEAT.md exists with required sections
- [ ] Heartbeat produces evidence or HEARTBEAT_OK
- [ ] Anti-stall rules are documented
- [ ] DONE_CHECKLIST format is enforced

### Autonomy Cron
- [ ] Daily heartbeat job is scheduled
- [ ] Weekly self-improvement job is scheduled
- [ ] Hourly queue check is scheduled
- [ ] All jobs show as enabled in `openclaw cron list`

### Memory Self-Heal
- [ ] memory-self-heal skill is installed
- [ ] Trigger patterns are configured
- [ ] blocked-items.md exists
- [ ] Daily memory files are being created

### Evidence Link Auditor
- [ ] evidence-link-auditor skill is installed
- [ ] Pre-merge validation runs on task completion
- [ ] Unresolved markers are detected
- [ ] Link verification works on external URLs

## Rollback Plan

If setup causes issues, rollback in this order:

### Step 1: Revert Config Changes
```powershell
# Backup current config
Copy-Item ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# Restore from backup if exists
if (Test-Path ~/.openclaw/openclaw.json.backup) {
    Copy-Item ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
    openclaw gateway restart
}
```

### Step 2: Disable Cron Jobs
```powershell
# List all jobs
openclaw cron list --includeDisabled

# Disable problematic jobs
openclaw cron update --jobId <job-id> --patch '{"enabled": false}'
```

### Step 3: Reset Memory Files
```powershell
# Archive current memory
Move-Item memory/ memory.archive.$(Get-Date -Format "yyyyMMdd-HHmmss")

# Recreate minimal structure
New-Item -ItemType Directory -Force memory/
```

### Step 4: Remove Skills
```powershell
# List installed skills
openclaw skill list

# Remove growth pack if needed
openclaw skill remove openclaw-growth-pack
```

### Step 5: Full Factory Reset (Last Resort)
```powershell
# Stop gateway
openclaw gateway stop

# Backup workspace
Move-Item ~/.openclaw/workspace ~/.openclaw/workspace.backup.$(Get-Date -Format "yyyyMMdd-HHmmss")

# Reinstall OpenClaw
npm uninstall -g openclaw
npm install -g openclaw

# Reinitialize
openclaw init
```

## Daily/Weekly Improvement Loop

### Daily Loop (Every Heartbeat)

1. **Check Queue**: Read `tasks/QUEUE.md` for actionable items
2. **Execute One Step**: Complete one concrete action
3. **Log Evidence**: Write to `memory/YYYY-MM-DD.md`
4. **Check Blockers**: Review `memory/blocked-items.md` for unblockable items
5. **Self-Heal Check**: Look for repeated failure patterns

### Weekly Loop (Every Sunday)

1. **Review Memory**: Read last 7 days of `memory/*.md` files
2. **Identify Patterns**: Find repeated friction (2+ occurrences)
3. **Update Skills**: Create/update `skills/local/` skill for pattern
4. **Clean Queue**: Archive completed items, reprioritize remaining
5. **Metrics Review**: Count tasks completed, blockers resolved, failures recovered

### Monthly Loop (First of Month)

1. **Skill Audit**: Review all installed skills, remove unused
2. **Config Review**: Check `openclaw.json` for drift
3. **Token Rotation**: Generate new gateway token if >30 days old
4. **Performance Metrics**: Calculate success rate, avg task time, failure recovery rate
5. **Goal Setting**: Set improvement targets for next month

## Usage Examples

### Fresh Install Setup
```powershell
# Install and run full setup
openclaw skill install openclaw-growth-pack
openclaw skill run openclaw-growth-pack --mode setup

# Verify all components
openclaw skill run openclaw-growth-pack --mode verify
```

### Individual Component Setup
```powershell
# Setup model routing only
openclaw skill run openclaw-growth-pack --component model-routing

# Setup gateway tokens only
openclaw skill run openclaw-growth-pack --component gateway-tokens

# Setup autonomy cron only
openclaw skill run openclaw-growth-pack --component autonomy-cron
```

### Ongoing Maintenance
```powershell
# Run daily improvement check
openclaw skill run openclaw-growth-pack --mode daily-check

# Run weekly review
openclaw skill run openclaw-growth-pack --mode weekly-review

# Run monthly audit
openclaw skill run openclaw-growth-pack --mode monthly-audit
```

## Integration with Existing Skills

This skill integrates with:

| Skill | Integration Point |
|-------|-------------------|
| memory-self-heal | Pattern detection and auto-recovery |
| evidence-link-auditor | Pre-merge validation |
| task-execution-guard | Anti-stall enforcement |
| agent-autonomy-kit | Autonomous execution loops |
| agent-autonomy-primitives | Task-driven execution |

## Support and Updates

- **Documentation**: https://github.com/Dalomeve/bot-output/tree/main/skills/openclaw-growth-pack
- **Issues**: https://github.com/Dalomeve/bot-output/issues
- **Updates**: `openclaw skill update openclaw-growth-pack`
- **Community**: https://discord.com/invite/clawd

## License

MIT License - See LICENSE file in repository.

---

*Growth Pack v1.0.0 | Built for OpenClaw users who want production-ready setup from day one*
