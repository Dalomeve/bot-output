[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Root,
  [switch]$Fix
)

$ErrorActionPreference = 'Stop'
$repair = 'C:\Users\davemelo\.openclaw\workspace\skills\local\zh-encoding-fix\scripts\repair-mojibake.ps1'
$pattern = '(\uFFFD|\u951B|\u951F|\u9225|\u9983|\u00C3[A-Za-z0-9]|\u00C2[ -~]|\u00E2[ -~]|\u00F0\u0178|鈫\?|脳|鉁\??|鈴\??)'

if (-not (Test-Path $Root)) {
  throw "Root not found: $Root"
}

$files = Get-ChildItem -Path $Root -Recurse -File -Include *.md,*.txt,*.json
$hits = @()
foreach ($f in $files) {
  $lineNo = 0
  foreach ($line in [System.IO.File]::ReadLines($f.FullName)) {
    $lineNo++
    if ([regex]::IsMatch($line, $pattern)) {
      $hits += [pscustomobject]@{
        Path = $f.FullName
        LineNumber = $lineNo
        Line = $line
      }
    }
  }
}

$fixedFiles = 0
$backupCount = 0

if ($Fix -and $hits.Count -gt 0) {
  if (-not (Test-Path $repair)) {
    throw "Repair script not found: $repair"
  }
  $result = & $repair -Root $Root | Out-String
  $fixedMatch = [regex]::Match($result, 'FilesRepaired\s*:\s*(\d+)')
  $bakMatch = [regex]::Match($result, 'BackupsCreated\s*:\s*(\d+)')
  if ($fixedMatch.Success) { $fixedFiles = [int]$fixedMatch.Groups[1].Value }
  if ($bakMatch.Success) { $backupCount = [int]$bakMatch.Groups[1].Value }

  $hits = @()
  foreach ($f in $files) {
    $lineNo = 0
    foreach ($line in [System.IO.File]::ReadLines($f.FullName)) {
      $lineNo++
      if ([regex]::IsMatch($line, $pattern)) {
        $hits += [pscustomobject]@{
          Path = $f.FullName
          LineNumber = $lineNo
          Line = $line
        }
      }
    }
  }
}

$resultObj = [pscustomobject]@{
  Root = $Root
  ScannedFiles = $files.Count
  MarkerCount = $hits.Count
  FixedFiles = $fixedFiles
  BackupCount = $backupCount
  Result = if ($hits.Count -eq 0) { 'PASS' } else { 'FAIL' }
}

$resultObj | Format-List

if ($hits.Count -gt 0) {
  Write-Host "\nFirst marker hits:" -ForegroundColor Yellow
  $hits | Select-Object -First 10 Path,LineNumber,Line | Format-Table -AutoSize
  exit 2
}
