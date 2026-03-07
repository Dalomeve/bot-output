# Correction Note - Phase 3 Self-Check

**Generated:** 2026-03-06 21:56 Asia/Shanghai  
**Scope:** runtime-check.md vs remediation-plan.md consistency audit

---

## INCONSISTENCY

**Found in:** `runtime-check.md` - RISK and EVIDENCE sections

**Issue 1: Core skill count mismatch**
- RISK section claims: "10 out of 18 core skills lack any audit record"
- EVIDENCE section lists: Only 6 core skills with NULL audit (items 1-6)
- EVIDENCE section then lists: 8 ready skills with NULL audit (items 7-14)
- Impact line states: "10 core skills + 8 ready skills = 18 skills eligible for automatic routing"

**Actual counts from EVIDENCE list:**
- Core skills with COMPLETE audit: 2 (bounty-hunter-audit-gate, bounty-hunter-core)
- Core skills with NULL audit: 6 (agent-autonomy-kit, agent-autonomy-primitives, api-usage-reporter, clawhub, cn-vpn-foreign-app-link, gh-issues)
- Ready skills with NULL audit: 8 (github, healthcheck, nano-pdf, Self-Improving, skill-creator, task-execution-guard, task-tracker, ?weather)

**Corrected totals:**
- Total core skills: 2 + 6 = 8 (not 18)
- Core skills missing audit: 6 (not 10)
- Total unaudited skills eligible for routing: 6 core + 8 ready = 14 (not 18)

**Issue 2: Internal contradiction in RISK section**
- Statement: "10 out of 18 core skills lack any audit record"
- This implies 18 total core skills, but EVIDENCE shows only 8 core skills total

---

## ROOT_CAUSE

**Counting error during report generation:**

1. The author miscounted the numbered list in EVIDENCE section (14 items total) as "10 core + 8 ready = 18"
2. Items 1-6 are explicitly marked as core status
3. Items 7-14 are explicitly marked as ready status (not core)
4. The phrase "10 out of 18 core skills" appears to conflate "core skills" with "total skills eligible for routing"

**Likely cause:** Mental arithmetic error when summarizing:
- Should have been: "6 out of 8 core skills lack audit records" + "8 ready skills also lack audit" = "14 total skills eligible for routing without audit"
- Instead wrote: "10 out of 18 core skills" (incorrect on both counts)

---

## CORRECTED_COUNTS

| Metric | Original (Wrong) | Corrected |
|--------|------------------|-----------|
| Total core skills | 18 | 8 |
| Core skills missing audit | 10 | 6 |
| Core skills with complete audit | (not stated) | 2 |
| Ready skills missing audit | 8 | 8 |
| Total unaudited skills eligible for routing | 18 | 14 |

**Corrected risk statement:**
> "Multiple skills with `status: "core"` have **null audit fields** (structure, runtime, evidence all null), violating the skill governance policy that only `ready` and `core` skills are eligible for automatic routing. Audit verification is the gate that confirms a skill is actually usable, but **6 out of 8 core skills** lack any audit record."

**Corrected impact statement:**
> "**Impact:** 6 core skills + 8 ready skills = 14 skills eligible for automatic routing with zero audit verification."

---

## PATCH_PLAN

**Files to update:**

1. **runtime-check.md** - Update RISK section:
   ```
   Old: "10 out of 18 core skills lack any audit record"
   New: "6 out of 8 core skills lack any audit record"
   ```

2. **runtime-check.md** - Update EVIDENCE section impact line:
   ```
   Old: "Impact: 10 core skills + 8 ready skills = 18 skills eligible for automatic routing with zero audit verification."
   New: "Impact: 6 core skills + 8 ready skills = 14 skills eligible for automatic routing with zero audit verification."
   ```

3. **runtime-check.md** - Optional: Add clarification note:
   ```
   **Note:** Total core skills in registry: 8 (2 audited, 6 unaudited)
   ```

**remediation-plan.md status:** 
- No corrections needed
- Correctly identifies 3 target skills from the 6 unaudited core skills
- All counts and status classifications are accurate

**Verification after patch:**
```powershell
# Verify corrected counts match skill-registry.json
$registry = Get-Content skill-registry.json | ConvertFrom-Json
$coreSkills = $registry.skills.PSObject.Properties | Where-Object { $_.Value.status -eq 'core' }
$unauditedCore = $coreSkills | Where-Object { $_.Value.audit.structure -eq $null -or $_.Value.audit.runtime -eq $null -or $_.Value.audit.evidence -eq $null }
Write-Host "Total core skills: $($coreSkills.Count)"
Write-Host "Unaudited core skills: $($unauditedCore.Count)"
```

**Expected output:**
```
Total core skills: 8
Unaudited core skills: 6 (or fewer if audits completed since report)
```

---

**Artifact Path:** `bot-output/outputs/2026-03-06-runtime-check/correction-note.md`  
**File Size:** ~3200 bytes  
**Severity:** Medium (numerical error, does not affect remediation actions)  
**Action Required:** Update runtime-check.md with corrected counts before archiving
