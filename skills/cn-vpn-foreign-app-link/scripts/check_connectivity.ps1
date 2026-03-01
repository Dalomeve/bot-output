param(
  [string]$TargetHost = "web.whatsapp.com",
  [string]$ProxyUrl = "http://127.0.0.1:7899",
  [int]$TimeoutSec = 20
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-CurlHead {
  param(
    [string]$Url,
    [string]$Proxy,
    [int]$Timeout
  )

  try {
    if ([string]::IsNullOrWhiteSpace($Proxy)) {
      Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec $Timeout -UseBasicParsing | Out-Null
    } else {
      Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec $Timeout -Proxy $Proxy -UseBasicParsing | Out-Null
    }
    return $true
  } catch {
    return $false
  }
}

$url = "https://$TargetHost"
$directOk = Test-CurlHead -Url $url -Timeout $TimeoutSec
$proxyOk = Test-CurlHead -Url $url -Proxy $ProxyUrl -Timeout $TimeoutSec

$advice = if ($directOk) {
  "Direct path works. Do not patch OpenClaw runtime."
} elseif ($proxyOk) {
  "Proxy path works while direct fails. Apply network-level route or runtime proxy patch."
} else {
  "Both direct and proxy checks failed. Fix VPN/proxy first."
}

[pscustomobject]@{
  timestamp = (Get-Date).ToString("s")
  host = $TargetHost
  proxy_url = $ProxyUrl
  direct_ok = $directOk
  proxy_ok = $proxyOk
  advice = $advice
} | ConvertTo-Json -Depth 5
