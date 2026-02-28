---
name: memory-self-heal
version: 1.0.0
description: Auto-diagnose and recover from repeated friction patterns using memory-driven self-improvement.
metadata:
  openclaw:
    emoji: "[LOOP]"
    category: resilience
---

# Memory Self-Heal Skill

Automatically detect, diagnose, and recover from repeated friction patterns by consulting memory before failure escalates.

## Trigger Conditions

Activate this skill when ANY of these patterns are detected:

1. **Shell Command Failure** - exec/process tool returns error with syntax mismatch
2. **Missing Evidence Completion** - Task claims done without DONE_CHECKLIST/EVIDENCE block
3. **API Key Blocker** - Tool fails with "missing API key" or "unconfigured" error
4. **Login Wall Detected** - Browser snapshot shows authentication/login required
5. **Browser Profile Conflict** - Multiple browser sessions causing target confusion
6. **Context Window Exhausted** - Agent fails with "context window too small" error

## Diagnosis Steps

When triggered, execute in order:

### Step 1: Pattern Match
Search memory for similar failures in last 7 days:
```powershell
# Search memory files for error keywords
Get-ChildItem memory/*.md | Select-String -Pattern "PowerShell|argument|split|API key|login|browser|context" -Context 2
```

### Step 2: Check Prior Fixes
For each matched pattern, extract the resolution:
- Read `memory/tasks.md` for completed tasks with same failure signature
- Read `memory/blocked-items.md` for documented blockers and unblock inputs
- Read `memory/YYYY-MM-DD.md` for lessons learned

### Step 3: Classify Failure Type
Map to known pattern:
| Pattern | Signature | Prior Fix |
|---------|-----------|-----------|
| PowerShell args | `ls -la`, `curl -s` fails | Use `Get-ChildItem`, `Invoke-WebRequest -Uri` |
| False completion | No DONE_CHECKLIST in response | Require evidence block before marking done |
| API key missing | `BRAVE_API_KEY`, `unconfigured` | Prompt user: `openclaw configure --section web` |
| Login wall | Browser shows login form | Switch to `openclaw` profile or request manual attach |
| Browser conflict | Multiple targetId/profile | Use explicit `profile="openclaw"` or `profile="chrome"` |
| Context exhausted | "context window too small" | Reduce payload, split task, or increase model context |

## Search Steps

Before asking user, search these locations:

1. **Memory files**: `memory/*.md` for prior failures and fixes
2. **Task queue**: `tasks/QUEUE.md` for blocked items with unblock instructions
3. **Capabilities**: `CAPABILITIES.md` for tool limitations
4. **Tools config**: `TOOLS.md` for approved model routes and keys
5. **Existing skills**: `skills/*/SKILL.md` for fallback procedures

PowerShell search template:
```powershell
# Search all memory for pattern
$pattern = "API key|PowerShell|login|browser"
Get-ChildItem memory/*.md | Select-String -Pattern $pattern -Context 3 | 
  Select-Object Path, LineNumber, Line, Context
```

## Retry + Fallback Policy

### Primary Retry (Attempt 1)
- Correct the identified issue based on memory pattern
- Re-execute with fixed parameters
- Wait for result

### Fallback Path (Attempt 2)
If primary retry fails:
1. **Shell failures**: Switch to native PowerShell cmdlets
2. **API key missing**: Document blocker in `memory/blocked-items.md`, prompt user with exact command
3. **Login wall**: Switch browser profile or use `web_fetch` as fallback
4. **Browser conflict**: Explicitly specify `target` and `profile` in browser calls
5. **Context exhausted**: Split task into sub-agents or reduce scope

### Final Fallback (Attempt 3)
If both fail:
1. Write detailed blocker to `memory/blocked-items.md` with:
   - Exact error message
   - Attempts made (primary + fallback)
   - Minimum unblock input required
2. Update `tasks/QUEUE.md` to mark item as Blocked
3. Report to user with smallest unblock input

## Verification Checklist

Before marking recovery complete:

- [ ] Executed at least one concrete retry action
- [ ] Verified artifact exists (file readable, URL accessible, command succeeded)
- [ ] No unresolved markers (PENDING, TODO, TBD) in output
- [ ] Updated `memory/YYYY-MM-DD.md` with lesson learned
- [ ] If blocker persists, documented in `memory/blocked-items.md` with unblock input

## Logging Template

Append to `memory/YYYY-MM-DD.md` after each self-heal cycle:

```markdown
## YYYY-MM-DD: Self-heal recovery - [Pattern Name]
- Task: [Brief description]
- Pattern: [PowerShell args | API key | Login wall | Browser conflict | Context exhausted | False completion]
- Diagnosis: [What memory search found]
- Primary Fix: [What was tried first]
- Fallback: [What was tried second, if applicable]
- Outcome: [Success | Blocked - requires X]
- Evidence: [Artifact path, command output, or blocker doc link]
- Lesson: [One-line rule for future]
```

## Concrete Patterns from Memory (2026-02-28 to 2026-03-01)

### Pattern 1: PowerShell Argument Splitting
**Signature**: `ls -la`, `curl -s`, `grep` flags fail on Windows
**Memory Evidence**: `memory/2026-02-28-crypto-trends-browser-automati.md` shows bash commands failing
**Fix**: Use `Get-ChildItem`, `Invoke-WebRequest -Uri`, `Select-String`
**Verification**: Command returns output without error

### Pattern 2: False Completion Without Evidence
**Signature**: Task claims "complete" without DONE_CHECKLIST/EVIDENCE block
**Memory Evidence**: `memory/tasks.md` shows proper format; violations cause rework
**Fix**: Require evidence block before marking any multi-step task done
**Verification**: Response contains DONE_CHECKLIST with EVIDENCE section

### Pattern 3: Missing API Key Blockers
**Signature**: `web_search` fails with BRAVE_API_KEY missing
**Memory Evidence**: `memory/blocked-items.md` documents Solana meme coin search blocked
**Fix**: Prompt user with exact command: `openclaw configure --section web`
**Verification**: API key configured, web_search succeeds

### Pattern 4: Login Wall / Browser Auth
**Signature**: Browser shows login form or requires extension attachment
**Memory Evidence**: `memory/2026-02-28-browser-control.md` shows Chrome extension attachment requirement
**Fix**: Use `profile="openclaw"` for isolated browser, or request manual attach for `profile="chrome"`
**Verification**: Browser snapshot shows target content, not login page

### Pattern 5: Browser Profile Conflict
**Signature**: Multiple browser sessions (openclaw + chrome) causing target confusion
**Memory Evidence**: `memory/2026-02-28-browser-control.md` shows conflicts between profiles
**Fix**: Explicitly specify `profile` and `target` in every browser call
**Verification**: Browser action succeeds on intended profile

### Pattern 6: Context Window Exhausted
**Signature**: Agent fails with "context window too small (N tokens). Minimum is 16000"
**Memory Evidence**: `memory/2026-02-28-crypto-trends-browser-automati.md` shows failure at 1 token
**Fix**: Reduce payload size, split into sub-agents, or use model with larger context
**Verification**: Agent completes without context error

## Integration with Heartbeat

On each heartbeat:
1. Check `memory/blocked-items.md` for items that can now be unblocked
2. If unblock condition met (e.g., user configured API key), retry blocked task
3. Log outcome to `memory/YYYY-MM-DD.md`

## Safety Boundaries

- Do not auto-retry destructive operations (deletions, external posts)
- Do not auto-retry more than 3 times without user input
- Do not store secrets or credentials in memory files
- Always document blockers with minimum unblock input
