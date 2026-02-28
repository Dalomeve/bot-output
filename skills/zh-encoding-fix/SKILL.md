---
name: zh-encoding-fix
version: 1.0.0
description: Diagnose and fix Chinese garbled text (mojibake) in files. Covers UTF-8/GBK/BOM detection, PowerShell encoding, and batch repair workflows.
---

# Chinese Garbled Text Fix

Diagnose and fix Chinese mojibake (乱码) in files. Handles UTF-8/GBK/BOM detection, PowerShell encoding issues, and terminal code page problems.

## Why This Exists

**Problem**: Chinese text appears as garbled characters like:
- `浠诲姟` (UTF-8 read as GBK)
- `鈫?` (arrow symbol mojibake)
- `鉁?` (checkmark mojibake)
- `ï»¿` (BOM artifacts)

**Root Causes**:
1. File saved as UTF-8-BOM but read as UTF-8
2. File saved as GBK but read as UTF-8
3. PowerShell default encoding mismatch
4. Terminal code page (chcp) mismatch

## Diagnosis

### 1. Identify Mojibake Patterns

| Garbled Text | Likely Cause | Actual Encoding |
|--------------|--------------|-----------------|
| `浠诲姟` | UTF-8 read as GBK | UTF-8 |
| `鈫?` | Emoji/symbol as UTF-8 | UTF-8 |
| `鉁?` | Emoji/symbol as UTF-8 | UTF-8 |
| `ï»¿` | BOM not stripped | UTF-8-BOM |
| `` | GBK read as UTF-8 | GBK/GB2312 |

### 2. Detect File Encoding

```powershell
# Method 1: Check for BOM
function Test-FileEncoding {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    
    # Check BOM
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return "UTF-8-BOM"
    }
    if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return "UTF-16-LE"
    }
    if ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return "UTF-16-BE"
    }
    
    # Try to detect by content
    $content = Get-Content $Path -Raw
    if ($content -match '[\u4e00-\u9fff]') {
        return "Contains Chinese (likely UTF-8 or GBK)"
    }
    
    return "Unknown (ASCII or detected as such)"
}

# Usage
Test-FileEncoding -Path "file.md"
```

```powershell
# Method 2: Compare byte patterns
function Get-EncodingHint {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    
    # UTF-8 BOM: EF BB BF
    if ($bytes.Length -ge 3 -and 
        $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Host "UTF-8 with BOM" -ForegroundColor Yellow
        return "UTF-8-BOM"
    }
    
    # UTF-8 no BOM
    $content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    if ($content -match '[\u4e00-\u9fff]') {
        Write-Host "UTF-8 (Chinese detected)" -ForegroundColor Green
        return "UTF-8"
    }
    
    # Try GBK
    $gbk = [System.Text.Encoding]::GetEncoding(936)
    $content = [System.IO.File]::ReadAllText($Path, $gbk)
    if ($content -match '[\u4e00-\u9fff]') {
        Write-Host "GBK/GB2312 (Chinese detected)" -ForegroundColor Cyan
        return "GBK"
    }
    
    Write-Host "Unknown encoding" -ForegroundColor Red
    return "Unknown"
}
```

### 3. Scan Directory for Mojibake

```powershell
function Find-MojibakeFiles {
    param(
        [string]$Path = ".",
        [string[]]$Extensions = @("*.md", "*.txt", "*.py", "*.json")
    )
    
    $mojibakePatterns = @(
        '浠', '姟', '鍚', '姩', '鈫', '鉁', 'ï»', '¿', ''
    )
    
    $files = Get-ChildItem -Path $Path -Include $Extensions -Recurse -File
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        foreach ($pattern in $mojibakePatterns) {
            if ($content -match [regex]::Escape($pattern)) {
                Write-Host "[MOJIBAKE] $($file.FullName)" -ForegroundColor Yellow
                Write-Host "  Pattern: $pattern" -ForegroundColor Gray
                break
            }
        }
    }
}

# Usage
Find-MojibakeFiles -Path "." -Extensions @("*.md", "*.txt")
```

## Fix Workflow

### Step 1: Backup Original Files

```powershell
# Backup before conversion
function Backup-Files {
    param([string[]]$Paths)
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    foreach ($path in $Paths) {
        $backup = "$path.bak.$timestamp"
        Copy-Item $path $backup
        Write-Host "Backed up: $backup"
    }
}
```

### Step 2: Convert to UTF-8 (No BOM)

```powershell
function Convert-ToUTF8NoBOM {
    param(
        [string]$Path,
        [string]$SourceEncoding = "GBK"
    )
    
    # Read with source encoding
    $sourceEnc = [System.Text.Encoding]::GetEncoding($SourceEncoding)
    $content = [System.IO.File]::ReadAllText($Path, $sourceEnc)
    
    # Write as UTF-8 without BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $content, $utf8NoBom)
    
    Write-Host "Converted: $Path (from $SourceEncoding to UTF-8 no BOM)"
}

# Usage for single file
Convert-ToUTF8NoBOM -Path "file.md" -SourceEncoding "GBK"
```

```powershell
# Batch convert all MD files
function Convert-DirectoryToUTF8 {
    param(
        [string]$Path = ".",
        [string]$SourceEncoding = "GBK",
        [switch]$WhatIf
    )
    
    $files = Get-ChildItem -Path $Path -Include "*.md", "*.txt" -Recurse -File
    
    foreach ($file in $files) {
        if ($WhatIf) {
            Write-Host "[DRY RUN] Would convert: $($file.FullName)"
            continue
        }
        
        try {
            Convert-ToUTF8NoBOM -Path $file.FullName -SourceEncoding $SourceEncoding
        } catch {
            Write-Host "[ERROR] Failed: $($file.FullName) - $_" -ForegroundColor Red
        }
    }
}

# Usage (dry run first!)
Convert-DirectoryToUTF8 -Path "." -SourceEncoding "GBK" -WhatIf
Convert-DirectoryToUTF8 -Path "." -SourceEncoding "GBK"
```

### Step 3: Fix PowerShell Read/Write

```powershell
# Always specify encoding explicitly
# Wrong (uses system default):
$content = Get-Content file.md
$content | Out-File file.md

# Right (explicit UTF-8):
$content = Get-Content file.md -Encoding UTF8
$content | Out-File file.md -Encoding UTF8 -NoNewline

# Or use -Encoding UTF8NoBOM (PowerShell 6+)
$content = Get-Content file.md -Encoding UTF8
$content | Out-File file.md -Encoding UTF8NoBOM
```

### Step 4: Fix Terminal Code Page

```powershell
# Check current code page
chcp

# Set to UTF-8 (65001) before running scripts
chcp 65001

# Add to PowerShell profile for persistence
Add-Content $PROFILE "`nchcp 65001  # Set UTF-8 code page"
```

## Verification

### Before/After Comparison

```powershell
function Compare-EncodingFix {
    param(
        [string]$OriginalPath,
        [string]$FixedPath
    )
    
    Write-Host "=== Before (Original) ===" -ForegroundColor Yellow
    Get-Content $OriginalPath -Encoding UTF8 | Select-Object -First 5
    
    Write-Host "`n=== After (Fixed) ===" -ForegroundColor Green
    Get-Content $FixedPath -Encoding UTF8 | Select-Object -First 5
    
    # Check for Chinese characters
    $content = Get-Content $FixedPath -Raw
    $chineseCount = ([regex]::Matches($content, '[\u4e00-\u9fff]')).Count
    Write-Host "`nChinese characters detected: $chineseCount" -ForegroundColor Cyan
}
```

### Validation Checklist

```powershell
function Test-EncodingFix {
    param([string]$Path)
    
    $results = @{
        "No BOM" = $false
        "UTF-8 Valid" = $false
        "Chinese Readable" = $false
        "No Mojibake" = $false
    }
    
    # Check BOM
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 3 -or 
        !($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)) {
        $results["No BOM"] = $true
    }
    
    # Check UTF-8 validity
    try {
        $content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
        $results["UTF-8 Valid"] = $true
    } catch {
        $results["UTF-8 Valid"] = $false
    }
    
    # Check Chinese readable
    if ($content -match '[\u4e00-\u9fff]') {
        $results["Chinese Readable"] = $true
    }
    
    # Check no mojibake patterns
    $mojibake = @('浠', '姟', '鍚', '鈫', '鉁', 'ï»')
    $hasMojibake = $false
    foreach ($m in $mojibake) {
        if ($content -match [regex]::Escape($m)) {
            $hasMojibake = $true
            break
        }
    }
    $results["No Mojibake"] = !$hasMojibake
    
    # Output results
    Write-Host "`n=== Encoding Fix Validation ===" -ForegroundColor Cyan
    foreach ($key in $results.Keys) {
        $status = if ($results[$key]) { "[OK]" } else { "[FAIL]" }
        $color = if ($results[$key]) { "Green" } else { "Red" }
        Write-Host "  $status $key" -ForegroundColor $color
    }
    
    $allPass = ($results.Values | Where-Object { $_ }) -eq $true | Measure-Object | Select-Object -ExpandProperty Count
    if ($allPass -eq 4) {
        Write-Host "`n[PASS] All checks passed!" -ForegroundColor Green
    } else {
        Write-Host "`n[FAIL] Some checks failed!" -ForegroundColor Red
    }
}

# Usage
Test-EncodingFix -Path "file.md"
```

## Prevention Rules

### Team Rules (Add to CONTRIBUTING.md)

```markdown
## Encoding Rules

1. **All text files must be UTF-8 without BOM**
   - Use `.editorconfig` to enforce
   - CI check for BOM presence

2. **PowerShell scripts must specify encoding**
   ```powershell
   Get-Content file.md -Encoding UTF8
   Out-File file.md -Encoding UTF8NoBOM
   ```

3. **Terminal must use UTF-8 code page**
   ```powershell
   chcp 65001  # Add to profile
   ```

4. **Git must handle encoding correctly**
   ```git
   [core]
       autocrlf = false
       safecrlf = false
   ```

5. **CI/CD must validate encoding**
   - Scan for BOM
   - Scan for mojibake patterns
   - Fail build if detected
```

### .editorconfig

```ini
# EditorConfig helps maintain consistent encoding
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

## Quick Reference

### One-Liner Fixes

```powershell
# Convert single file from GBK to UTF-8
$content = Get-Content file.md -Encoding Default; $content | Out-File file.md -Encoding UTF8NoBOM

# Remove BOM from file
$content = Get-Content file.md -Raw; $content.TrimStart([char]0xFEFF) | Out-File file.md -Encoding UTF8NoBOM

# Scan for mojibake in directory
Get-ChildItem *.md -Recurse | ForEach-Object { if ((Get-Content $_.FullName -Raw) -match '浠|姟|鈫') { $_.FullName } }
```

### Common Patterns

| Garbled | Should Be | Fix |
|---------|-----------|-----|
| `浠诲姟` | 任务 | Re-encode GBK→UTF-8 |
| `鈫?` | → | Re-encode + fix emoji |
| `鉁?` | ✓ | Re-encode + fix emoji |
| `ï»¿` | (nothing) | Strip BOM |
| `` | 中文 | Re-encode GBK→UTF-8 |

## Privacy/Safety

- Always backup before conversion
- Use dry-run first (`-WhatIf`)
- Verify after conversion
- No external API calls needed

## Self-Use Trigger

Use when:
- Chinese text appears garbled in files
- After git clone shows mojibake
- PowerShell outputs weird characters
- CI/CD reports encoding issues
- Team members report display problems

---

**Fix encoding once. Prevent forever.**
