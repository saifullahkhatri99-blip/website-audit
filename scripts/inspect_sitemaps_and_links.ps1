[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$prodBase = "https://globalsalah.com"

Write-Host "=========================================="
Write-Host "INSPECTING ALL SUB-SITEMAPS AND URL STRUCTURES"
Write-Host "=========================================="

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")
$smContent = $wc.DownloadString("$stagingBase/sitemap.xml")
[xml]$smXml = $smContent

$sitemapList = @()
foreach ($sm in $smXml.sitemapindex.sitemap) {
    $sitemapList += $sm.loc
    Write-Host "Sitemap: $($sm.loc) (Lastmod: $($sm.lastmod))"
}

# Let's inspect pages-en-001.xml
$pagesEnUrl = "$stagingBase/sitemaps/pages-en-001.xml"
Write-Host "`nFetching $pagesEnUrl..."
try {
    $pagesContent = $wc.DownloadString($pagesEnUrl)
    [xml]$pagesXml = $pagesContent
    Write-Host "Found $($pagesXml.urlset.url.Count) URLs in pages-en-001.xml:"
    foreach ($u in $pagesXml.urlset.url) {
        Write-Host "  -> $($u.loc)"
    }
} catch {
    Write-Host "Error fetching pages-en: $_"
}

# Let's check Saudi Arabia cities in countries/cities sitemaps
$citiesEnUrl = "$stagingBase/sitemaps/cities-en-001.xml"
Write-Host "`nFetching $citiesEnUrl (sample 15 cities)..."
try {
    $citiesContent = $wc.DownloadString($citiesEnUrl)
    [xml]$citiesXml = $citiesContent
    Write-Host "Total cities in sitemap: $($citiesXml.urlset.url.Count)"
    $citiesXml.urlset.url | Where-Object { $_.loc -like "*saudi-arabia*" } | Select-Object -First 10 | ForEach-Object {
        Write-Host "  Saudi City: $($_.loc)"
    }
} catch {
    Write-Host "Error fetching cities-en: $_"
}

# Let's check Header & Footer links on Homepage
Write-Host "`nInspecting Homepage HTML for All Internal Links..."
$homeHtml = $wc.DownloadString("$stagingBase/")
$linkMatches = [regex]::Matches($homeHtml, '(?i)<a\b[^>]*href=["'']([^"'']+)["''][^>]*>')
$internalLinks = @()
foreach ($lm in $linkMatches) {
    $href = $lm.Groups[1].Value
    if ($href -notlike "http*" -and $href -notlike "#*" -and $href -notlike "mailto*" -and $href -notlike "tel*") {
        if ($internalLinks -notcontains $href) { $internalLinks += $href }
    } elseif ($href -like "https://globalsalah.com*" -or $href -like "$stagingBase*") {
        if ($internalLinks -notcontains $href) { $internalLinks += $href }
    }
}
Write-Host "Homepage internal links found ($($internalLinks.Count)):"
foreach ($l in $internalLinks) {
    Write-Host "  $l"
}
