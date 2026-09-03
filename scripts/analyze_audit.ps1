$json = Get-Content "scripts/audit_summary.json" -Raw | ConvertFrom-Json

Write-Host "=========================================="
Write-Host "DEEP AUDIT ANALYSIS REPORT"
Write-Host "=========================================="

Write-Host "`n[1] STATUS CODES SUMMARY:"
$json | Group-Object StatusCode | ForEach-Object {
    Write-Host "HTTP $($_.Name): $($_.Count) pages"
}
$non200 = $json | Where-Object { $_.StatusCode -ne 200 }
if ($non200) {
    Write-Host "`nNon-200 Pages:"
    foreach ($p in $non200) {
        Write-Host "  $($p.StatusCode) -> $($p.Path)"
    }
}

Write-Host "`n[2] BASE HREF TAG CHECK:"
$withBase = $json | Where-Object { $_.HasBaseHref -eq $true }
Write-Host "Pages with <base href>: $($withBase.Count) / $($json.Count)"
if ($withBase) {
    Write-Host "Sample Base Href Value: $($withBase[0].BaseHrefValue)"
}

Write-Host "`n[3] H1 HEADINGS AUDIT:"
$multipleH1 = $json | Where-Object { $_.H1Count -gt 1 }
$noH1 = $json | Where-Object { $_.H1Count -eq 0 }
$emptyH1 = $json | Where-Object { $_.EmptyHeadingsCount -gt 0 }
Write-Host "Pages with exactly 1 H1: $(($json | Where-Object {$_.H1Count -eq 1}).Count)"
Write-Host "Pages with Multiple H1s: $($multipleH1.Count)"
Write-Host "Pages with NO H1: $($noH1.Count)"
Write-Host "Pages with Empty Headings: $($emptyH1.Count)"
if ($multipleH1) {
    Write-Host "Pages with Multiple H1:"
    $multipleH1 | ForEach-Object { Write-Host "  $($_.Path) (H1 count: $($_.H1Count) - $($_.H1Texts -join ' | '))" }
}
if ($noH1) {
    Write-Host "Pages with No H1:"
    $noH1 | ForEach-Object { Write-Host "  $($_.Path)" }
}

Write-Host "`n[4] META TITLES & DESCRIPTIONS AUDIT:"
$missingTitle = $json | Where-Object { [string]::IsNullOrWhiteSpace($_.Title) }
$longTitle = $json | Where-Object { $_.TitleLength -gt 60 }
$shortTitle = $json | Where-Object { $_.TitleLength -lt 30 -and $_.TitleLength -gt 0 }
$missingDesc = $json | Where-Object { [string]::IsNullOrWhiteSpace($_.MetaDescription) }
$longDesc = $json | Where-Object { $_.MetaDescriptionLength -gt 160 }
$shortDesc = $json | Where-Object { $_.MetaDescriptionLength -lt 70 -and $_.MetaDescriptionLength -gt 0 }

Write-Host "Missing Title: $($missingTitle.Count)"
Write-Host "Long Title (>60 chars): $($longTitle.Count)"
Write-Host "Short Title (<30 chars): $($shortTitle.Count)"
Write-Host "Missing Meta Description: $($missingDesc.Count)"
Write-Host "Long Meta Description (>160 chars): $($longDesc.Count)"
Write-Host "Short Meta Description (<70 chars): $($shortDesc.Count)"

Write-Host "`nSample Titles & Lengths:"
$json | Select-Object -First 10 | ForEach-Object {
    Write-Host "  [$($_.TitleLength) ch] $($_.Path) -> '$($_.Title)'"
}

Write-Host "`nSample Descriptions & Lengths:"
$json | Select-Object -First 10 | ForEach-Object {
    Write-Host "  [$($_.MetaDescriptionLength) ch] $($_.Path) -> '$($_.MetaDescription)'"
}

Write-Host "`n[5] CANONICALS & HREFLANG AUDIT:"
$canonicalProdCount = ($json | Where-Object { $_.Canonical -like "https://globalsalah.com*" }).Count
$canonicalStagingCount = ($json | Where-Object { $_.Canonical -like "https://crmapi.designstime.com*" }).Count
$missingCanonical = ($json | Where-Object { [string]::IsNullOrWhiteSpace($_.Canonical) }).Count
Write-Host "Canonicals pointing to production (globalsalah.com): $canonicalProdCount"
Write-Host "Canonicals pointing to staging (crmapi.designstime.com): $canonicalStagingCount"
Write-Host "Missing Canonical: $missingCanonical"

Write-Host "`nHreflang Tags per page:"
$json | Group-Object HreflangCount | ForEach-Object {
    Write-Host "  Hreflang count $($_.Name): $($_.Count) pages"
}

Write-Host "`n[6] STRUCTURED DATA / SCHEMA AUDIT:"
$json | Group-Object SchemasCount | ForEach-Object {
    Write-Host "  Schema script tags count $($_.Name): $($_.Count) pages"
}
Write-Host "`nUnique Schema Types Found across pages:"
$allTypes = @()
foreach ($p in $json) {
    if ($p.SchemaTypes) {
        $allTypes += $p.SchemaTypes
    }
}
$allTypes | Group-Object | ForEach-Object {
    Write-Host "  - $($_.Name): in $($_.Count) page instances"
}

Write-Host "`n[7] IMAGES AUDIT:"
$totalImgs = ($json | Measure-Object -Property ImagesTotal -Sum).Sum
$totalMissingAlt = ($json | Measure-Object -Property ImagesMissingAlt -Sum).Sum
$totalMissingDims = ($json | Measure-Object -Property ImagesMissingDimensions -Sum).Sum
$totalNonWebp = ($json | Measure-Object -Property ImagesNonWebp -Sum).Sum
Write-Host "Total Images Detected: $totalImgs"
Write-Host "Images Missing Alt: $totalMissingAlt"
Write-Host "Images Missing Width/Height: $totalMissingDims"
Write-Host "Images Non-WebP (PNG/JPG): $totalNonWebp"

Write-Host "`n[8] DUPLICATE HTML IDs:"
$dupIdPages = $json | Where-Object { $_.DuplicateIds.Count -gt 0 }
Write-Host "Pages with Duplicate IDs: $($dupIdPages.Count)"
foreach ($p in $dupIdPages) {
    Write-Host "  $($p.Path): Duplicate IDs -> $($p.DuplicateIds -join ', ')"
}
