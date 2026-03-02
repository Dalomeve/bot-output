[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)] [string]$Root,
  [int]$MinCount = 2
)

$ErrorActionPreference = 'Stop'
$eventsDir = Join-Path $Root 'memory/failure-events'
$playbook = Join-Path $Root 'memory/failure-playbook.md'

if (-not (Test-Path $eventsDir)) {
  "# Failure Playbook`n`nNo events yet." | Set-Content -Path $playbook -Encoding utf8
  Write-Output "PLAYBOOK_CREATED_EMPTY: $playbook"
  exit 0
}

$events = @()
Get-ChildItem -Path $eventsDir -Filter *.jsonl -File | ForEach-Object {
  Get-Content $_.FullName | ForEach-Object {
    if (-not [string]::IsNullOrWhiteSpace($_)) {
      try { $events += ($_ | ConvertFrom-Json) } catch {}
    }
  }
}

if ($events.Count -eq 0) {
  "# Failure Playbook`n`nNo events yet." | Set-Content -Path $playbook -Encoding utf8
  Write-Output "PLAYBOOK_CREATED_EMPTY: $playbook"
  exit 0
}

$groups = $events | Group-Object lesson_id | Sort-Object Count -Descending
$classGroups = $events | Group-Object failure_class | Sort-Object Count -Descending
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Failure Playbook') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | Out-Null
$lines.Add('') | Out-Null

foreach ($g in $groups) {
  if ($g.Count -lt $MinCount) { continue }
  $sample = $g.Group[0]
  $rule = switch ($sample.failure_class) {
    'auth_or_token' { 'Verify active config source, token scope, and endpoint consistency before retry.' }
    'encoding' { 'Run output-encoding-gate and enforce UTF-8 console/profile settings before artifact generation.' }
    'network' { 'Check connectivity and proxy/no_proxy, then retry with reduced scope and explicit timeout.' }
    'path_or_fs' { 'Normalize paths and ensure workspace-safe paths before edit/write operations.' }
    'session_or_tool_registry' { 'Detect lock/tool registry corruption; recover session before new tool calls.' }
    'shell_syntax' { 'Switch to native shell syntax for current platform and re-run minimal command.' }
    default { 'Apply minimal reproducible retry and capture more context before escalation.' }
  }
  $lines.Add('## LESSON-' + $sample.lesson_id) | Out-Null
  $lines.Add('- count: ' + $g.Count) | Out-Null
  $lines.Add('- class: ' + $sample.failure_class) | Out-Null
  $lines.Add('- signature: ' + $sample.signature) | Out-Null
  $lines.Add('- action: ' + $rule) | Out-Null
  $lines.Add('') | Out-Null
}

foreach ($cg in $classGroups) {
  if ($cg.Count -lt $MinCount) { continue }
  $class = $cg.Name
  $rule = switch ($class) {
    'auth_or_token' { 'Before retry, verify active config source, token scope, and endpoint consistency.' }
    'encoding' { 'Run output-encoding-gate and enforce UTF-8 console/profile settings before artifact generation.' }
    'network' { 'Check connectivity and proxy/no_proxy, then retry with reduced scope and explicit timeout.' }
    'path_or_fs' { 'Normalize paths and validate workspace-safe target before edit/write operations.' }
    'session_or_tool_registry' { 'Detect lock/tool registry corruption first, recover session, then retry tool calls.' }
    'shell_syntax' { 'Switch to native shell syntax for current platform and rerun minimal command.' }
    default { 'Apply minimal reproducible retry and capture more context before escalation.' }
  }
  $lines.Add('## CLASS-' + $class) | Out-Null
  $lines.Add('- count: ' + $cg.Count) | Out-Null
  $lines.Add('- action: ' + $rule) | Out-Null
  $lines.Add('') | Out-Null
}

if ($lines.Count -le 4) {
  $lines.Add('No repeated patterns above threshold.') | Out-Null
}

$lines | Set-Content -Path $playbook -Encoding utf8
Write-Output "PLAYBOOK_UPDATED: $playbook"
