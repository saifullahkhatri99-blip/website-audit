[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

$scripts = @(
    "app.b21b1c733c19.js",
    "prayer.8bda55dd84b2.js",
    "features.d8a9275d9499.js",
    "quran.a7524e9324ed.js",
    "forum.2c4c360b1672.js",
    "privacy-ui.3d845a3814f6.js",
    "language-suggestion.42c5ce948526.js"
)

Write-Host "=========================================="
Write-Host "DEEP JAVASCRIPT CODEBASE AUDIT"
Write-Host "=========================================="

foreach ($s in $scripts) {
    $url = "$stagingBase/assets/js/$s"
    try {
        $js = $wc.DownloadString($url)
        Write-Host "`n--- $s ($($js.Length) bytes) ---"
        
        # Check API calls / fetch / ajax
        $fetches = [regex]::Matches($js, '(?i)fetch\s*\(\s*["'']([^"'']+)["'']')
        Write-Host "  Fetch calls found: $($fetches.Count)"
        foreach ($f in $fetches) {
            Write-Host "    fetch: $($f.Groups[1].Value)"
        }

        # Check endpoints / URLs
        $urls = [regex]::Matches($js, 'https?://[a-zA-Z0-9\.\-_/:]+')
        $uniqueUrls = @()
        foreach ($u in $urls) {
            $val = $u.Value
            if ($uniqueUrls -notcontains $val -and $val -notlike "*w3.org*" -and $val -notlike "*schema.org*") {
                $uniqueUrls += $val
            }
        }
        Write-Host "  External/Hardcoded URLs ($($uniqueUrls.Count)):"
        foreach ($u in $uniqueUrls | Select-Object -First 10) {
            Write-Host "    -> $u"
        }

        # Check console logs
        $logs = [regex]::Matches($js, 'console\.(log|warn|error|info)\(')
        Write-Host "  Console statements left in production JS: $($logs.Count)"

        # Check localStorage keys
        $storage = [regex]::Matches($js, 'localStorage\.(setItem|getItem|removeItem)\s*\(\s*["'']([^"'']+)["'']')
        $keys = @()
        foreach ($st in $storage) {
            $k = $st.Groups[2].Value
            if ($keys -notcontains $k) { $keys += $k }
        }
        Write-Host "  LocalStorage Keys used: $($keys -join ', ')"

    } catch {
        Write-Host "Error inspecting $($s): $($_.Exception.Message)"
    }
}
