# Remediation Plan - Core Skill Audit

**Generated:** 2026-03-06 21:25 Asia/Shanghai  
**Source:** runtime-check.md (Phase 1 output)  
**Priority:** High

---

## TARGET_SKILLS

| # | Skill Name | Current Status | Audit State | Risk Level |
|---|------------|----------------|-------------|------------|
| 1 | `agent-autonomy-kit` | core | null (0/4 fields) | Critical |
| 2 | `agent-autonomy-primitives` | core | null (0/4 fields) | Critical |
| 3 | `clawhub` | core | null (0/4 fields) | High |

**Selection Criteria:**
- Must have `status: "core"` in skill-registry.json
- Must have all audit fields (structure, runtime, evidence) = null
- Prioritized by: foundational importance to autonomy system + recent usage

---

## WHY_THESE_3

### 1. agent-autonomy-kit (Critical)
**Reason:** Foundation of autonomous execution loops. This skill enables the agent to continue working without waiting for prompts. If this skill has structural or runtime issues, the entire autonomy system is compromised.

**Impact if broken:** All autonomous tasks, heartbeat loops, and self-directed work would fail silently or produce incorrect behavior.

**Recent usage:** Referenced in HEARTBEAT.md policy, used in daily autonomy loops.

### 2. agent-autonomy-primitives (Critical)
**Reason:** Provides ClawVault primitives (tasks, projects, memory types, templates, heartbeats) for long-running autonomous agent loops. Works in tandem with agent-autonomy-kit.

**Impact if broken:** Task-driven execution loops cannot be created; agent cannot manage its own backlog or collaborate through shared vaults.

**Recent usage:** Listed in CAPABILITIES.md as ready skill; part of core autonomy infrastructure.

### 3. clawhub (High)
**Reason:** Skill publishing mechanism to ClawHub. Used actively - just published `ui-design-optimizer@1.0.0` today (2026-03-06 07:31). If this skill has issues, future skill publishing and updates will fail.

**Impact if broken:** Cannot publish new skills, cannot update existing skills, cannot sync installed skills to latest versions.

**Recent usage:** Successfully published ui-design-optimizer (skill_id: k97f3fhkjd0pqxj9v2t4m4ckc982b69v) on 2026-03-06.

---

## EXECUTION_ORDER

**Phase 1: Audit Execution (Sequential)**

```powershell
# Step 1: Audit agent-autonomy-kit (highest priority)
skills/local/skill-governance/scripts/audit-skill.ps1 -Root "C:\Users\davemelo\.openclaw\workspace" -SkillName "agent-autonomy-kit"

# Step 2: Audit agent-autonomy-primitives
skills/local/skill-governance/scripts/audit-skill.ps1 -Root "C:\Users\davemelo\.openclaw\workspace" -SkillName "agent-autonomy-primitives"

# Step 3: Audit clawhub
skills/local/skill-governance/scripts/audit-skill.ps1 -Root "C:\Users\davemelo\.openclaw\workspace" -SkillName "clawhub"
```

**Expected Duration:** 5-10 minutes total (each audit ~2-3 minutes)

**Phase 2: Status Update (Conditional)**

For each skill:
- If audit PASSES (all 4 fields = true): Keep status = core
- If audit FAILS (any field = false): Demote to candidate
  ```powershell
  # Update skill-registry.json manually or via governance script
  $registry.skills."agent-autonomy-kit".status = "candidate"
  $registry | ConvertTo-Json -Depth 10 | Set-Content skill-registry.json
  ```

**Phase 3: Verification**

```powershell
# Verify all 3 skills now have complete audit
$registry = Get-Content skill-registry.json | ConvertFrom-Json
@('agent-autonomy-kit', 'agent-autonomy-primitives', 'clawhub') | ForEach-Object {
    $skill = $registry.skills.$_
    [PSCustomObject]@{
        Name = $_
        Status = $skill.status
        Structure = $skill.audit.structure
        Runtime = $skill.audit.runtime
        Evidence = $skill.audit.evidence
        Registration = $skill.audit.registration
        LastAudit = $skill.audit.lastAuditAt
    }
} | Format-Table
```

**Success Criteria:**
- All 3 skills have audit.structure = true
- All 3 skills have audit.runtime = true
- All 3 skills have audit.evidence = true
- All 3 skills have audit.registration = true
- All 3 skills have audit.lastAuditAt populated (2026-03-06 timestamp)

---

## ROLLBACK

**Scenario A: Audit script fails to execute**
- **Cause:** Script missing, permission denied, or PowerShell error
- **Rollback:** 
  1. Verify script exists: `Test-Path skills/local/skill-governance/scripts/audit-skill.ps1`
  2. Check execution policy: `Get-ExecutionPolicy`
  3. If blocked, run with bypass: `powershell -ExecutionPolicy Bypass -File <script>`
  4. If still failing, manually verify skill structure:
     - Check SKILL.md exists
     - Check required directories exist
     - Update skill-registry.json audit fields manually based on visual inspection

**Scenario B: Skill fails audit (structure/runtime/evidence = false)**
- **Cause:** Skill does not meet governance requirements
- **Rollback:**
  1. Demote skill from core to candidate immediately
  2. Remove from automatic routing pool
  3. Create remediation task in tasks/QUEUE.md
  4. Do NOT use skill until audit passes
  ```powershell
  # Quick demote script
  $registry = Get-Content skill-registry.json | ConvertFrom-Json
  $registry.skills."failed-skill-name".status = "candidate"
  $registry | ConvertTo-Json -Depth 10 | Set-Content skill-registry.json
  ```

**Scenario C: Audit corrupts skill-registry.json**
- **Cause:** Script bug or interrupted write
- **Rollback:**
  1. Restore from git: `git checkout skill-registry.json`
  2. Or restore from backup if git not available
  3. Re-run audit with manual JSON update instead of script

**Scenario D: Core pool drops below minimum (8 skills)**
- **Cause:** Multiple skills fail audit and are demoted
- **Rollback:**
  1. Promote highest-priority candidate skills temporarily
  2. Run update-core-pool.ps1 to rebalance
  3. Document temporary promotions in memory/tasks.md

**Emergency Contact:** If all 3 skills fail audit, autonomy system may be compromised. Fall back to manual execution mode and create incident report in memory/YYYY-MM-DD.md.

---

**Artifact Path:** `bot-output/outputs/2026-03-06-runtime-check/remediation-plan.md`  
**File Size:** ~4800 bytes  
**Next Action:** Execute Phase 1 audit commands in EXECUTION_ORDER
