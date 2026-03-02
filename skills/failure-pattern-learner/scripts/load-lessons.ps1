[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)] [string]$Root,
  [Parameter(Mandatory=$true)] [string]$Query
)

$ErrorActionPreference = 'Stop'
$playbook = Join-Path $Root 'memory/failure-playbook.md'
if (-not (Test-Path $playbook)) {
  Write-Output 'LESSONS_MATCHED: 0'
  exit 0
}

$q = [regex]::Matches($Query.ToLowerInvariant(), '[a-z0-9_\\-]{3,}') | ForEach-Object { $_.Value }
if ($q.Count -eq 0) {
  Write-Output 'LESSONS_MATCHED: 0'
  exit 0
}
$content = Get-Content -Raw $playbook
$sections = ($content -split '(?m)^## ').Where({$_ -ne ''})
$matched = @()
foreach ($s in $sections) {
  $text = $s.ToLowerInvariant()
  foreach ($k in $q) {
    if ($text -like "*${k}*") { $matched += $s; break }
  }
}

Write-Output ('LESSONS_MATCHED: ' + $matched.Count)
if ($matched.Count -gt 0) {
  "`n--- MATCHED LESSONS ---"
  $matched | Select-Object -First 5 | ForEach-Object { '## ' + $_.Trim() }
}
