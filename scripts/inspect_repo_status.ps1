[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
try {
    $html = $wc.DownloadString("https://github.com/saifullahkhatri99-blip/website-audit")
    Write-Host "Page Title:"
    if ($html -match '(?i)<title>(.*?)</title>') { Write-Host "  $($matches[1].Trim())" }
    
    if ($html -match "Quick setup") {
        Write-Host "`nRepo Status: Repository is initialized and EMPTY (waiting for initial push)!"
    } else {
        Write-Host "`nRepo Status: Repository has existing commits/files!"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
