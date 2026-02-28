# Heartbeat Policy

**Repository**: bot-output
**Last Updated**: 2026-03-01

---

## Heartbeat Checklist

On each heartbeat (daily):

### 1. Long-Running Goals Check (Priority 1)

- [ ] **Agent Audit Trail**: Has there been a commit today?
  - If YES: Verify evidence (commit hash + verification result)
  - If NO: What's blocking? Record in memory/long-running-goals.md
  - Queue next improvement

### 2. Task Queue Review

- [ ] Read `tasks/QUEUE.md`
- [ ] Pick one highest-priority actionable item
- [ ] Execute one concrete step
- [ ] Log evidence to `memory/YYYY-MM-DD.md`

### 3. Blocker Check

- [ ] Check `memory/blocked-items.md` for items > 24h old
- [ ] If found: attempt phoenix-loop diagnosis
- [ ] If pattern repeated: create/update skill

### 4. Evidence Verification

- [ ] Any completed tasks have evidence artifacts
- [ ] URLs are accessible (spot check)
- [ ] No unresolved markers (TODO/PENDING/TBD) in deliverables

---

## Output Requirements

Each heartbeat must produce:
- Execution evidence (artifact path/command result) OR
- Exactly `HEARTBEAT_OK` if no meaningful action exists

---

## Long-Running Goal: Agent Audit Trail

**Daily Check**:
```powershell
# Check for today's commits
git log --since="2026-03-01" --oneline | Select-String "audit"
```

**If no commit today**:
1. Identify one improvement (code/test/doc/integration)
2. Execute and commit
3. Record in memory/long-running-goals.md

---

**Keep each heartbeat cheap. 1-2 checks max. Produce evidence.**
