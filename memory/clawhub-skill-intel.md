# ClawHub Skill Intelligence Loop

**Started**: 2026-03-01
**Status**: Active (Continuous)
**Last Review**: 2026-03-01

---

## Mission

Continuously discover, evaluate, and integrate high-quality ClawHub skills that enhance execution capabilities. Create glue skills for coordination.

---

## Evaluation Criteria

| Dimension | Weight | Description |
|-----------|--------|-------------|
| **Utility** | 30% | Does it solve a real problem we face? |
| **Safety** | 25% | No hidden data exfil, no download-and-execute |
| **Maintainability** | 20% | Active maintenance, clear docs, version history |
| **Relevance** | 25% | Fits current task portfolio |

**Threshold**: Score >= 70 for allowlist consideration
**Auto-Reject**: High-risk patterns (implicit external calls, unknown author, no source)

---

## Review Cycle 1: 2026-03-01

### Candidates Evaluated (12)

| # | Skill | Author | Downloads | Stars | Versions | Score | Decision |
|---|-------|--------|-----------|-------|----------|-------|----------|
| 1 | ontology | @oswalpalash | 88.7k | 202 | 3 | 85 | ✅ Allowlist |
| 2 | self-improving-agent | @pskoett | 78.5k | 931 | 12 | 88 | ✅ Allowlist |
| 3 | proactive-agent | @halthelobster | 45.6k | 294 | 11 | 82 | ✅ Allowlist |
| 4 | find-skills | @JimLiuxinghai | 64k | 265 | 1 | 75 | ✅ Allowlist |
| 5 | auto-updater | @maximeprades | 22.4k | 155 | 1 | 78 | ✅ Allowlist |
| 6 | summarize | @steipete | 61k | 287 | 1 | 72 | ⏳ Review |
| 7 | brave-search | @steipete | 23.5k | 101 | 2 | 68 | ❌ Reject (we have API issue) |
| 8 | github | @steipete | 57.3k | 192 | 1 | 65 | ❌ Reject (we have gh CLI) |
| 9 | weather | @steipete | 48.4k | 165 | 1 | 60 | ❌ Reject (we have this) |
| 10 | agent-browser | @TheSethRose | 57.4k | 299 | 2 | 55 | ❌ Reject (we have browser tool) |
| 11 | humanize-ai-text | @moltbro | 23.9k | 95 | 2 | 45 | ❌ Reject (ethics concern) |
| 12 | api-gateway | @byungkyu | 29.9k | 138 | 55 | 50 | ❌ Reject (OAuth complexity) |

### Scoring Details (Top 5)

#### 1. self-improving-agent (Score: 88)
- **Utility** (27/30): Directly enhances our phoenix-loop skill
- **Safety** (23/25): Known author, clear source, no external calls
- **Maintainability** (18/20): 12 versions, active updates
- **Relevance** (20/25): High synergy with our self-improvement work
- **Decision**: Study pattern, integrate concepts into phoenix-loop

#### 2. ontology (Score: 85)
- **Utility** (28/30): Structured memory could enhance our evidence tracking
- **Safety** (22/25): Known author (@oswalpalash), transparent
- **Maintainability** (17/20): 3 versions, good docs
- **Relevance** (18/25): Could integrate with agent-audit-trail
- **Decision**: Evaluate for audit trail enhancement

#### 3. proactive-agent (Score: 82)
- **Utility** (26/30): WAL Protocol, Working Buffer patterns valuable
- **Safety** (21/25): Hal Stack project, transparent
- **Maintainability** (18/20): 11 versions, very active
- **Relevance** (17/25): Synergy with HEARTBEAT/autonomy work
- **Decision**: Extract patterns for our autonomy skills

#### 4. auto-updater (Score: 78)
- **Utility** (24/30): Automated skill updates valuable
- **Safety** (20/25): Cron-based, transparent
- **Maintainability** (17/20): Single version but clear purpose
- **Relevance** (17/25): Could automate our skill maintenance
- **Decision**: Study cron pattern for our updater

#### 5. find-skills (Score: 75)
- **Utility** (22/30): Skill discovery useful but we have clawhub CLI
- **Safety** (21/25): Standard patterns
- **Maintainability** (15/20): Single version
- **Relevance** (17/25): Moderate synergy
- **Decision**: Reference for discovery patterns

---

## Allowlist (Approved for Integration Study)

| Skill | Added | Purpose | Integration Status |
|-------|-------|---------|-------------------|
| self-improving-agent | 2026-03-01 | Pattern reference for phoenix-loop | 📋 Planned |
| ontology | 2026-03-01 | Structured memory for audit trails | 📋 Planned |
| proactive-agent | 2026-03-01 | Autonomy patterns for HEARTBEAT | 📋 Planned |
| auto-updater | 2026-03-01 | Cron-based skill maintenance | 📋 Planned |
| find-skills | 2026-03-01 | Discovery patterns | 📋 Planned |

---

## Reject List (With Reasons)

| Skill | Reason | Risk Level |
|-------|--------|------------|
| humanize-ai-text | Ethics concern (AI detection bypass) | HIGH |
| api-gateway | OAuth complexity, token management risk | MEDIUM |
| agent-browser | Duplicate (we have browser tool) | LOW |
| github | Duplicate (we have gh CLI) | LOW |
| weather | Duplicate (we have weather skill) | LOW |
| brave-search | We have API key issue, not skill problem | LOW |

---

## Glue Skills Created

### 1. skill-orchestrator (2026-03-01)

**Purpose**: Coordinate between local skills and discovered high-value patterns.

**Integrates**:
- phoenix-loop + self-improving-agent patterns
- agent-audit-trail + ontology concepts
- HEARTBEAT + proactive-agent WAL protocol

**Location**: `skills/skill-orchestrator/`

---

## Next Review

**Scheduled**: 2026-03-02 (Daily cycle)
**Focus**: 
- Evaluate 8+ new/updated skills
- Deep-dive into allowlist skill code
- Create 1+ new glue skill

---

## Safety Rules

1. **Never install** skills with:
   - Download-and-execute patterns
   - Implicit external data transmission
   - Unknown/anonymous authors
   - No source code available

2. **Always verify**:
   - Author reputation (previous work)
   - Version history (active maintenance)
   - Privacy scan before any integration

3. **Document rejections**:
   - Record specific reason
   - Include risk level
   - Note any partial value

---

**Continuous learning. Safe integration. No blind installs.**
