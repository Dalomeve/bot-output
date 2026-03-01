param(
  [string]$DistRoot = "$env:APPDATA\npm\node_modules\openclaw\dist",
  [string]$BackupSuffix = ".bak-vpn-skill",
  [switch]$ForceReinstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $DistRoot)) {
  throw "OpenClaw dist path not found: $DistRoot"
}

$backups = Get-ChildItem -Path $DistRoot -Recurse -File -Filter "*$BackupSuffix" -ErrorAction SilentlyContinue
$restored = @()

foreach ($bak in $backups) {
  $target = $bak.FullName.Substring(0, $bak.FullName.Length - $BackupSuffix.Length)
  Copy-Item -LiteralPath $bak.FullName -Destination $target -Force
  $restored += $target
}

if ($restored.Count -eq 0 -or $ForceReinstall) {
  & npm install -g openclaw@latest
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to reinstall openclaw."
  }
}

[pscustomobject]@{
  restored_count = $restored.Count
  restored_files = $restored
  reinstalled = ($restored.Count -eq 0 -or $ForceReinstall.IsPresent)
} | ConvertTo-Json -Depth 5
