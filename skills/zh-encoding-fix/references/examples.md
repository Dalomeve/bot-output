# zh-encoding-fix Examples (ASCII-safe)

This file contains usage examples without embedding raw mojibake glyphs.
Use escaped markers and test fixtures to reproduce issues safely.

## Example 1: Single File Conversion (CP936 -> UTF-8)

```powershell
# Convert one file from CP936 (GBK) to UTF-8 without BOM
$src = "./sample.md"
$text = [System.IO.File]::ReadAllText($src, [System.Text.Encoding]::GetEncoding(936))
[System.IO.File]::WriteAllText($src, $text, [System.Text.UTF8Encoding]::new($false))
```

## Example 2: Batch Conversion with Backup

```powershell
Get-ChildItem -Recurse -File -Include *.md,*.txt,*.json | ForEach-Object {
  $path = $_.FullName
  Copy-Item $path "$path.bak" -Force
  $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(936))
  [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
}
```

## Example 3: Mojibake Scan Gate

```powershell
$patterns = @(
  '\uFFFD',
  '\u6D60',
  '\u59DF',
  '\u935A',
  '\u95B3',
  '\u95B4',
  '\u922B',
  '\u9241'
)

Get-ChildItem -Recurse -File -Include *.md,*.txt,*.json | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  foreach ($m in $patterns) {
    if ($content -match [regex]::Escape($m)) {
      Write-Host "Mojibake marker found in: $($_.FullName)"
      break
    }
  }
}
```

## Example 4: CI Check

```yaml
name: encoding-check

on: [push, pull_request]

jobs:
  verify:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify UTF-8 and marker-free docs
        shell: pwsh
        run: |
          $patterns = @('\\uFFFD','\\u6D60','\\u59DF','\\u935A','\\u95B3','\\u95B4','\\u922B','\\u9241')
          $files = Get-ChildItem -Recurse -File -Include *.md,*.txt,*.json
          foreach ($f in $files) {
            $content = Get-Content $f.FullName -Raw
            foreach ($p in $patterns) {
              if ($content -match [regex]::Escape($p)) {
                Write-Error "Mojibake marker found: $($f.FullName)"
                exit 1
              }
            }
          }
```

## Example 5: Safe Reporting

When documenting incidents, do not paste raw corrupted glyphs directly.
Prefer:
- marker labels (`M1`, `M2`)
- unicode escapes (`\\uXXXX`)
- before/after hashes
