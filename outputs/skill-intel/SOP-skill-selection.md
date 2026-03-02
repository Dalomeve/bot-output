# SOP: Skill Discovery and Acceptance

## Purpose

Define the operational workflow for discovering, evaluating, and accepting new OpenClaw agent skills from external sources.

---

## Source Whitelist

Only consider skills from these vetted sources:

| Source Type | Acceptable URLs | Notes |
|-------------|-----------------|-------|
| GitHub Repos | `github.com/openclaw/*`, `github.com/clawhub/*` | Official OpenClaw ecosystem |
| GitHub Issues | `github.com/*/issues/*` | Feature requests with working implementations |
| GitHub Discussions | `github.com/*/discussions/*` | Community-proposed skills with code |
| ClawHub | `clawhub.com/skills/*` | Pre-vetted skill marketplace |
| npm | `npmjs.com/package/openclaw-skill-*` | Published skill packages |

**Rejected Sources:**
- Unverified personal blogs/gists without audit trail
- Binary downloads or obfuscated code
- Sources requiring payment before audit

---

## Link Verification Gate

Before any evaluation, verify each candidate link:

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| URL Validity | HTTP HEAD request | Returns 200/301, not 404 |
| Repo State | GitHub API or UI | Exists, not deleted |
| Issue/Discussion State | GitHub API | `state: open` preferred; `closed` acceptable if merged |
| Last Update | GitHub `pushed_at` or commit date | Within 180 days |
| Code Availability | Repo contains `/skills/*/SKILL.md` | Skill definition present |

**Fail any check -> Reject with reason logged.**

---

## Scoring Rubric

Score each skill on a 0-100 scale across five dimensions:

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| **Utility** | 30% | Solves common user task; frequency of use case |
| **Safety** | 25% | No destructive ops; respects privacy; audit-friendly |
| **Maintainability** | 20% | Clear code; documented; testable |
| **Integration** | 15% | Uses approved tools; fits OpenClaw patterns |
| **Community Signal** | 10% | Stars, forks, discussion engagement |

### Thresholds

| Score Range | Decision | Action |
|-------------|----------|--------|
| **0-49** | Reject | Log reason; no further action |
| **50-74** | Backlog | Add to `skills/backlog.md` for future review |
| **75-100** | Build Now | Proceed to draft; assign to sprint |

---

## Privacy and Safety Rejection Criteria

**Automatic Rejection** if skill contains any of:

- [ ] Credentials/secrets in code or config
- [ ] Data exfiltration patterns (external POST without user consent)
- [ ] Destructive filesystem ops (`rm -rf`, recursive delete) without confirmation gates
- [ ] Network calls to unverified third-party APIs
- [ ] Obfuscated or minified code without source
- [ ] Download-and-execute patterns
- [ ] Bypass of OpenClaw safety boundaries
- [ ] No clear user-visible action description

**Flag for Enhanced Review** if:

- Requires elevated permissions
- Accesses user messages or memory
- Makes external API calls (even if documented)

---

## Definition of Done: Skill Draft

A skill draft is complete when all items are checked:

- [ ] `SKILL.md` created with `<name>`, `<description>`, `<location>`
- [ ] Skill logic implemented in `skills/{name}/` directory
- [ ] All tool calls use approved OpenClaw tools only
- [ ] Safety gates implemented for any destructive/external actions
- [ ] Documentation includes: trigger conditions, steps, verification criteria, fallback
- [ ] No unresolved markers (`TODO`, `PENDING`, `TBD`) in deliverable code
- [ ] Encoding validated (UTF-8, no mojibake)
- [ ] Tested in isolated profile or sandbox session
- [ ] Added to `SKILLS-WHITELIST.md` with source pin (commit hash or version)

---

## Review Handoff Format

When handing off to human reviewer, use this template:

```markdown
## Skill Review Request

**Skill Name:** {name}
**Source:** {URL}
**Score:** {XX/100}
**Decision:** {Build Now | Backlog}

### Summary
{2-3 sentence description of what the skill does}

### Safety Audit
- [ ] No credentials/secrets
- [ ] No data exfiltration
- [ ] No destructive ops without confirmation
- [ ] External API calls documented: {yes/no}

### Files Changed
- `skills/{name}/SKILL.md`
- `skills/{name}/index.js` (or equivalent)
- `SKILLS-WHITELIST.md` (entry added)

### Test Evidence
{Commands run, outputs observed, verification summary}

### Reviewer Action Required
- [ ] Approve for main profile
- [ ] Request changes
- [ ] Reject with reason: _______
```

---

## Weekly Cadence and Throughput

### Cadence

| Day | Activity |
|-----|----------|
| **Monday** | Source scan: GitHub issues/discussions, ClawHub new listings |
| **Wednesday** | Score and triage candidates from Monday scan |
| **Friday** | Draft completion + review handoff for scored skills |

### Minimum Throughput Targets

| Metric | Target |
|--------|--------|
| Candidates evaluated/week | 5 minimum |
| Skills drafted/week | 1 minimum |
| Backlog items added/week | 2 minimum |
| Review handoffs/week | 1 minimum |

### Tracking

Log all activity in `memory/skill-intel-weekly.md`:

```markdown
## Week {YYYY-Www}

### Candidates Evaluated
| Name | Source | Score | Decision |
|------|--------|-------|----------|
| {name} | {URL} | {XX} | {Reject/Backlog/Build} |

### Drafts Completed
- {skill-name} -> {handoff-date}

### Blockers
{Any issues preventing throughput}
```

---

## Revision History

| Date | Version | Change |
|------|---------|--------|
| 2025-01-01 | 1.0 | Initial SOP |

