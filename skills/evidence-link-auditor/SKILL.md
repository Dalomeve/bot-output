---
name: evidence-link-auditor
description: Audit evidence links in deliverables before claiming completion. Use when outputs contain URLs, file links, or proof references and you must verify accessibility, marker cleanliness, and report PASS/FAIL with evidence.
---

# Evidence Link Auditor

Validate evidence links and unresolved markers in output artifacts.

## Trigger

Use this skill when:
- A task is marked complete and includes links as evidence
- A PR/report requires QA before publish
- A user asks to verify links in docs or outputs

## Inputs

- `target_path`: directory or file to audit (default `./outputs`)
- `report_path`: where to write report (default `./outputs/qa/link-audit-<timestamp>.md`)

## Workflow

### 1) Discover files

Scan markdown/text files under `target_path`.

```powershell
$target = "./outputs"
$files = Get-ChildItem -Path $target -Recurse -File -Include *.md,*.txt -ErrorAction SilentlyContinue
```

### 2) Extract links

Extract:
- external URLs (`http://` or `https://`)
- markdown relative links (`[x](./path)`)

```powershell
$urlRegex = 'https?://[^\s\)\]"''<>]+'
$mdRelRegex = '\[[^\]]+\]\((?!https?://)([^)#]+)(#[^)]+)?\)'
```

### 3) Validate links

External URL checks:
- `HEAD` first
- fallback `GET` when `HEAD` unsupported
- timeout 10s
- pass only for `2xx` and `3xx`

Internal link checks:
- resolve relative path from source file directory
- fail if target file missing

### 4) Marker scan

Fail markers in final deliverables:
- `TODO`, `TBD`, `PENDING`, `FIXME`, `WIP`

### 5) Emit report

Write a deterministic report with:
- summary counts
- failed links table
- marker table
- final `PASS` or `FAIL`

## PASS/FAIL Rules

`PASS` only if all conditions are true:
- no failed external links
- no broken internal links
- no unresolved markers

Otherwise `FAIL`.

## Required Output Block

```markdown
DONE_CHECKLIST
- Objective met: yes/no
- Report file: <path>
- Links checked: <n>
- Failed links: <n>
- Marker hits: <n>
- Final status: PASS/FAIL
```

## Safety

- Redact secrets in logged URLs (`token`, `api_key`, `secret`, `password`, `Bearer`)
- Do not use authenticated/private headers for probe checks
- Do not mark PASS on timeout/network failure; classify as failure or "manual verification needed"

## Practical Notes

- Ignore links requiring login unless explicit credentials are provided
- Limit redirect follow depth to 5
- Keep raw command output separate from the final report for readability
