[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$urls = @(
    "https://github.com/saifullahkhatri99-blip/website-audit",
    "https://github.com/saifullahkhatri99-blip",
    "https://crmapi.designstime.com"
)

foreach ($u in $urls) {
    try {
        $req = [System.Net.HttpWebRequest]::Create($u)
        $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0"
        $req.Timeout = 10000
        $res = $req.GetResponse()
        Write-Host "[OK $([int]$res.StatusCode)] $u" -ForegroundColor Green
        $res.Close()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            Write-Host "[HTTP $([int]$_.Exception.Response.StatusCode)] $u" -ForegroundColor Red
        } else {
            Write-Host "[ERROR] $u - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
