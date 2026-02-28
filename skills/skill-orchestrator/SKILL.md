---
name: skill-orchestrator
description: Coordinate between local skills and discovered ClawHub patterns. Integrates phoenix-loop, agent-audit-trail, HEARTBEAT, and autonomy skills with external best practices.
---

# Skill Orchestrator

Coordinate between your local skills and discovered high-value ClawHub patterns. Acts as a glue layer for skill integration.

## Why This Exists

**Problem**: You have multiple skills (phoenix-loop, agent-audit-trail, task-finish-contract, etc.) but no unified coordination. ClawHub has excellent patterns (self-improving-agent, proactive-agent, ontology) but installing everything creates bloat.

**Solution**: This orchestrator skill:
- Maps your skills to external best practices
- Provides unified triggers and workflows
- Enables skill composition without duplication
- Tracks integration opportunities from ClawHub

## Integration Map

### Your Skills -> External Patterns

| Your Skill | External Reference | Integration |
|------------|-------------------|-------------|
| phoenix-loop | self-improving-agent | Extract error pattern matching |
| agent-audit-trail | ontology | Add structured entity tracking |
| HEARTBEAT.md | proactive-agent | WAL Protocol for state persistence |
| weekly-self-improve-loop | auto-updater | Cron-based skill maintenance |
| memory-to-skill-crystallizer | self-improving-agent | Learning capture patterns |

## Usage

### 1. Discover Integration Opportunities

```bash
# Check what ClawHub skills could enhance your setup
python skill_orchestrator.py discover --category autonomy
```

Output:
```
Found 3 integration opportunities:

1. self-improving-agent -> phoenix-loop
   Pattern: Error pattern matching with learning capture
   Value: Enhance failure detection accuracy
   Risk: LOW (pattern reference only)

2. ontology -> agent-audit-trail
   Pattern: Typed entity tracking
   Value: Structured evidence relationships
   Risk: LOW (concept integration)

3. proactive-agent -> HEARTBEAT
   Pattern: WAL Protocol for state
   Value: Crash recovery, audit trail
   Risk: MEDIUM (requires state migration)
```

### 2. Generate Integration Plan

```bash
python skill_orchestrator.py plan --target phoenix-loop --reference self-improving-agent
```

Output:
```markdown
## Integration Plan: phoenix-loop + self-improving-agent

### Phase 1: Pattern Extraction (Day 1)
- [ ] Read self-improving-agent SKILL.md
- [ ] Extract error pattern matching logic
- [ ] Compare with phoenix-loop diagnosis

### Phase 2: Code Integration (Day 2-3)
- [ ] Add pattern matching to phoenix-loop
- [ ] Update verification criteria
- [ ] Test with historical failures

### Phase 3: Validation (Day 4)
- [ ] Run phoenix-loop on known failures
- [ ] Compare accuracy before/after
- [ ] Document improvements
```

### 3. Track Integration Status

```bash
python skill_orchestrator.py status
```

Output:
```
Integration Status:

| Source | Target | Status | Last Updated |
|--------|--------|--------|--------------|
| self-improving-agent | phoenix-loop | 📋 Planned | 2026-03-01 |
| ontology | agent-audit-trail | 📋 Planned | 2026-03-01 |
| proactive-agent | HEARTBEAT | 📋 Planned | 2026-03-01 |
| auto-updater | weekly-self-improve-loop | 📋 Planned | 2026-03-01 |
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `discover` | Find integration opportunities |
| `plan` | Generate integration plan |
| `status` | Show integration status |
| `sync` | Sync with ClawHub allowlist |
| `validate` | Validate integration safety |

## Safety Rules

### Never Integrate

- Skills with download-and-execute patterns
- Skills with implicit external data transmission
- Skills from unknown/anonymous authors
- Skills without source code

### Always Verify

1. **Author Reputation**: Previous work quality
2. **Version History**: Active maintenance
3. **Privacy Scan**: No token/key leakage
4. **Pattern Safety**: No hidden side effects

### Integration Levels

| Level | Description | Example |
|-------|-------------|---------|
| **Reference** | Read and extract patterns | self-improving-agent -> phoenix-loop |
| **Concept** | Adopt architectural concepts | ontology -> agent-audit-trail |
| **Code** | Direct code integration | (requires full audit) |
| **Install** | Full skill installation | (highest scrutiny) |

## Allowlist Integration

Reads from `memory/clawhub-skill-intel.md` allowlist:

```python
# Example integration check
from skill_intel import get_allowlist

allowlist = get_allowlist()
for skill in allowlist:
    if skill['name'] == 'self-improving-agent':
        print(f"Safe to reference: {skill['score']}/100")
```

## Workflows

### Daily Orchestration

```python
# Add to HEARTBEAT.md
1. Check for new ClawHub skill updates
2. Review allowlist for changes
3. Queue one integration task
4. Log to memory/clawhub-skill-intel.md
```

### Weekly Review

```python
# Add to weekly-self-improve-loop
1. Evaluate 8+ new/updated skills
2. Update allowlist/reject-list
3. Create 1+ glue skill if needed
4. Report integration metrics
```

## Metrics

Track integration value:

| Metric | Target | Current |
|--------|--------|---------|
| Skills integrated | 4+/month | 0 (new) |
| Pattern adoptions | 8+/month | 0 (new) |
| Integration bugs | <1/month | 0 |
| Time saved | 2h+/week | TBD |

## Examples

### Example 1: Extract Pattern from self-improving-agent

```python
from skill_orchestrator import extract_pattern

pattern = extract_pattern(
    source='self-improving-agent',
    target='phoenix-loop',
    focus='error_pattern_matching'
)

# Pattern extracted:
# - Multi-level error classification
# - Learning capture with context
# - Verification before marking complete
```

### Example 2: Add Ontology Concepts to Audit Trail

```python
from skill_orchestrator import integrate_concept

integrate_concept(
    source='ontology',
    target='agent-audit-trail',
    concept='typed_entities',
    implementation='Add entity types to evidence tracking'
)
```

## Limitations

- Pattern extraction is manual (not automated)
- Code integration requires human review
- No automatic skill installation
- ClawHub API access required for sync

## References

- `memory/clawhub-skill-intel.md` - Allowlist and evaluations
- `skills/phoenix-loop/` - Self-improvement patterns
- `skills/agent-audit-trail/` - Evidence tracking
- `HEARTBEAT.md` - Daily execution loop

---

**Coordinate, don't duplicate. Integrate, don't install blindly.**
