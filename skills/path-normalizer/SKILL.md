---
name: path-normalizer
description: Normalize tilde-based file paths before read/edit/write tool calls. Use when path or file_path starts with ~ (for example ~/ or ~user/) to prevent avoidable file path failures.
---

# Path Normalizer

Normalize user-supplied paths before file tools execute.

## Trigger

Run when a file tool call includes:
- `path` or `file_path` starting with `~`
- formats: `~/...`, `~user/...`, `~\...`, `~user\...`

## Scope

Apply to file tools only:
- `read`
- `edit`
- `write`

Do not modify paths that are already absolute.

## Workflow

### 1) Detect

If `path` or `file_path` starts with `~`, normalization is required.

### 2) Normalize

Rules:
- `~/x` -> `<home>/x`
- `~\x` -> `<home>\x` (Windows)
- `~user/x` -> `/home/user/x` (POSIX)
- `~user\x` -> `C:\Users\user\x` (Windows)

Home resolution:
- POSIX: `$HOME`
- Windows: `$USERPROFILE`

### 3) Validate format

Validate resulting path shape only:
- POSIX absolute path starts with `/`
- Windows absolute path matches `^[A-Za-z]:[\\/]`

Do not check file existence in this skill.

### 4) Execute

Call original tool with normalized path and log conversion:
- `original_path`
- `normalized_path`
- `tool_name`

## Done Criteria

Complete only if all pass:
- `~/...` is normalized to absolute path
- `~user/...` is normalized to absolute path
- absolute paths are unchanged
- no `File not found: ~...` errors caused by unexpanded `~`
- conversion log exists for each transformed call

Required output block:

```markdown
DONE_CHECKLIST
- Normalized calls: <n>
- Unchanged absolute paths: <n>
- Expansion failures: <n>
- Evidence: <log ref or command output>
```

## Safety

- Never claim target file exists after normalization
- Never rewrite non-file arguments
- Never mutate already-absolute paths
- On invalid normalization result, stop and return clear error with both paths

## Test Cases

- `~/project/a.txt`
- `~user/project/a.txt`
- `~\AppData\Roaming\x.json`
- `/etc/hosts` (unchanged)
- `C:\Windows\System32\drivers\etc\hosts` (unchanged)
