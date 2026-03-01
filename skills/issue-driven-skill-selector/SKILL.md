---
name: issue-driven-skill-selector
description: Select high-value skills from real community problems. Use when discovering user pain points from GitHub/issues/forums, and require link-proof validation before ranking or deciding whether to build a skill or file a core issue.
---

# Issue-Driven Skill Selector

Find real, high-frequency problems and decide: build a skill, file a core issue, or do both.

## Trigger

Use this skill when:
- You need a backlog of high-value skill ideas
- You want evidence-based prioritization from real community reports
- You need a decision between skill-layer mitigation vs core-engine fix

## Inputs

- `sources`: list of repos/forums (default includes `openclaw/openclaw` issues)
- `min_candidates`: default 12
- `time_window_days`: optional recency window

## Workflow

### 1) Collect candidates

Collect issues/discussions/posts with concrete user pain.
Prefer:
1. GitHub issues/discussions
2. Official docs Q&A
3. Public community threads

For each candidate, capture:
- title
- source_url
- pain_type (`config`, `stability`, `automation`, `security`, `release`)
- recurrence_signal

### 2) Link Proof Gate (hard requirement)

Do not keep unverified links.

GitHub issue validation:
```bash
gh issue view <num> --repo <owner>/<repo> --json number,title,url,state
```
Pass if command succeeds and URL/title exist.

General URL validation:
```bash
curl -I --max-time 10 <url>
```
Pass only on HTTP 2xx/3xx.

Reject rules:
- Any 4xx/5xx -> drop candidate
- Timeout twice -> mark `UNVERIFIED`, exclude from Top list

### 3) Score each candidate

Score 0-10 for each dimension:
- impact: user reach/frequency
- skill_solvability: how much can be solved in skill layer
- implementation_cost: lower effort gets higher score
- risk: lower operational risk gets higher score

Weighted total:
`total = impact*1.0 + skill_solvability*1.2 + implementation_cost*0.8 + risk*1.0`

### 4) Route decision

- `skill-first`: skill_solvability >= 7 and no core code change required
- `core-first`: skill_solvability <= 4 or requires core protocol/runtime fix
- `hybrid`: 5-6; ship skill mitigation now, file core issue for long-term fix

### 5) Produce required output blocks

Output must include all sections:

```markdown
CANDIDATE_TABLE
| rank | title | source_url | pain_type | recurrence_signal | impact | solvability | cost | risk | total | route |

TOP3_DECISIONS
- candidate #1 ...
  - skill plan: name, trigger, done criteria
  - core issue draft: title + minimal repro

EXECUTION_NEXT
1. next concrete action
2. owner
3. expected artifact
```

## Done Criteria

Complete only if all are true:
- At least `min_candidates` verified candidates collected
- Every candidate link passed Link Proof Gate
- Every candidate has full scoring fields and route decision
- Top 3 each include:
  - skill proposal (`name`, `trigger`, `done criteria`)
  - core-issue draft (`title`, `minimal repro`)
- Output includes all three blocks: `CANDIDATE_TABLE`, `TOP3_DECISIONS`, `EXECUTION_NEXT`

Required completion block:

```markdown
DONE_CHECKLIST
- Verified candidates: <n>
- Rejected links (4xx/5xx/timeout): <n>
- Scored candidates: <n>
- Top3 generated: yes/no
- Required blocks present: yes/no
```

## Safety

- Never fabricate links or issue IDs
- Never include private repo content without explicit access approval
- Throttle requests to avoid abuse/rate-limit bursts
- Do not auto-close/report issues without user confirmation

## Practical rule

If evidence is weak, do not propose a skill. Ask for one more validated source instead.
