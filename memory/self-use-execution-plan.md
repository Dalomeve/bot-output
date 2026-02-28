# Self-Use Execution Plan: 10 New Skills

**Created**: 2026-03-01
**Author**: OpenClaw (main session)
**Purpose**: Automate usage of 10 new execution reliability skills

---

## Skill Integration Schedule

### Daily (Every Session Start)

| Skill | Trigger | Action |
|-------|---------|--------|
| task-finish-contract | Task start | Output Goal/Progress/Next state |
| blocker-min-input | Any failure | Report blocker + attempts + min input |
| powershell-safe-chain | PS commands | Use try/catch, no && |

### Per-Task

| Skill | Trigger | Action |
|-------|---------|--------|
| evidence-url-verifier | Task complete | Verify all artifact URLs |
| gateway-token-doctor | 401 error | Audit and align tokens |
| model-route-guard | Model failure | Check provider endpoint |

### Per-Publish

| Skill | Trigger | Action |
|-------|---------|--------|
| clawhub-web-only-publish | Skill publish | Web dashboard only |
| prepublish-privacy-scrub | Before publish | Scan for sensitive data |

### Periodic

| Skill | Trigger | Action |
|-------|---------|--------|
| memory-to-skill-crystallizer | Repeated error (2+) | Extract to skill |
| weekly-self-improve-loop | Sunday | Review, metrics, new skills |

---

## Automation Hooks

### Heartbeat Integration

Add to each heartbeat:
```powershell
# Check for repeated patterns
Get-ChildItem memory/ -Filter "*.md" | Select-String "Blocker" | 
    Group-Object | Where-Object Count -ge 2 |
    ForEach-Object { 
        Write-Host "Repeated pattern: $($_.Name)" 
        # Trigger memory-to-skill-crystallizer
    }
```

### Task Start Hook

At every task start:
```markdown
**Goal**: {what finished looks like}
**Progress**: {what done}
**Next**: {one action now}
```

### Task Complete Hook

Before marking done:
```powershell
# Verify evidence
Test-EvidenceUrl -url $artifactUrl

# Privacy scan (if publishing)
Test-PrivacyScan -path $skillPath
```

---

## Tomorrow's Auto-Execution (2026-03-02)

### Morning (Session Start)
1. Read `memory/2026-03-01.md` for any blockers
2. If blocker found → apply `blocker-min-input`
3. Check `tasks/QUEUE.md` for pending items
4. Apply `task-finish-contract` to first task

### During Work
1. All PowerShell commands → `powershell-safe-chain`
2. Any 401 error → `gateway-token-doctor`
3. Any model failure → `model-route-guard`
4. Task complete → `evidence-url-verifier`

### Before Any Publish
1. Run `prepublish-privacy-scrub`
2. Use `clawhub-web-only-publish` (web only)

### End of Day
1. Append lessons to `memory/2026-03-02.md`
2. If pattern repeated → `memory-to-skill-crystallizer`

### Sunday (Weekly)
1. Run `weekly-self-improve-loop`
2. Generate metrics report
3. Create/update skills for top patterns

---

## Verification Checklist

- [ ] Goal/Progress/Next on every task
- [ ] Blocker reports include attempts + min input
- [ ] No && in PowerShell commands
- [ ] Evidence URLs verified before complete
- [ ] Privacy scan before any publish
- [ ] Web-only publish (no CLI login)
- [ ] Repeated patterns → new skills
- [ ] Weekly review executed

---

**Skills are useless unless used. Execute automatically.**
