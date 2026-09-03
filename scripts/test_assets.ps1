[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$stagingBase = "https://crmapi.designstime.com"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

Write-Host "Testing all asset URLs..."

$assetsToCheck = @(
    "/assets/vendor/bootstrap.min.d85327d99c7a.css",
    "/assets/css/site.a16caa6ecb63.css",
    "/assets/css/country-city.cf72676339ff.css",
    "/assets/css/blog.86dd23daff8d.css",
    "/assets/css/blog-layout.7309c7d3d231.css",
    "/assets/css/tools.86f08cce3158.css",
    "/assets/css/final-enhancements.56a2a0362c3e.css",
    "/assets/css/homepage-2026.css",
    "/assets/css/homepage-enhancements.86166ba5a246.css",
    "/assets/vendor/bootstrap.bundle.min.e4fd49181388.js",
    "/assets/js/app.b21b1c733c19.js",
    "/assets/js/privacy-ui.3d845a3814f6.js",
    "/assets/js/language-suggestion.42c5ce948526.js",
    "/assets/js/forum.2c4c360b1672.js",
    "/assets/js/prayer.8bda55dd84b2.js",
    "/assets/js/features.d8a9275d9499.js",
    "/assets/js/quran.a7524e9324ed.js",
    "/assets/js/homepage-events.js",
    "/assets/js/homepage-inspiration.js",
    "/assets/images/global-salah-full-logo.webp",
    "/assets/images/global-salah-full-logo.png",
    "/assets/images/global-salah-favicon.png",
    "/assets/images/social-preview.webp"
)

foreach ($asset in $assetsToCheck) {
    $full = "$stagingBase$asset"
    try {
        $req = [System.Net.HttpWebRequest]::Create($full)
        $req.Method = "HEAD"
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $len = $res.ContentLength
        $ct = $res.Headers["Content-Type"]
        Write-Host "[OK $([int]$res.StatusCode)] $asset ($ct, $len bytes)" -ForegroundColor Green
        $res.Close()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            Write-Host "[FAIL $([int]$_.Exception.Response.StatusCode)] $asset" -ForegroundColor Red
        } else {
            Write-Host "[ERROR] $asset - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
