# Chinese Encoding Fix - Examples

Real-world examples of mojibake diagnosis and repair.

---

## Example 1: Single File Fix (GBK → UTF-8)

### Before
```
# 浠诲姟娓呭崟

- [ ] 瀹屾垚浠诲姟 A
- [ ] 瀹屾垚浠诲姟 B
```

### Diagnosis
```powershell
Test-FileEncoding -Path "tasks.md"
# Output: GBK/GB2312 (Chinese detected)
```

### Fix
```powershell
# Backup
Copy-Item tasks.md tasks.md.bak

# Convert
$content = Get-Content tasks.md -Encoding Default
$content | Out-File tasks.md -Encoding UTF8NoBOM

# Verify
Test-EncodingFix -Path "tasks.md"
```

### After
```
# 任务清单

- [ ] 完成任务 A
- [ ] 完成任务 B
```

---

## Example 2: Batch Fix Directory

### Scan for Mojibake
```powershell
Find-MojibakeFiles -Path "C:\project\docs" -Extensions @("*.md", "*.txt")

# Output:
# [MOJIBAKE] C:\project\docs\README.md
# [MOJIBAKE] C:\project\docs\guide\intro.txt
```

### Dry Run First
```powershell
Convert-DirectoryToUTF8 -Path "C:\project\docs" -SourceEncoding "GBK" -WhatIf

# Output:
# [DRY RUN] Would convert: C:\project\docs\README.md
# [DRY RUN] Would convert: C:\project\docs\guide\intro.txt
```

### Execute Conversion
```powershell
Convert-DirectoryToUTF8 -Path "C:\project\docs" -SourceEncoding "GBK"

# Output:
# Converted: C:\project\docs\README.md (from GBK to UTF-8 no BOM)
# Converted: C:\project\docs\guide\intro.txt (from GBK to UTF-8 no BOM)
```

---

## Example 3: BOM Removal

### Before (with BOM)
```powershell
$bytes = [System.IO.File]::ReadAllBytes("config.md")
$bytes[0..2]
# Output: 239 187 191 (EF BB BF = UTF-8 BOM)
```

### Fix
```powershell
# Read raw content
$content = Get-Content config.md -Raw

# Strip BOM if present
$content = $content.TrimStart([char]0xFEFF)

# Write back without BOM
$content | Out-File config.md -Encoding UTF8NoBOM

# Verify
$bytes = [System.IO.File]::ReadAllBytes("config.md")
$bytes[0..2]
# Output: (no BOM - first bytes are actual content)
```

---

## Example 4: PowerShell Script Encoding

### Problem Script
```powershell
# script.ps1 (saved as UTF-8-BOM)
Write-Host "你好世界"  # Outputs: 浣犲ソ涓栫晫
```

### Diagnosis
```powershell
Test-FileEncoding -Path "script.ps1"
# Output: UTF-8-BOM
```

### Fix
```powershell
# Read content
$content = Get-Content script.ps1 -Raw

# Strip BOM and re-save
$content.TrimStart([char]0xFEFF) | Out-File script.ps1 -Encoding UTF8NoBOM

# Run again
.\script.ps1
# Output: 你好世界 (correct!)
```

---

## Example 5: Git Clone with Encoding Issues

### Problem
```bash
git clone https://github.com/user/chinese-repo.git
cat README.md
# Output: 浠诲姟... (garbled)
```

### Fix on Windows
```powershell
# Set terminal to UTF-8
chcp 65001

# Re-read with correct encoding
Get-Content README.md -Encoding UTF8
# Output: 任务... (correct!)

# Fix file permanently
$content = Get-Content README.md -Encoding UTF8
$content | Out-File README.md -Encoding UTF8NoBOM
```

### Fix Git Config
```bash
# Set Git to handle UTF-8 correctly
git config --global core.quotepath false
git config --global gui.encoding utf-8
git config --global i18n.commit.encoding utf-8
git config --global i18n.logoutputencoding utf-8
```

---

## Example 6: CI/CD Encoding Check

### GitHub Actions Workflow
```yaml
name: Encoding Check

on: [push]

jobs:
  check-encoding:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Check for BOM
        shell: pwsh
        run: |
          $files = Get-ChildItem *.md -Recurse
          foreach ($f in $files) {
            $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
            if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
              Write-Error "BOM detected: $($f.FullName)"
              exit 1
            }
          }
      
      - name: Check for Mojibake
        shell: pwsh
        run: |
          $patterns = @('浠', '姟', '鍚', '鈫', '鉁')
          $files = Get-ChildItem *.md -Recurse
          foreach ($f in $files) {
            $content = Get-Content $f.FullName -Raw
            foreach ($p in $patterns) {
              if ($content -match [regex]::Escape($p)) {
                Write-Error "Mojibake detected: $($f.FullName)"
                exit 1
              }
            }
          }
```

---

## Example 7: VS Code Settings

### settings.json
```json
{
    "files.encoding": "utf8",
    "files.autoGuessEncoding": false,
    "files.eol": "\n",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.trimFinalNewlines": true
}
```

### .editorconfig
```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

---

## Quick Command Reference

| Task | Command |
|------|---------|
| Detect encoding | `Test-FileEncoding -Path file.md` |
| Scan mojibake | `Find-MojibakeFiles -Path "."` |
| Convert single | `Convert-ToUTF8NoBOM -Path file.md -SourceEncoding GBK` |
| Convert batch | `Convert-DirectoryToUTF8 -Path "." -SourceEncoding GBK` |
| Verify fix | `Test-EncodingFix -Path file.md` |
| Set terminal | `chcp 65001` |
| Remove BOM | `$content.TrimStart([char]0xFEFF) \| Out-File file.md -Encoding UTF8NoBOM` |

---

**Copy, paste, fix.**
