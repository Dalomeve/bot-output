param(
  [string]$ProxyUrl = "http://127.0.0.1:7899",
  [string]$DistRoot = "$env:APPDATA\npm\node_modules\openclaw\dist",
  [string]$BackupSuffix = ".bak-vpn-skill"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $DistRoot)) {
  throw "OpenClaw dist path not found: $DistRoot"
}

function Ensure-HttpsProxyAgent {
  & npm ls -g https-proxy-agent --depth=0 1>$null 2>$null
  if ($LASTEXITCODE -ne 0) {
    & npm install -g https-proxy-agent
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to install https-proxy-agent globally."
    }
  }
}

function Patch-File {
  param(
    [string]$Path,
    [string]$Proxy
  )

  $raw = Get-Content $Path -Raw
  $original = $raw

  if ($raw -notmatch 'import \{ HttpsProxyAgent \} from "https-proxy-agent";') {
    $raw = $raw.Replace(
      'import qrcode from "qrcode-terminal";',
      "import qrcode from `"qrcode-terminal`";`r`nimport { HttpsProxyAgent } from `"https-proxy-agent`";"
    )
  }

  if ($raw -notmatch 'OPENCLAW_WHATSAPP_PROXY') {
    $inject = @"
const { version } = await fetchLatestBaileysVersion();
	const proxyUrl = process.env.OPENCLAW_WHATSAPP_PROXY ?? process.env.HTTPS_PROXY ?? process.env.HTTP_PROXY ?? process.env.ALL_PROXY ?? "$Proxy";
	const wsAgent = proxyUrl ? new HttpsProxyAgent(proxyUrl) : void 0;
"@
    $raw = $raw.Replace('const { version } = await fetchLatestBaileysVersion();', $inject.TrimEnd("`r", "`n"))
  }

  if ($raw -notmatch 'agent:\s*wsAgent') {
    $raw = $raw -replace "(\s+version,\r?\n\s+logger,)", "`$1`r`n`t`tagent: wsAgent,"
    $raw = $raw -replace "version,\r?\n\t\tagent: wsAgent,\r?\n\t\tlogger,", "version,`r`n`t`tagent: wsAgent,`r`n`t`tlogger,"
  }

  if ($raw -ne $original) {
    $backup = "$Path$BackupSuffix"
    if (-not (Test-Path $backup)) {
      Copy-Item -LiteralPath $Path -Destination $backup -Force
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $raw, $utf8NoBom)
    return $true
  }

  return $false
}

Ensure-HttpsProxyAgent

$targets = @()
$targets += Get-ChildItem -Path $DistRoot -Filter "session-*.js" -File -ErrorAction SilentlyContinue
$pluginSdk = Join-Path $DistRoot "plugin-sdk"
if (Test-Path $pluginSdk) {
  $targets += Get-ChildItem -Path $pluginSdk -Filter "session-*.js" -File -ErrorAction SilentlyContinue
}

if ($targets.Count -eq 0) {
  throw "No session-*.js files found under $DistRoot"
}

$patched = @()
foreach ($file in $targets) {
  if (Patch-File -Path $file.FullName -Proxy $ProxyUrl) {
    $patched += $file.FullName
  }
}

foreach ($file in $targets) {
  & node --check $file.FullName
  if ($LASTEXITCODE -ne 0) {
    throw "Syntax check failed: $($file.FullName)"
  }
}

[pscustomobject]@{
  dist_root = $DistRoot
  proxy_url = $ProxyUrl
  patched_count = $patched.Count
  patched_files = $patched
} | ConvertTo-Json -Depth 5
