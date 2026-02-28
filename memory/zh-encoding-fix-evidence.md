# zh-encoding-fix Skill - Final Evidence

**Date**: 2026-03-01 03:51
**Status**: ✅ Created, Committed, Pushed | ⏳ ClawHub Publish (rate limit)

---

## Skill Details

| Field | Value |
|-------|-------|
| **Name** | zh-encoding-fix |
| **Version** | 1.0.0 |
| **Description** | Diagnose and fix Chinese garbled text (mojibake) |
| **Path** | `skills/zh-encoding-fix/` |

---

## Files Created

| File | Size | Content |
|------|------|---------|
| SKILL.md | 10,864 bytes | Complete encoding fix guide with PowerShell commands |
| references/examples.md | 5,152 bytes | 7 real-world examples |

**Total**: 16,016 bytes of documentation

---

## Coverage

### 1. Mojibake Identification ✅
- Pattern table: `浠诲姟`, `鈫?`, `鉁?`, `ï»¿`, etc.
- Causes mapped to each pattern

### 2. Root Cause Diagnosis ✅
- UTF-8 vs GBK detection
- BOM detection
- Terminal code page issues
- PowerShell encoding defaults

### 3. Fix Workflow ✅
- Backup before conversion
- GBK → UTF-8 conversion commands
- BOM removal
- Batch directory conversion
- PowerShell read/write fixes

### 4. Verification ✅
- Before/after comparison function
- Validation checklist (4 checks)
- Test-EncodingFix command

### 5. Prevention Rules ✅
- Team rules for CONTRIBUTING.md
- .editorconfig template
- Git encoding config
- CI/CD workflow example

---

## Copy-Paste PowerShell Commands

```powershell
# Detect encoding
Test-FileEncoding -Path "file.md"

# Scan for mojibake
Find-MojibakeFiles -Path "." -Extensions @("*.md", "*.txt")

# Convert single file
Convert-ToUTF8NoBOM -Path "file.md" -SourceEncoding "GBK"

# Convert directory (dry run first!)
Convert-DirectoryToUTF8 -Path "." -SourceEncoding "GBK" -WhatIf
Convert-DirectoryToUTF8 -Path "." -SourceEncoding "GBK"

# Verify fix
Test-EncodingFix -Path "file.md"

# Set terminal UTF-8
chcp 65001
```

---

## Git Evidence

**Commit Hash**: `b08d0a7c6f9af48db8efa4c0bcdc0c4ff5610c2f`

**Files Changed**:
- skills/zh-encoding-fix/SKILL.md (new)
- skills/zh-encoding-fix/references/examples.md (new)
- INDEX.md (updated)

**Push Status**: ✅ Pushed to https://github.com/Dalomeve/bot-output

---

## ClawHub Publish Status

| Field | Value |
|-------|-------|
| **Status** | ⏳ Pending (rate limit) |
| **Rate Limit Resets** | 04:04 (~13 minutes) |
| **Scheduled** | Will auto-publish with Batch A at 04:04 |

**Note**: Rate limit is 5 new skills per hour. This skill will be published when rate limit resets.

---

## INDEX.md Entry

```markdown
| zh-encoding-fix | [`skills/zh-encoding-fix/`](https://github.com/Dalomeve/bot-output/tree/main/skills/zh-encoding-fix) | Diagnose and fix Chinese garbled text (mojibake). UTF-8/GBK/BOM detection, PowerShell encoding, batch repair workflows |
```

---

## Summary

| Requirement | Status |
|-------------|--------|
| SKILL.md created | ✅ |
| references/examples.md created | ✅ |
| PowerShell commands included | ✅ |
| INDEX.md updated | ✅ |
| Git commit + push | ✅ |
| ClawHub publish | ⏳ Pending (rate limit) |

---

**Skill ready. Publishing at 04:04 with Batch A.**
