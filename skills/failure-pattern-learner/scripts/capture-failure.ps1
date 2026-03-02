[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)] [string]$Root,
  [Parameter(Mandatory=$true)] [string]$TaskId,
  [Parameter(Mandatory=$true)] [string]$ErrorText,
  [string]$Context = "",
  [string]$Tool = "unknown"
)

$ErrorActionPreference = 'Stop'
$eventsDir = Join-Path $Root 'memory/failure-events'
New-Item -ItemType Directory -Force -Path $eventsDir | Out-Null

function Normalize-Signature([string]$text) {
  $s = $text.ToLowerInvariant()
  $s = [regex]::Replace($s, 'https?://\S+', '<url>')
  $s = [regex]::Replace($s, '[a-z]:\\[^\s\"]+', '<path>')
  $s = [regex]::Replace($s, '\b\d{3,}\b', '<num>')
  $s = [regex]::Replace($s, '\s+', ' ').Trim()
  return $s
}

function Classify-Failure([string]$text) {
  $t = $text.ToLowerInvariant()
  if ($t -match 'tool not found|session.*lock|jsonl\.lock|lock timeout|registry') { return 'session_or_tool_registry' }
  if ($t -match 'token|unauthorized|401|403|auth') { return 'auth_or_token' }
  if ($t -match 'encoding|mojibake|garbled|\ufffd|gbk|utf-8') { return 'encoding' }
  if ($t -match 'timeout|timed out|1006|handshake|network|dns') { return 'network' }
  if ($t -match 'file not found|path|no such file|workspace') { return 'path_or_fs' }
  if ($t -match 'powershell|cmdlet|parameter|argument') { return 'shell_syntax' }
  return 'unknown'
}

$sig = Normalize-Signature $ErrorText
$hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($sig))
$hash = -join ($hashBytes | ForEach-Object { $_.ToString('x2') })
$lessonId = $hash.Substring(0,12)

$event = [ordered]@{
  timestamp = (Get-Date).ToString('o')
  task_id = $TaskId
  tool = $Tool
  failure_class = (Classify-Failure $ErrorText)
  signature = $sig
  lesson_id = $lessonId
  error_text = $ErrorText
  context = $Context
}

$file = Join-Path $eventsDir ((Get-Date).ToString('yyyy-MM-dd') + '.jsonl')
($event | ConvertTo-Json -Compress) | Add-Content -Path $file -Encoding utf8

[pscustomobject]@{
  EventFile = $file
  LessonId = $lessonId
  FailureClass = $event.failure_class
  Signature = $sig
} | Format-List
