# OpenClaw Growth Pack - Examples

Practical examples for each component of the Growth Pack onboarding skill.

## Example 1: Model Routing Setup

### Before (Broken Configuration)
```json
{
  "models": {
    "providers": {
      "bailian": {
        "baseUrl": "https://api.wrong-url.com/v1"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "qwen-wrong-model"
      }
    }
  }
}
```

**Symptoms:**
- `openclaw sessions spawn` fails with 404
- Error: "Model not found: qwen-wrong-model"

### After (Fixed Configuration)
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

**Verification:**
```powershell
# Test primary model
openclaw sessions spawn --task "Hello, test connection" --model bailian/qwen3-coder-plus
# ✅ Session spawned successfully

# Test fallback model
openclaw sessions spawn --task "Fallback test" --model bailian/qwen3.5-plus
# ✅ Session spawned successfully
```

---

## Example 2: Gateway Token Consistency

### Before (Inconsistent Tokens)
```
Config token: abc123xyz
Remote token: def456uvw
Env token:   abc123xyz
```

**Symptoms:**
- CLI works but UI shows "Authentication failed"
- Gateway logs show token mismatch errors
- Remote operations fail intermittently

### After (Consistent Tokens)
```powershell
# Generate new token
$newToken = "sk_" + -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})

# Apply to all locations
$config = Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json
$config.gateway.auth.token = $newToken
$config.gateway.remote.token = $newToken
$config | ConvertTo-Json -Depth 10 | Set-Content ~/.openclaw/openclaw.json

[Environment]::SetEnvironmentVariable("OPENCLAW_GATEWAY_TOKEN", $newToken, "User")

openclaw gateway restart
```

**Verification:**
```powershell
# Check consistency
$configToken = (Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json).gateway.auth.token
$remoteToken = (Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json).gateway.remote.token
$envToken = [Environment]::GetEnvironmentVariable("OPENCLAW_GATEWAY_TOKEN", "User")

Write-Host "Config: $configToken"
Write-Host "Remote: $remoteToken"
Write-Host "Env: $envToken"

# All three should match ✅
```

---

## Example 3: HEARTBEAT Hardening

### Before (Weak Heartbeat)
```markdown
# HEARTBEAT.md

Check for tasks occasionally.
```

**Symptoms:**
- Agent stalls on complex tasks
- No evidence of progress
- Planning-only replies without execution

### After (Hardened Heartbeat)
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

**Verification:**
```powershell
# Trigger heartbeat
openclaw sessions send --label main --message "HEARTBEAT: Check for unfinished tasks"

# Check memory for evidence
Get-Content memory/2026-03-01.md | Select-String "action executed|artifact|verification"
# ✅ Should show evidence entries
```

---

## Example 4: Autonomy Cron Setup

### Before (No Automation)
- User must manually prompt for every task
- No scheduled self-improvement
- Blocked items stay blocked indefinitely

### After (Automated Cron Jobs)
```powershell
# Daily heartbeat check at 9 AM
openclaw cron add --job '{
  "name": "daily-heartbeat-check",
  "schedule": { "kind": "cron", "expr": "0 9 * * *", "tz": "Asia/Shanghai" },
  "payload": { "kind": "systemEvent", "text": "HEARTBEAT: Check for unfinished tasks and blocked items" },
  "sessionTarget": "main",
  "enabled": true
}'

# Weekly self-improvement on Sundays at 10 AM
openclaw cron add --job '{
  "name": "weekly-self-improvement",
  "schedule": { "kind": "cron", "expr": "0 10 * * 0", "tz": "Asia/Shanghai" },
  "payload": { "kind": "systemEvent", "text": "SELF-IMPROVE: Review last 7 days of memory, identify friction patterns, update skills/local/" },
  "sessionTarget": "main",
  "enabled": true
}'

# Hourly queue check
openclaw cron add --job '{
  "name": "hourly-queue-check",
  "schedule": { "kind": "every", "everyMs": 3600000 },
  "payload": { "kind": "systemEvent", "text": "QUEUE: Check tasks/QUEUE.md for actionable items" },
  "sessionTarget": "main",
  "enabled": true
}'
```

**Verification:**
```powershell
# List all cron jobs
openclaw cron list

# Output should show:
# ✅ daily-heartbeat-check (enabled)
# ✅ weekly-self-improvement (enabled)
# ✅ hourly-queue-check (enabled)

# Check run history
openclaw cron runs --jobId daily-heartbeat-check
# ✅ Should show recent successful runs
```

---

## Example 5: Memory Self-Heal Integration

### Before (No Self-Healing)
```
Task fails with PowerShell syntax error
→ Agent retries same failing command
→ Task remains blocked
→ User must manually intervene
```

### After (Self-Healing Active)
```
Task fails with PowerShell syntax error
→ memory-self-heal skill activates
→ Searches memory for similar failures
→ Finds pattern: "ls -la fails on Windows"
→ Auto-retries with: Get-ChildItem
→ Task completes successfully
→ Lesson logged to memory/2026-03-01.md
```

**Example Memory Entry:**
```markdown
## 2026-03-01: Self-heal recovery - PowerShell Args
- Task: List workspace files
- Pattern: PowerShell args (ls -la fails)
- Diagnosis: memory/2026-02-28.md shows same failure
- Primary Fix: Retry with Get-ChildItem
- Outcome: Success
- Evidence: Get-ChildItem returned 42 files
- Lesson: Always use native PowerShell cmdlets on Windows
```

**Verification:**
```powershell
# Check for self-heal entries
Get-Content memory/2026-03-01.md | Select-String "Self-heal" -Context 3
# ✅ Should show recovery entries

# Check blocked items resolved
Get-Content memory/blocked-items.md | Select-String "Resolved"
# ✅ Should show resolved blockers
```

---

## Example 6: Evidence Link Auditor

### Before (No Validation)
```markdown
## Task Complete

See the report: [report.md](./outputs/report.md)
Commit: [abc123](https://github.com/user/repo/commit/abc123)

TODO: Add more tests
PENDING: Deploy to production
```

**Issues:**
- Link to report.md doesn't exist (404)
- Commit hash abc123 doesn't exist
- Unresolved markers in "complete" task

### After (With Auditor)
```powershell
# Run audit before marking complete
openclaw skill run evidence-link-auditor --target ./outputs/latest

# Audit Report:
# ✅ All external links valid (HTTP 200)
# ✅ All internal links resolve
# ✅ No unresolved markers found
# ✅ Commit hashes verified
```

**Fixed Output:**
```markdown
## Task Complete

See the report: [report.md](./outputs/report.md) ✅
Commit: [abc123def](https://github.com/user/repo/commit/abc123def) ✅

DONE_CHECKLIST:
- [x] Feature implemented
- [x] Tests added
- [x] Documentation updated

EVIDENCE:
- Artifact: ./outputs/report.md (verified exists)
- Commit: abc123def (verified in repo)
- Tests: 15 passed, 0 failed
```

---

## Example 7: Full Setup Workflow

### Fresh Install Scenario

```powershell
# Step 1: Install Growth Pack
openclaw skill install openclaw-growth-pack
# ✅ Skill installed to ~/.openclaw/workspace/skills/openclaw-growth-pack

# Step 2: Run setup wizard
openclaw skill run openclaw-growth-pack --mode setup
# 🔄 Configuring model routing...
# ✅ Model routing configured
# 🔄 Checking gateway tokens...
# ✅ Tokens consistent
# 🔄 Setting up cron jobs...
# ✅ 3 cron jobs created
# 🔄 Integrating memory-self-heal...
# ✅ Self-heal active
# 🔄 Integrating evidence-link-auditor...
# ✅ Auditor active

# Step 3: Verify installation
openclaw skill run openclaw-growth-pack --mode verify
# ✅ Model routing: PASS
# ✅ Gateway tokens: PASS
# ✅ Heartbeat: PASS
# ✅ Cron jobs: PASS
# ✅ Self-heal: PASS
# ✅ Evidence auditor: PASS

# Step 4: Test with sample task
openclaw sessions spawn --task "List files in workspace"
# ✅ Session completes with evidence
```

---

## Example 8: Rollback Scenario

### Problem: Cron Jobs Causing Conflicts

```powershell
# Step 1: Identify problematic job
openclaw cron list
# Shows: hourly-queue-check running too frequently

# Step 2: Disable problematic job
openclaw cron update --jobId hourly-queue-check --patch '{"enabled": false}'
# ✅ Job disabled

# Step 3: If issue persists, restore config backup
Copy-Item ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
openclaw gateway restart
# ✅ Gateway restarted with backup config

# Step 4: Verify system stable
openclaw gateway status
# ✅ Gateway running normally
```

---

## Example 9: Daily Improvement Loop

### Morning Heartbeat (9 AM)
```powershell
# Cron triggers daily-heartbeat-check
# Agent executes:

# 1. Check queue
Get-Content tasks/QUEUE.md
# Finds: "Update documentation" (priority: high)

# 2. Execute one step
openclaw sessions spawn --task "Update README with new features"
# ✅ Session completes

# 3. Log evidence
Add-Content memory/2026-03-01.md @"
## 2026-03-01 09:00: Daily Heartbeat
- Action: Updated README
- Artifact: ./README.md (commit: def456)
- Verification: Get-Content README.md | Select-String "new features" ✅
"@
```

### Evening Review (Manual)
```powershell
# Review day's progress
Get-Content memory/2026-03-01.md
# Shows: 3 tasks completed, 1 blocker resolved

# Check for patterns
Get-ChildItem memory/*.md | Select-String "PowerShell" -Context 2
# Finds: 2 PowerShell syntax failures this week
# → Create skills/local/powershell-fix.md
```

---

## Example 10: Weekly Improvement Loop

### Sunday Review (10 AM)
```powershell
# Cron triggers weekly-self-improvement
# Agent executes:

# 1. Review last 7 days memory
$lastWeek = Get-ChildItem memory/*.md | Where-Object {
    $_.LastWriteTime -gt (Get-Date).AddDays(-7)
}
$patterns = $lastWeek | Select-String "failure|error|blocked" -Context 3

# 2. Identify repeated patterns
# Finds: PowerShell syntax errors (3 occurrences)
# Finds: API key missing (2 occurrences)

# 3. Create/update local skill
New-Item skills/local/powershell-syntax-fix.md -Value @"
# PowerShell Syntax Fix

Trigger: exec fails with bash flags (ls -la, curl -s)
Fix: Retry with native cmdlets (Get-ChildItem, Invoke-WebRequest -Uri)
Verification: Command returns output without error
"@

# 4. Log weekly summary
Add-Content memory/weekly-summary-2026-W09.md @"
## Week 9 Summary
- Tasks completed: 15
- Blockers resolved: 3
- Patterns identified: 2
- Skills created: 1 (powershell-syntax-fix)
- Success rate: 93%
"@
```

---

## Example 11: Troubleshooting Common Issues

### Issue: Model Calls Failing
```powershell
# Check configuration
openclaw config get | Select-Object -ExpandProperty models

# If baseUrl is wrong, fix it
$config = Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json
$config.models.providers.bailian.baseUrl = "https://coding.dashscope.aliyuncs.com/v1"
$config | ConvertTo-Json -Depth 10 | Set-Content ~/.openclaw/openclaw.json
openclaw gateway restart

# Verify fix
openclaw sessions spawn --task "Test" --model bailian/qwen3-coder-plus
# ✅ Should succeed
```

### Issue: Gateway Auth Errors
```powershell
# Check token consistency
$configToken = (Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json).gateway.auth.token
$remoteToken = (Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json).gateway.remote.token
$envToken = [Environment]::GetEnvironmentVariable("OPENCLAW_GATEWAY_TOKEN", "User")

# If mismatch, regenerate
$newToken = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$config.gateway.auth.token = $newToken
$config.gateway.remote.token = $newToken
$config | ConvertTo-Json -Depth 10 | Set-Content ~/.openclaw/openclaw.json
[Environment]::SetEnvironmentVariable("OPENCLAW_GATEWAY_TOKEN", $newToken, "User")
openclaw gateway restart
```

### Issue: Heartbeat Not Producing Evidence
```powershell
# Check HEARTBEAT.md content
Get-Content HEARTBEAT.md

# If missing evidence requirements, update it
@'
# HEARTBEAT.md

## Heartbeat Policy

Keep each heartbeat cheap and useful. Do at most 1-2 checks per cycle.
Heartbeat must produce either execution evidence or `HEARTBEAT_OK`.

## Evidence Requirement

When heartbeat executes work, append a compact proof to `memory/YYYY-MM-DD.md`:

- action executed
- artifact path/url/id
- verification command summary
'@ | Set-Content HEARTBEAT.md

# Test heartbeat
openclaw sessions send --label main --message "HEARTBEAT: Check tasks"
Get-Content memory/$(Get-Date -Format "yyyy-MM-dd").md
# ✅ Should show evidence entries
```

---

*Examples v1.0.0 | OpenClaw Growth Pack*
