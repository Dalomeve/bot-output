# zh-encoding-fix Skill - Final Evidence

Date: 2026-03-01
Status: created, committed, and pushed.

## Summary

This skill was created to diagnose and repair mojibake in markdown/text/json files.
The final version avoids embedding corrupted glyph examples directly and uses escaped
unicode markers in checks.

## Deliverables

- skills/zh-encoding-fix/SKILL.md
- skills/zh-encoding-fix/scripts/repair-mojibake.ps1
- skills/zh-encoding-fix/references/examples.md

## Verification

- PowerShell console encoding set to UTF-8 (`InputEncoding`, `OutputEncoding`, `$OutputEncoding`)
- Code page set to 65001
- Post-generation mojibake scan returns zero in current target files
- Repair script supports dry-run and backup creation

## Notes

Historical logs contained mojibake sample tokens and badge glyphs copied from mixed-encoding output.
Those have been replaced with ASCII-safe text and escaped markers.

## Source Control

- Repository: https://github.com/Dalomeve/bot-output
- Skill path: https://github.com/Dalomeve/bot-output/tree/main/skills/zh-encoding-fix
