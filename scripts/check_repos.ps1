[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")
try {
    $profileHtml = $wc.DownloadString("https://github.com/saifullahkhatri99-blip?tab=repositories")
    $repoMatches = [regex]::Matches($profileHtml, '(?i)itemprop="name codeRepository"[^>]*>\s*([a-zA-Z0-9\.\-_]+)')
    Write-Host "Public repositories found on saifullahkhatri99-blip:"
    foreach ($m in $repoMatches) {
        Write-Host "  -> $($m.Groups[1].Value.Trim())"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
