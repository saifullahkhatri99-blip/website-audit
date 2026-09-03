[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
try {
    $html = $wc.DownloadString("https://github.com/saifullahkhatri99-blip/website-audit")
    $fileMatches = [regex]::Matches($html, '(?i)class="react-directory-truncate"[^>]*>.*?<a[^>]*title="([^"]+)"')
    Write-Host "Files found in https://github.com/saifullahkhatri99-blip/website-audit:"
    foreach ($m in $fileMatches) {
        Write-Host "  -> $($m.Groups[1].Value)"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
