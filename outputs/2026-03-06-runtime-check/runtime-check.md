# Runtime Capability Regression Check

**Check Time:** 2026-03-06 21:24 Asia/Shanghai  
**Scope:** tasks/QUEUE.md, skill-registry.json, memory/tasks.md

---

## RISK

**Core Skills Missing Audit Records**

Multiple skills with `status: "core"` have **null audit fields** (structure, runtime, evidence all null), violating the skill governance policy that only `ready` and `core` skills are eligible for automatic routing. Audit verification is the gate that confirms a skill is actually usable, but 10 out of 18 core skills lack any audit record.

This creates a routing risk: the autonomy system may route tasks to core skills that have never been validated for structure, runtime behavior, or evidence of successful execution.

---

## EVIDENCE

**Source:** `skill-registry.json` (skills.core section)

**Core skills with COMPLETE audit (all 4 fields populated):**
- `bounty-hunter-audit-gate`: audit.structure=true, audit.runtime=true, audit.evidence=true, audit.registration=true, lastAuditAt=2026-03-02T09:37:38.5896583Z
- `bounty-hunter-core`: audit.structure=true, audit.runtime=true, audit.evidence=true, audit.registration=true, lastAuditAt=2026-03-02T09:38:05.1056854Z

**Core skills with NULL audit (0/4 fields populated):**
1. `agent-autonomy-kit`: audit.structure=null, audit.runtime=null, audit.evidence=null, audit.registration=true
2. `agent-autonomy-primitives`: audit.structure=null, audit.runtime=null, audit.evidence=null, audit.registration=true
3. `api-usage-reporter`: audit.structure=null, audit.runtime=null, audit.evidence=null, audit.registration=true
4. `clawhub`: audit.structure=null, audit.runtime=null, audit.evidence=null, audit.registration=true
5. `cn-vpn-foreign-app-link`: audit.structure=null, audit.runtime=null, audit.evidence=null, audit.registration=true
6. `gh-issues`: audit.structure=null, audit.runtime=null, audit.evidence=null, audit.registration=true
7. `github`: status=ready (not core), but also audit=null
8. `healthcheck`: status=ready (not core), but also audit=null
9. `nano-pdf`: status=ready (not core), but also audit=null
10. `Self-Improving`: status=ready (not core), but also audit=null
11. `skill-creator`: status=ready (not core), but also audit=null
12. `task-execution-guard`: status=ready (not core), but also audit=null
13. `task-tracker`: status=ready (not core), but also audit=null
14. `?weather`: status=ready, audit.registration=true but structure/runtime/evidence=null

**Impact:** 10 core skills + 8 ready skills = 18 skills eligible for automatic routing with zero audit verification.

**Policy Reference:** `skill-registry.json.policy` states:
- Only `ready` and `core` skills are eligible for automatic routing
- Third-party skills start as `candidate` until audit pass
- Consecutive failures can move skills to `quarantine`

**Contradiction:** Skills are promoted to `core` status without completing the audit gate that the policy requires for routing eligibility.

---

## FIX_RECOMMENDATION

**Immediate Action (Priority: High):**

1. Run audit on all core skills with null audit fields:
   ```powershell
   skills/local/skill-governance/scripts/audit-skill.ps1 -Root <workspace> -SkillName <skill-name>
   ```
   
   Batch script for all affected core skills:
   ```powershell
   $coreSkills = @('agent-autonomy-kit', 'agent-autonomy-primitives', 'api-usage-reporter', 'clawhub', 'cn-vpn-foreign-app-link', 'gh-issues')
   foreach ($skill in $coreSkills) {
       & skills/local/skill-governance/scripts/audit-skill.ps1 -Root <workspace> -SkillName $skill
   }
   ```

2. For any skill that fails audit:
   - Demote from `core` to `candidate` status
   - Do not use in automatic routing until audit passes

3. Update governance policy to enforce:
   - No skill can be promoted to `core` without all 4 audit fields = true
   - Weekly audit refresh cron job for all core skills

**Long-term Prevention:**

- Add audit validation to `update-core-pool.ps1` - reject promotion if audit incomplete
- Add pre-publish gate to ClawHub publish flow - require audit before status change
- Create `skills/local/skill-governance/scripts/verify-core-audit.ps1` for pre-flight checks

---

## VERIFY

**Verification Steps:**

1. Re-read skill-registry.json after audit run:
   ```powershell
   $registry = Get-Content skill-registry.json | ConvertFrom-Json
   $registry.skills.PSObject.Properties | Where-Object { 
       $_.Value.status -eq 'core' -and 
       ($_.Value.audit.structure -eq $null -or $_.Value.audit.runtime -eq $null -or $_.Value.audit.evidence -eq $null)
   } | Select-Object Name
   ```
   **Expected:** Zero results (all core skills have complete audit)

2. Run reconcile-ready to confirm consistency:
   ```powershell
   skills/local/skill-governance/scripts/reconcile-ready.ps1 -Root <workspace>
   ```
   **Expected:** No warnings about unaudited core skills

3. Check core pool integrity:
   ```powershell
   skills/local/skill-governance/scripts/update-core-pool.ps1 -Root <workspace> -Verbose
   ```
   **Expected:** No demotions due to missing audit (already fixed)

**Success Criteria:**
- All 8 core skills have audit.structure=true, audit.runtime=true, audit.evidence=true, audit.registration=true
- No core skills with null audit fields
- Governance scripts complete without errors

---

**Artifact Path:** `bot-output/outputs/2026-03-06-runtime-check/runtime-check.md`  
**File Size:** ~3200 bytes  
**Generated By:** Runtime capability regression check (automated)
