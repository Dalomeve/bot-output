---
name: output-encoding-gate
description: Enforce mojibake-free markdown/text/json outputs before task completion. Blocks delivery when corrupted markers are detected and runs deterministic repair.
---

# Output Encoding Gate

Use this skill as a final gate before reporting completion.

## Trigger

- Any task writes `.md`, `.txt`, or `.json` artifacts
- Any task produces skill docs (`SKILL.md`) or evidence reports
- Any user reports garbled symbols in generated outputs

## Required Inputs

- Target root path (artifact directory)
- Optional file glob include list
- Whether auto-repair is allowed

## Workflow

1. Run verification script:

```powershell
./scripts/verify-encoding-gate.ps1 -Root <target_path>
```

2. If markers found and repair is allowed:

```powershell
./scripts/verify-encoding-gate.ps1 -Root <target_path> -Fix
```

3. Re-run verification and require zero marker hits.

4. Only then mark task complete.

## Done Criteria

- `MarkerCount = 0`
- `ScannedFiles > 0`
- If fixed: backup files created and listed
- Completion response includes gate evidence

## Safety

- Never claim success with `MarkerCount > 0`
- Never overwrite without backup when `-Fix` is used
- Prefer ASCII-safe docs for operational files

## Evidence Format

```markdown
ENCODING_GATE
- Root: <path>
- ScannedFiles: <n>
- MarkerCount: <n>
- FixedFiles: <n>
- BackupCount: <n>
- Result: PASS/FAIL
```
