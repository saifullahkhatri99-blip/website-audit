[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

Write-Host "=========================================="
Write-Host "INSPECTING SITEMAP FILES CONTENT"
Write-Host "=========================================="

$blogSmUrl = "$stagingBase/blog-sitemap.xml"
try {
    $c = $wc.DownloadString($blogSmUrl)
    Write-Host "blog-sitemap.xml Content:`n"
    Write-Host $c
} catch {
    Write-Host "Error fetching blog-sitemap.xml: $($_.Exception.Message)"
}

$forumSmUrl = "$stagingBase/forum-sitemap.xml"
try {
    $c2 = $wc.DownloadString($forumSmUrl)
    Write-Host "`nforum-sitemap.xml Content:`n"
    Write-Host $c2
} catch {
    Write-Host "Error fetching forum-sitemap.xml: $($_.Exception.Message)"
}
