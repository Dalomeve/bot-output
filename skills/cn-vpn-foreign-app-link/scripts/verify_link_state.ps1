param(
  [string]$Channel = "WhatsApp"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$status = & openclaw status
if ($LASTEXITCODE -ne 0) {
  throw "openclaw status failed."
}

$line = ($status | Select-String -Pattern $Channel | Select-Object -First 1).Line
$notLinked = $false
if ($line) {
  $notLinked = ($line -match "Not linked")
}

[pscustomobject]@{
  channel = $Channel
  status_line = $line
  linked = (-not $notLinked -and [string]::IsNullOrWhiteSpace($line) -eq $false)
} | ConvertTo-Json -Depth 5
