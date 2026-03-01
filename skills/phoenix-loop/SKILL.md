---
name: phoenix-loop
description: Turn repeated failures into reusable recovery procedures. Use when the same blocker recurs (>=2 times), tasks stall, or recovery steps are missing; produce a validated playbook entry and only promote to a new skill after proven success.
---

# Phoenix Loop

Convert recurring failures into reliable recovery knowledge without generating low-value skills.

## Trigger

Run when any condition is true:
- same failure signature appears 2+ times
- blocker persists and no successful recovery is recorded
- user asks to learn from a failed run

## Inputs

- failure logs (`memory/tasks.md`, `memory/blocked-items.md`, daily memory files)
- current task context
- existing skills and playbooks

## Workflow

### 1) Normalize failure signature

Create one canonical signature:
- error class (`auth`, `network`, `timeout`, `permission`, `schema`, `unknown`)
- stable message fragment (redacted)
- failing step/tool

### 2) Check recurrence gate

Only continue if recurrence >= 2.
If recurrence < 2, log observation only and stop.

### 3) Search existing recovery knowledge

Check in order:
1. `memory/recovery-playbook.md`
2. `skills/local/*-recovery/SKILL.md`
3. relevant workflow skills

If matching recovery exists, execute that first instead of creating new content.

### 4) Build or update playbook entry

Write/update one entry in `memory/recovery-playbook.md`:

```markdown
## Recovery: <signature-id>
- Class: <auth|network|...>
- Trigger: <when this failure appears>
- Diagnosis: <fast checks>
- Recovery Steps:
  1. <step>
  2. <step>
  3. <step>
- Verification:
  - <check 1>
  - <check 2>
- Fallback: <minimum unblock input>
- LastValidatedAt: <timestamp>
- SuccessCount: <n>
```

### 5) Validation run

Apply recovery to the current case and record result.

### 6) Promote to skill (strict gate)

Create a standalone skill only if all are true:
- recurrence >= 2
- recovery succeeded in at least 2 independent runs
- steps are deterministic and safe
- clear trigger boundary exists

Otherwise keep as playbook only.

## Anti-Noise Rules

- Never create a new skill for one-off incidents
- Never create duplicate skills with tiny wording differences
- Prefer updating one stable playbook/skill over creating many variants

## Done Criteria

Task is complete only if:
- normalized failure signature exists
- recurrence count is documented
- playbook entry is created or updated
- validation result is recorded (success/failed with reason)
- promotion decision is explicit (`promoted` or `playbook-only`)

Required block:

```markdown
DONE_CHECKLIST
- Signature: <id>
- Recurrence: <count>
- Playbook updated: yes/no (<path>)
- Validation: success/failed
- Promotion: skill-created | playbook-only
- Reason: <why>
```

## Safety

- Redact secrets before logging (`token`, `api_key`, `secret`, `password`, `Bearer`)
- Do not auto-run destructive remediation steps
- Do not claim “fixed” without verification output

## Integration

- Use with `memory-self-heal` for retry/fallback loop
- Use with `task-execution-guard` to enforce evidence before completion
- Use with `instruction-anchor-guard` to preserve user constraints during recovery
