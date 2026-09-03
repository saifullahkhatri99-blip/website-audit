$data = Get-Content "scripts/features_audit_summary.json" -Raw | ConvertFrom-Json
foreach ($p in $data) {
    Write-Host "[$($p.Status)] $($p.Path) - $($p.H1)"
    if ($p.DotSlashLinks.Count -gt 0) {
        Write-Host "  WARNING: $($p.DotSlashLinks.Count) dot-slash links found (e.g. $($p.DotSlashLinks[0]))" -ForegroundColor Yellow
    }
    $types = ($p.SchemaDetails | ForEach-Object { $_.Type }) -join ', '
    Write-Host "  Schemas: $types"
    Write-Host "  CSS ($($p.CssFiles.Count)): $($p.CssFiles -join ', ')"
    Write-Host "  JS ($($p.JsFiles.Count)): $($p.JsFiles -join ', ')"
    Write-Host "-----------------------------------------"
}
