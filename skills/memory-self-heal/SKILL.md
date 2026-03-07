---
name: memory-self-heal
version: 1.1.0
description: General-purpose self-healing loop that learns from past failures, retries safely, and records reusable fixes.
metadata:
  openclaw:
    emoji: "[HEAL]"
    category: resilience
---

# Memory Self-Heal Skill

Use this skill when the agent starts failing repeatedly, stalls, or keeps asking the user for steps that could be inferred from prior evidence.

## Goals

1. Recover execution without user micromanagement
2. Reuse previous fixes from memory/logs/tasks
3. Escalate only with minimal unblock input when truly blocked
4. Leave reusable evidence for future runs

## When To Trigger

Trigger when any of these appear:
- Same or similar error occurs 2+ times in one task
- Tool call fails due to argument mismatch, missing config, auth wall, or context overflow
- Agent claims completion without verifiable artifact
- Task progress stalls (no new artifact across 2 cycles)

## Inputs

- Current task objective
- Latest error/output
- Available evidence locations (memory, tasks, logs)

## Portable Evidence Scan Order

Scan these in order; skip missing paths silently:
1. `memory/` (or equivalent workspace memory path)
2. `tasks/` or queue files
3. runtime logs / channel logs
4. skill docs (`skills/*/SKILL.md`) for known fallback recipes
5. core docs (`TOOLS.md`, `CAPABILITIES.md`, `AGENTS.md`)

Shell examples (use whichever shell is active):

```powershell
# PowerShell
Get-ChildItem -Recurse memory, tasks -ErrorAction SilentlyContinue |
  Select-String -Pattern "error|blocked|retry|fallback|auth|token|proxy|timeout|context" -Context 2
```

```bash
# POSIX shell
rg -n "error|blocked|retry|fallback|auth|token|proxy|timeout|context" memory tasks 2>/dev/null
```

## Failure Classification

Classify first, then act:
- `syntax_or_args`: command syntax/argument mismatch
- `auth_or_config`: key/token/env/config missing or invalid
- `network_or_reachability`: timeout, DNS, handshake, region restrictions
- `ui_login_wall`: page requires manual login/attach
- `resource_limit`: context window, rate limit, memory pressure
- `false_done`: no artifact/evidence but reported complete
- `unknown`: no confident class

## Recovery Policy (3-Tier)

### Attempt 1: Direct Fix
- Apply best-known fix from memory for same class/signature
- Re-run the smallest validating action
- Record result

### Attempt 2: Safe Fallback
- Switch to alternate tool/path with lower fragility
- Narrow scope (smaller input, shorter query, one target)
- Re-run validation

### Attempt 3: Controlled Escalation
- Mark blocked with minimum unblock input
- Provide exact next action user must do (one command or one UI step)
- Do not loop further until new input arrives

## Safety Rules

- Never auto-run destructive operations without confirmation
- Never log secrets/tokens in memory files
- Max 3 retries per blocker signature per task
- Prefer deterministic steps over broad speculative retries

## Completion Contract

Do not claim done unless all are true:
- At least one artifact exists and is readable (file/link/output)
- The original task objective is explicitly mapped to artifact(s)
- No unresolved blocker for current objective

Required output block:

```markdown
DONE_CHECKLIST
- Objective met: yes/no
- Artifact: <path or URL or command output ref>
- Validation: <what was checked>
- Remaining blocker: <none or exact unblock input>
```

## Memory Writeback Template

Append one concise entry after each self-heal cycle:

```markdown
## Self-heal: <date-time> <short task>
- Signature: <normalized error signature>
- Class: <classification>
- Attempt1: <action> -> <result>
- Attempt2: <action> -> <result>
- Final: <success | blocked>
- Artifact/Evidence: <path|url|log ref>
- Reusable rule: <one-line rule>
```

## Generic Known Fixes (Seed Set)

- Command mismatch on Windows: prefer native PowerShell cmdlets
- Token mismatch/auth failure: verify active config source and token scope
- WebSocket/timeouts: test reachability + proxy/no_proxy consistency
- Context overflow: split task into smaller units and reduce payload
- False completion: enforce artifact validation before final response
- Crypto market data sources (GMGN, DexScreener): check (1) Brave API key for web_search, (2) browser tool with Chrome profile for JS-heavy/Cloudflare-protected sites, (3) fallback to manual user verification with specific URLs
- **Browser fallback for Cloudflare blocks**: When web_fetch returns 403 Cloudflare error, use `browser` tool with `profile: openclaw` to load JS-heavy sites; snapshot with `refs: aria` to extract structured data
- **Evidence audit scope rule**: When running marker audits (TODO/TBD/PENDING), scope to current session outputs only (`outputs/YYYY-MM-DD-*`); exclude documentation files (INDEX.md, README.md) and historical session notes older than 7 days to avoid false positives from documentation examples and immutable historical records
- **BOSS job page iframe blocker (early-detection)**: On first navigation failure to /web/geek/jobs or /web/geek/recommend, immediately check for iframe refs in snapshot; if 2+ iframe refs detected with no accessible job content, OR URL remains /web/geek/chat (SPA redirect), OR evaluate on contentDocument throws cross-origin error, skip further navigation attempts and switch to chat-only monitoring mode (/web/geek/chat); job review is not actionable when iframe-blocked; continue monitoring existing conversations for recruiter responses and resume using uploaded resume when boss confirmation received

## Integration Notes直聘 job recommendations page (/web/geek/jobs or /web/geek/recommend) shows cross-origin iframe content that cannot be accessed via aria snapshot or evaluate, accept the limitation and continue with message queue monitoring via chat page (/web/geek/chat); job review is not actionable when iframe-blocked; resume using existing uploaded resume when boss confirmation received

## Integration Notes

- Works with autonomy/task-tracker skills but does not depend on them
- If a project has custom memory paths, adapt scan roots dynamically
- Keep entries short to avoid memory bloat
