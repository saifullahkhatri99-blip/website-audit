[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

$pages = @(
    "/",
    "/countries/pakistan/karachi/",
    "/quran/",
    "/duas/ablution/",
    "/zakat-calculator/",
    "/qibla-finder/",
    "/special-islamic-days/ramadan-2027/",
    "/sahih-bukhari/",
    "/blog/how-prayer-times-are-calculated/",
    "/forum/"
)

Write-Host "=========================================="
Write-Host "DEEP SCHEMA EXTRACTION & OPPORTUNITY AUDIT"
Write-Host "=========================================="

foreach ($p in $pages) {
    $url = "$stagingBase$p"
    Write-Host "`n========================================================"
    Write-Host "PAGE: $p"
    Write-Host "========================================================"
    try {
        $html = $wc.DownloadString($url)
        $schemaPattern = '(?is)<script\s+type=["'']application/ld\+json["'']>(.*?)</script>'
        $matches = [regex]::Matches($html, $schemaPattern)
        Write-Host "Found $($matches.Count) JSON-LD blocks."
        foreach ($m in $matches) {
            $jsonStr = $m.Groups[1].Value.Trim()
            Write-Host $jsonStr
        }
    } catch {
        Write-Host "Error fetching $($p): $($_.Exception.Message)"
    }
}
