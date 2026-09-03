[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$baseUrl = "https://crmapi.designstime.com"
Write-Host "=========================================="
Write-Host "AUDITING TARGET: $baseUrl"
Write-Host "=========================================="

# 1. Server Headers Check
Write-Host "`n[1] Checking Server Headers..."
try {
    $req = [System.Net.HttpWebRequest]::Create($baseUrl)
    $req.AllowAutoRedirect = $true
    $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    $res = $req.GetResponse()
    Write-Host "HTTP Status: $($res.StatusCode) ($([int]$res.StatusCode))"
    Write-Host "Final Response URI: $($res.ResponseUri)"
    Write-Host "--- Headers ---"
    foreach ($key in $res.Headers.AllKeys) {
        Write-Host "$key : $($res.Headers[$key])"
    }
    $res.Close()
} catch {
    Write-Host "Error checking headers: $_"
}

# 2. Check Security Headers Specifically
Write-Host "`n[2] Checking Security Headers..."
$securityHeaders = @(
    "Strict-Transport-Security",
    "Content-Security-Policy",
    "X-Content-Type-Options",
    "X-Frame-Options",
    "X-XSS-Protection",
    "Referrer-Policy",
    "Permissions-Policy"
)
try {
    $req = [System.Net.HttpWebRequest]::Create($baseUrl)
    $res = $req.GetResponse()
    foreach ($sh in $securityHeaders) {
        $val = $res.Headers[$sh]
        if ($val) {
            Write-Host "[PRESENT] $($sh): $val" -ForegroundColor Green
        } else {
            Write-Host "[MISSING] $($sh)" -ForegroundColor Red
        }
    }
    $res.Close()
} catch {
    Write-Host "Security header error: $_"
}

# 3. Check robots.txt and sitemaps
Write-Host "`n[3] Checking Robots.txt..."
$robotsUrl = "$baseUrl/robots.txt"
try {
    $client = New-Object System.Net.WebClient
    $robotsTxt = $client.DownloadString($robotsUrl)
    Write-Host "Robots.txt Content:`n$robotsTxt"
} catch {
    Write-Host "[ERROR/MISSING] Robots.txt: $($_.Exception.Message)"
}

Write-Host "`n[4] Checking Sitemap.xml..."
$sitemapUrls = @(
    "$baseUrl/sitemap.xml",
    "$baseUrl/sitemap_index.xml",
    "$baseUrl/sitemap-index.xml"
)
foreach ($sm in $sitemapUrls) {
    try {
        $client = New-Object System.Net.WebClient
        $smContent = $client.DownloadString($sm)
        Write-Host "[FOUND] $sm (Length: $($smContent.Length) chars)"
        Write-Host "Preview: $($smContent.Substring(0, [Math]::Min(500, $smContent.Length)))"
    } catch {
        Write-Host "[NOT FOUND / ERROR] $sm : $($_.Exception.Message)"
    }
}

# 4. Check 404 response
Write-Host "`n[5] Checking 404 Custom Error Handling..."
$test404 = "$baseUrl/this-page-definitely-does-not-exist-test-404"
try {
    $req404 = [System.Net.HttpWebRequest]::Create($test404)
    $res404 = $req404.GetResponse()
    Write-Host "Status for non-existent page: $($res404.StatusCode) (WARNING: Soft 404 if 200 OK!)"
    $res404.Close()
} catch [System.Net.WebException] {
    $resp = $_.Exception.Response
    if ($resp) {
        Write-Host "Status for non-existent page: $($resp.StatusCode)"
    } else {
        Write-Host "WebException: $($_.Exception.Message)"
    }
}
