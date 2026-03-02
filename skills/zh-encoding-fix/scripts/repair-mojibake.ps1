[CmdletBinding()]
param(
  [Parameter(Position=0)]
  [string]$Root = (Get-Location).Path,
  [switch]$Recurse = $true,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$enc936 = [System.Text.Encoding]::GetEncoding(936)
$encUtf8 = New-Object System.Text.UTF8Encoding($false)
$marker = '(\uFFFD|\u951B|\u951F|\u9225|\u9983|\u00C3[A-Za-z0-9]|\u00C2[ -~]|\u00E2[ -~]|\u00F0\u0178)'
$mixedLatinCjk = '(?=.*[A-Za-z]{3,})(?=.*[\u4E00-\u9FFF]).+'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Get-IssueCount([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return 9999 }
  $bad = ([regex]::Matches($s, $marker)).Count
  if ([regex]::IsMatch($s, $mixedLatinCjk)) { $bad += 1 }
  return $bad
}

function Get-Score([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return -9999 }
  $cjk = ([regex]::Matches($s, '[\u4E00-\u9FFF]')).Count
  $ascii = ([regex]::Matches($s, '[A-Za-z0-9 .,;:!?#\-_/\\()\[\]{}]')).Count
  $bad = Get-IssueCount $s
  $mixedPenalty = 0
  if ([regex]::IsMatch($s, $mixedLatinCjk)) { $mixedPenalty = 20 }
  return ($cjk * 2) + $ascii - ($bad * 10) - $mixedPenalty
}

$files = Get-ChildItem -Path $Root -File -Include *.md,*.txt,*.json -Recurse:$Recurse
$scanned = 0
$detected = 0
$wouldRepair = 0
$repaired = 0
$backups = @()

foreach ($f in $files) {
  if ($f.FullName -match '\\zh-encoding-fix\\') { continue }
  $scanned++
  $raw = [System.IO.File]::ReadAllText($f.FullName)
  if (-not [regex]::IsMatch($raw, $marker) -and -not [regex]::IsMatch($raw, $mixedLatinCjk)) { continue }

  $detected++
  $lines = $raw -split "`r?`n", -1
  $changed = $false
  $newLines = New-Object System.Collections.Generic.List[string]

  foreach ($line in $lines) {
    $origScore = Get-Score $line
    $candidate = $line
    try {
      $bytes = $enc936.GetBytes($line)
      $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
      $candScore = Get-Score $decoded
      $origBad = Get-IssueCount $line
      $candBad = Get-IssueCount $decoded
      if ($candScore -gt $origScore -and $candBad -le $origBad) {
        $candidate = $decoded
      }
    } catch {
      $candidate = $line
    }

    if ($candidate -ne $line) { $changed = $true }
    $newLines.Add($candidate) | Out-Null
  }

  if ($changed) {
    $wouldRepair++
    $backup = "$($f.FullName).bak.$timestamp"
    if (-not $DryRun) {
      Copy-Item -LiteralPath $f.FullName -Destination $backup -Force
      [System.IO.File]::WriteAllText($f.FullName, ($newLines -join "`n"), $encUtf8)
      $backups += $backup
      $repaired++
    }
  }
}

$residual = (Get-ChildItem -Path $Root -File -Include *.md,*.txt,*.json -Recurse:$Recurse |
  Select-String -Pattern $marker -AllMatches -CaseSensitive | Measure-Object).Count

[pscustomobject]@{
  Root = $Root
  DryRun = [bool]$DryRun
  FilesScanned = $scanned
  CorruptedFilesDetected = $detected
  FilesWouldRepair = $wouldRepair
  FilesRepaired = $repaired
  BackupsCreated = $backups.Count
  ResidualMarkers = $residual
  BackupExamples = ($backups | Select-Object -First 5) -join '; '
} | Format-List
