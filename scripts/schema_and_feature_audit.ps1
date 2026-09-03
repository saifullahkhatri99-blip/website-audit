[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$prodBase = "https://globalsalah.com"

# Target key distinct feature pages
$testPages = @(
    "/",
    "/countries/",
    "/countries/pakistan/",
    "/countries/pakistan/karachi/",
    "/countries/saudi-arabia/mecca/",
    "/countries/united-states/new-york/",
    "/quran/",
    "/calendar/",
    "/islamic-date-converter/",
    "/ramadan-calendar/",
    "/special-islamic-days/",
    "/special-islamic-days/ramadan-2027/",
    "/duas/",
    "/duas/ablution/",
    "/zakat-calculator/",
    "/inheritance-calculator/",
    "/qaza-namaz-calculator/",
    "/qibla-finder/",
    "/prayer-tracker/",
    "/sahih-bukhari/",
    "/jamia-tirmazi/",
    "/makkah-tv/",
    "/madina-tv/",
    "/99-names-of-allah/",
    "/islamic-gallery/",
    "/blog/",
    "/blog/how-prayer-times-are-calculated/",
    "/forum/",
    "/about-us/",
    "/contact-us/",
    "/privacy-policy/",
    "/terms-and-conditions/",
    "/ur/",
    "/ar/"
)

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

$pageAudits = @()

foreach ($path in $testPages) {
    $url = "$stagingBase$path"
    $obj = [PSCustomObject]@{
        Path = $path
        Status = 0
        Title = ""
        MetaDesc = ""
        Canonical = ""
        HreflangCount = 0
        H1 = ""
        SchemaCount = 0
        SchemaDetails = @()
        CssFiles = @()
        JsFiles = @()
        InternalRelativeLinksCount = 0
        DotSlashLinks = @()
        BrokenLinksFound = @()
    }
    try {
        $html = $wc.DownloadString($url)
        $obj.Status = 200

        # Title
        if ($html -match '(?i)<title>(.*?)</title>') { $obj.Title = $matches[1].Trim() }
        # Meta Desc
        if ($html -match '(?i)<meta\s+name=["'']description["'']\s+content=["'']([^"'']*)["'']') { $obj.MetaDesc = $matches[1].Trim() }
        # Canonical
        if ($html -match '(?i)<link\s+rel=["'']canonical["'']\s+href=["'']([^"'']*)["'']') { $obj.Canonical = $matches[1].Trim() }
        # H1
        if ($html -match '(?i)<h1[^>]*>(.*?)</h1>') { $obj.H1 = [regex]::Replace($matches[1], '<[^>]+>', '').Trim() }

        # Hreflangs
        $hls = [regex]::Matches($html, '(?i)<link\s+rel=["'']alternate["'']\s+hreflang')
        $obj.HreflangCount = $hls.Count

        # Dot slash links
        $dotLinks = [regex]::Matches($html, '(?i)<a\b[^>]*href=["''](\./[^"'']*)["'']')
        foreach ($dl in $dotLinks) {
            $obj.DotSlashLinks += $dl.Groups[1].Value
        }

        # CSS
        $cssMatches = [regex]::Matches($html, '(?i)<link\b[^>]*href=["'']([^"'']+\.css[^"'']*)["''][^>]*rel=["'']stylesheet["'']')
        if ($cssMatches.Count -eq 0) {
            $cssMatches = [regex]::Matches($html, '(?i)<link\b[^>]*rel=["'']stylesheet["''][^>]*href=["'']([^"'']+\.css[^"'']*)["'']')
        }
        foreach ($cm in $cssMatches) { $obj.CssFiles += $cm.Groups[1].Value }

        # JS
        $jsMatches = [regex]::Matches($html, '(?i)<script\b[^>]*src=["'']([^"'']+\.js[^"'']*)["'']')
        foreach ($jm in $jsMatches) { $obj.JsFiles += $jm.Groups[1].Value }

        # Schemas
        $schemaPattern = '(?is)<script\s+type=["'']application/ld\+json["'']>(.*?)</script>'
        $schemaMatches = [regex]::Matches($html, $schemaPattern)
        $obj.SchemaCount = $schemaMatches.Count
        foreach ($sm in $schemaMatches) {
            try {
                $sJson = $sm.Groups[1].Value | ConvertFrom-Json
                if ($sJson."@graph") {
                    foreach ($node in $sJson."@graph") {
                        $obj.SchemaDetails += [PSCustomObject]@{
                            Type = $node."@type"
                            Id = $node."@id"
                            Name = $node.name
                        }
                    }
                } else {
                    $obj.SchemaDetails += [PSCustomObject]@{
                        Type = $sJson."@type"
                        Id = $sJson."@id"
                        Name = $sJson.name
                    }
                }
            } catch {
                $obj.SchemaDetails += "JSON Parse Error: $($_.Exception.Message)"
            }
        }

    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $obj.Status = [int]$_.Exception.Response.StatusCode
        } else {
            $obj.Status = 999
        }
    }
    $pageAudits += $obj
}

$pageAudits | ConvertTo-Json -Depth 6 | Out-File "scripts/features_audit_summary.json" -Encoding UTF8
Write-Host "Detailed feature and schema audit saved to scripts/features_audit_summary.json"
