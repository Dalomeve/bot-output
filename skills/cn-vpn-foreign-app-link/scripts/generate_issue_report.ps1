param(
  [string]$OutFile = ".\openclaw-foreign-app-link-issue.md",
  [string]$TargetHost = "web.whatsapp.com",
  [string]$ProxyUrl = "http://127.0.0.1:7899"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$openclawVersion = (& openclaw --version) -join "`n"
$status = (& openclaw status) -join "`n"
$connectivity = (& powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\check_connectivity.ps1" -TargetHost $TargetHost -ProxyUrl $ProxyUrl) -join "`n"

$body = @"
## Summary
OpenClaw channel linking to foreign app fails in CN network and needs explicit proxy routing for websocket.

## Environment
- openclaw version: $openclawVersion
- host: $TargetHost
- proxy: $ProxyUrl

## Repro
1. Run: `openclaw channels login --channel whatsapp --verbose`
2. Observe timeout/handshake failure in CN network without full-route VPN.

## Connectivity Probe
```json
$connectivity
```

## Current Status
```text
$status
```

## Expected
OpenClaw should support stable proxy routing for channel websocket login without manual dist patching.
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$outDir = Split-Path -Parent $OutFile
if ([string]::IsNullOrWhiteSpace($outDir)) {
  $outDir = (Get-Location).Path
}
if (-not (Test-Path $outDir)) {
  New-Item -Path $outDir -ItemType Directory -Force | Out-Null
}
$resolvedFile = Join-Path $outDir (Split-Path -Leaf $OutFile)
[System.IO.File]::WriteAllText($resolvedFile, $body, $utf8NoBom)

Write-Output "Issue report written to: $resolvedFile"
