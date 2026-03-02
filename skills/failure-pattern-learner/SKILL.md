---
name: failure-pattern-learner
version: 1.0.0
description: Persist failure events, extract reusable lessons, and force lesson lookup before retries to prevent repeat mistakes.
metadata:
  openclaw:
    category: resilience
    emoji: "[LEARN]"
---

# Failure Pattern Learner

Use this skill to make failure handling cumulative instead of stateless.

## Why

`memory-self-heal` helps recover in the current turn, but repeated regressions still happen when lessons are not persisted and reloaded in future tasks.

## Trigger

Trigger when any one is true:
- Same error class appears 2+ times in 7 days
- A task required manual rescue after "fixed" status
- Any blocker caused by prior known misconfiguration (encoding, token mismatch, session lock, wrong shell syntax)

## Required Outputs

- Append structured failure event to `memory/failure-events/YYYY-MM-DD.jsonl`
- Update summary playbook `memory/failure-playbook.md`
- Before retrying, retrieve lessons for current context and include them in plan

## Workflow

1) Capture failure event:

```powershell
./scripts/capture-failure.ps1 -Root <workspace> -TaskId <id> -ErrorText "<error>" -Context "<what was happening>"
```

2) Rebuild/refresh playbook:

```powershell
./scripts/build-playbook.ps1 -Root <workspace>
```

3) Load relevant lessons before next attempt:

```powershell
./scripts/load-lessons.ps1 -Root <workspace> -Query "<task or error keywords>"
```

4) Retry with lessons applied.

## Completion Contract

Do not declare final success on a recovered task unless all are true:
- Failure event captured
- Playbook refreshed
- At least one lesson was consulted (or explicit "no matching lesson")
- Retry outcome recorded (success/blocked)

## Safety

- Do not store tokens/keys/secrets in event logs
- Normalize signatures (remove volatile IDs/paths) before aggregation
- Keep lessons actionable and testable

## Evidence Block

```markdown
LEARNING_EVIDENCE
- EventFile: <path>
- Playbook: <path>
- LessonsMatched: <n>
- AppliedLessonIds: <ids>
- RetryOutcome: success/blocked
```
