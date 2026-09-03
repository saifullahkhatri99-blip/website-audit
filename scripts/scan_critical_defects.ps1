[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

# Fetch all sitemap pages
$pagesEnUrl = "$stagingBase/sitemaps/pages-en-001.xml"
$pagesContent = $wc.DownloadString($pagesEnUrl)
[xml]$pagesXml = $pagesContent

$blogSmUrl = "$stagingBase/blog-sitemap.xml"
$blogContent = $wc.DownloadString($blogSmUrl)
[xml]$blogXml = $blogContent

$allUrls = @()
foreach ($u in $pagesXml.urlset.url) { $allUrls += $u.loc }
foreach ($u in $blogXml.urlset.url) { $allUrls += $u.loc }

Write-Host "Scanning $($allUrls.Count) URLs for Critical Defects (Localhost, Encoding bugs, Staging links, Schema bugs)..."

$defectReport = @()

foreach ($u in $allUrls) {
    $localUrl = $u -replace "https://globalsalah.com", $stagingBase
    try {
        $html = $wc.DownloadString($localUrl)
        
        $hasLocalhost = $html -match 'localhost'
        $hasEncodingGlitch = $html -match '' -or $html -match '&#65533;'
        $hasHardcodedStagingInBody = $html -match 'crmapi\.designstime\.com'
        $hasDotSlashLinks = $html -match 'href=["'']\./'
        
        if ($hasLocalhost -or $hasEncodingGlitch -or $hasHardcodedStagingInBody -or $hasDotSlashLinks) {
            $defects = @()
            if ($hasLocalhost) { $defects += "HARDCODED LOCALHOST FOUND" }
            if ($hasEncodingGlitch) { $defects += "CHARACTER ENCODING CORRUPTION ()" }
            if ($hasHardcodedStagingInBody) { $defects += "STAGING DOMAIN IN HTML" }
            if ($hasDotSlashLinks) { $defects += "RELATIVE ./ LINKS" }
            
            Write-Host "[DEFECT FOUND] in $($u): $($defects -join ', ')" -ForegroundColor Red
            
            # Extract snippets if localhost
            if ($hasLocalhost) {
                $lhMatches = [regex]::Matches($html, '(?i)[^\s"''<>]*localhost[^\s"''<>]*')
                foreach ($m in $lhMatches) {
                    Write-Host "   -> Snippet: $($m.Value)" -ForegroundColor Yellow
                }
            }
            # Extract encoding snippet
            if ($hasEncodingGlitch) {
                $encMatches = [regex]::Matches($html, '.{0,20}.{0,20}')
                foreach ($m in $encMatches | Select-Object -First 3) {
                    Write-Host "   -> Encoding snippet: $($m.Value)" -ForegroundColor Cyan
                }
            }
            
            $defectReport += [PSCustomObject]@{
                Url = $u
                LocalUrl = $localUrl
                Defects = $defects
            }
        }
    } catch {
        Write-Host "[ERROR FETCHING] $u : $($_.Exception.Message)"
    }
}

Write-Host "`nTotal Pages with Critical Content Defects: $($defectReport.Count)"
