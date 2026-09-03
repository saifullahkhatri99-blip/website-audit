[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$prodBase = "https://globalsalah.com"

# 1. Fetch Sitemap Index
Write-Host "Fetching sitemap index..."
$sitemapIndexUrl = "$stagingBase/sitemap.xml"
$sitemaps = @()
try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 AuditBot/1.0")
    $smContent = $wc.DownloadString($sitemapIndexUrl)
    [xml]$smXml = $smContent
    foreach ($sm in $smXml.sitemapindex.sitemap) {
        $sitemaps += $sm.loc
    }
    Write-Host "Found $($sitemaps.Count) sub-sitemaps in index."
} catch {
    Write-Host "Error fetching sitemap index: $_"
}

# 2. Collect sample URLs from sub-sitemaps
$sampleUrls = @(
    "/",
    "/countries/",
    "/countries/pakistan/",
    "/countries/pakistan/karachi/",
    "/countries/united-states/",
    "/countries/united-states/new-york/",
    "/countries/saudi-arabia/",
    "/countries/saudi-arabia/makkah/",
    "/countries/united-kingdom/london/",
    "/quran/",
    "/quran/surah-al-fatiha/",
    "/calendar/",
    "/islamic-date-converter/",
    "/ramadan-calendar/",
    "/special-islamic-days/",
    "/duas/",
    "/duas/ablution/",
    "/duas/sleep/",
    "/duas/eating/",
    "/qibla-direction/",
    "/tasbeeh-counter/",
    "/blog/",
    "/about-us/",
    "/about/",
    "/privacy-policy/",
    "/terms-of-service/",
    "/contact-us/",
    "/contact/"
)

# Fetch URLs from sub-sitemaps if available
foreach ($smUrl in $sitemaps | Select-Object -First 3) {
    # rewrite prod url to staging url for testing
    $localSmUrl = $smUrl -replace "https://globalsalah.com", $stagingBase
    try {
        $wc = New-Object System.Net.WebClient
        $subSmContent = $wc.DownloadString($localSmUrl)
        [xml]$subXml = $subSmContent
        $count = 0
        foreach ($urlElem in $subXml.urlset.url) {
            $path = $urlElem.loc -replace "https://globalsalah.com", ""
            if ($path -and ($sampleUrls -notcontains $path) -and $count -lt 5) {
                $sampleUrls += $path
                $count++
            }
        }
    } catch {
        Write-Host "Could not fetch sub-sitemap: $localSmUrl ($($_.Exception.Message))"
    }
}

Write-Host "`nTotal Pages to Audit: $($sampleUrls.Count)"

# 3. Create results container
$auditResults = @()

foreach ($path in $sampleUrls) {
    $fullUrl = "$stagingBase$path"
    Write-Host "Auditing: $path ..."
    $pageData = [PSCustomObject]@{
        Path = $path
        FullUrl = $fullUrl
        StatusCode = 0
        ResponseTimeMs = 0
        ContentLength = 0
        Title = ""
        TitleLength = 0
        MetaDescription = ""
        MetaDescriptionLength = 0
        RobotsMeta = ""
        Canonical = ""
        CanonicalMatch = $false
        HreflangCount = 0
        HreflangList = @()
        OGTitle = ""
        OGDescription = ""
        OGImage = ""
        OGUrl = ""
        OGType = ""
        TwitterCard = ""
        TwitterTitle = ""
        TwitterImage = ""
        H1Count = 0
        H1Texts = @()
        H2Count = 0
        H3Count = 0
        H4Count = 0
        EmptyHeadingsCount = 0
        ImagesTotal = 0
        ImagesMissingAlt = 0
        ImagesMissingDimensions = 0
        ImagesNonWebp = 0
        ScriptsCount = 0
        StylesheetsCount = 0
        SchemasCount = 0
        SchemaTypes = @()
        SchemaErrors = @()
        HasBaseHref = $false
        BaseHrefValue = ""
        DuplicateIds = @()
        BrokenLinks = @()
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $req = [System.Net.HttpWebRequest]::Create($fullUrl)
        $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0"
        $req.Timeout = 10000
        $res = $req.GetResponse()
        $sw.Stop()
        $pageData.ResponseTimeMs = $sw.ElapsedMilliseconds
        $pageData.StatusCode = [int]$res.StatusCode
        $pageData.ContentLength = $res.ContentLength

        $sr = New-Object System.IO.StreamReader($res.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $html = $sr.ReadToEnd()
        $sr.Close()
        $res.Close()

        # Parse with Regex / HTML
        # Title
        if ($html -match '(?i)<title>(.*?)</title>') {
            $pageData.Title = $matches[1].Trim()
            $pageData.TitleLength = $pageData.Title.Length
        }

        # Meta Description
        if ($html -match '(?i)<meta\s+name=["'']description["'']\s+content=["'']([^"'']*)["'']' -or $html -match '(?i)<meta\s+content=["'']([^"'']*)["'']\s+name=["'']description["'']') {
            $pageData.MetaDescription = $matches[1].Trim()
            $pageData.MetaDescriptionLength = $pageData.MetaDescription.Length
        }

        # Meta Robots
        if ($html -match '(?i)<meta\s+name=["'']robots["'']\s+content=["'']([^"'']*)["'']') {
            $pageData.RobotsMeta = $matches[1].Trim()
        }

        # Canonical
        if ($html -match '(?i)<link\s+rel=["'']canonical["'']\s+href=["'']([^"'']*)["'']') {
            $pageData.Canonical = $matches[1].Trim()
            $expectedProd = "$prodBase$path"
            # Normalize trailing slash
            if ($expectedProd -replace "/$", "" -eq $pageData.Canonical -replace "/$", "") {
                $pageData.CanonicalMatch = $true
            }
        }

        # Base Href
        if ($html -match '(?i)<base\s+href=["'']([^"'']*)["'']') {
            $pageData.HasBaseHref = $true
            $pageData.BaseHrefValue = $matches[1]
        }

        # Hreflangs
        $hreflangMatches = [regex]::Matches($html, '(?i)<link\s+rel=["'']alternate["'']\s+hreflang=["'']([^"'']+)["'']\s+href=["'']([^"'']+)["'']')
        if ($hreflangMatches.Count -eq 0) {
            $hreflangMatches = [regex]::Matches($html, '(?i)<link\s+href=["'']([^"'']+)["'']\s+rel=["'']alternate["'']\s+hreflang=["'']([^"'']+)["'']')
        }
        $pageData.HreflangCount = $hreflangMatches.Count
        foreach ($hm in $hreflangMatches) {
            $pageData.HreflangList += "$($hm.Groups[1].Value): $($hm.Groups[2].Value)"
        }

        # OpenGraph
        if ($html -match '(?i)<meta\s+property=["'']og:title["'']\s+content=["'']([^"'']*)["'']') { $pageData.OGTitle = $matches[1] }
        if ($html -match '(?i)<meta\s+property=["'']og:description["'']\s+content=["'']([^"'']*)["'']') { $pageData.OGDescription = $matches[1] }
        if ($html -match '(?i)<meta\s+property=["'']og:image["'']\s+content=["'']([^"'']*)["'']') { $pageData.OGImage = $matches[1] }
        if ($html -match '(?i)<meta\s+property=["'']og:url["'']\s+content=["'']([^"'']*)["'']') { $pageData.OGUrl = $matches[1] }
        if ($html -match '(?i)<meta\s+property=["'']og:type["'']\s+content=["'']([^"'']*)["'']') { $pageData.OGType = $matches[1] }

        # Twitter
        if ($html -match '(?i)<meta\s+name=["'']twitter:card["'']\s+content=["'']([^"'']*)["'']') { $pageData.TwitterCard = $matches[1] }
        if ($html -match '(?i)<meta\s+name=["'']twitter:title["'']\s+content=["'']([^"'']*)["'']') { $pageData.TwitterTitle = $matches[1] }
        if ($html -match '(?i)<meta\s+name=["'']twitter:image["'']\s+content=["'']([^"'']*)["'']') { $pageData.TwitterImage = $matches[1] }

        # Headings
        $h1Matches = [regex]::Matches($html, '(?i)<h1[^>]*>(.*?)</h1>')
        $pageData.H1Count = $h1Matches.Count
        foreach ($h1 in $h1Matches) {
            $cleanH1 = [regex]::Replace($h1.Groups[1].Value, '<[^>]+>', '').Trim()
            $pageData.H1Texts += $cleanH1
            if ([string]::IsNullOrWhiteSpace($cleanH1)) { $pageData.EmptyHeadingsCount++ }
        }

        $h2Matches = [regex]::Matches($html, '(?i)<h2[^>]*>(.*?)</h2>')
        $pageData.H2Count = $h2Matches.Count
        $h3Matches = [regex]::Matches($html, '(?i)<h3[^>]*>(.*?)</h3>')
        $pageData.H3Count = $h3Matches.Count
        $h4Matches = [regex]::Matches($html, '(?i)<h4[^>]*>(.*?)</h4>')
        $pageData.H4Count = $h4Matches.Count

        # Images
        $imgMatches = [regex]::Matches($html, '(?i)<img\b([^>]*)>')
        $pageData.ImagesTotal = $imgMatches.Count
        foreach ($img in $imgMatches) {
            $attrs = $img.Groups[1].Value
            if ($attrs -notmatch '(?i)\balt=') {
                $pageData.ImagesMissingAlt++
            } elseif ($attrs -match '(?i)\balt=["'']\s*["'']') {
                # empty alt
            }
            if ($attrs -notmatch '(?i)\bwidth=' -or $attrs -notmatch '(?i)\bheight=') {
                $pageData.ImagesMissingDimensions++
            }
            if ($attrs -match '(?i)\bsrc=["'']([^"'']+\.(png|jpg|jpeg|gif))["'']') {
                $pageData.ImagesNonWebp++
            }
        }

        # Scripts and CSS
        $scriptMatches = [regex]::Matches($html, '(?i)<script\b([^>]*)>')
        $pageData.ScriptsCount = $scriptMatches.Count
        $cssMatches = [regex]::Matches($html, '(?i)<link\b[^>]*rel=["'']stylesheet["''][^>]*>')
        $pageData.StylesheetsCount = $cssMatches.Count

        # Schemas
        $schemaMatches = [regex]::Matches($html, '(?i)<script\s+type=["'']application/ld\+json["'']>([\s\S]*?)</script>')
        $pageData.SchemasCount = $schemaMatches.Count
        foreach ($sm in $schemaMatches) {
            $jsonStr = $sm.Groups[1].Value.Trim()
            try {
                $jsonObj = $jsonStr | ConvertFrom-Json
                if ($jsonObj."@graph") {
                    foreach ($node in $jsonObj."@graph") {
                        $pageData.SchemaTypes += $node."@type"
                    }
                } elseif ($jsonObj."@type") {
                    $pageData.SchemaTypes += $jsonObj."@type"
                }
            } catch {
                $pageData.SchemaErrors += "JSON-LD parse error: $($_.Exception.Message)"
            }
        }

        # Check Duplicate IDs
        $idMatches = [regex]::Matches($html, '(?i)\bid=["'']([^"'']+)["'']')
        $idList = @()
        foreach ($idm in $idMatches) {
            $idVal = $idm.Groups[1].Value
            if ($idList -contains $idVal -and ($pageData.DuplicateIds -notcontains $idVal)) {
                $pageData.DuplicateIds += $idVal
            }
            $idList += $idVal
        }

    } catch [System.Net.WebException] {
        $sw.Stop()
        $pageData.ResponseTimeMs = $sw.ElapsedMilliseconds
        if ($_.Exception.Response) {
            $pageData.StatusCode = [int]$_.Exception.Response.StatusCode
        } else {
            $pageData.StatusCode = 999
        }
    } catch {
        $pageData.StatusCode = 999
    }

    $auditResults += $pageData
}

# Export Audit Results to JSON for analysis
$jsonOutput = $auditResults | ConvertTo-Json -Depth 6
$jsonOutput | Out-File -FilePath "scripts/audit_summary.json" -Encoding UTF8
Write-Host "`nAudit complete! Results saved to scripts/audit_summary.json"
