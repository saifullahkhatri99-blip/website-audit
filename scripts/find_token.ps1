Write-Host "Checking Environment Variables..."
if ([System.Environment]::GetEnvironmentVariable("GITHUB_TOKEN")) { Write-Host "FOUND GITHUB_TOKEN" }
if ([System.Environment]::GetEnvironmentVariable("GH_TOKEN")) { Write-Host "FOUND GH_TOKEN" }
if ([System.Environment]::GetEnvironmentVariable("GIT_TOKEN")) { Write-Host "FOUND GIT_TOKEN" }

Write-Host "Checking User Profile..."
$user = $env:USERPROFILE
$filesToCheck = @(
    "$user\.git-credentials",
    "$user\.gitconfig",
    "$user\.config\gh\hosts.yml",
    "$user\.npmrc",
    "$env:APPDATA\GitHub CLI\hosts.yml",
    "$user\.env",
    "c:\Users\WN-084\Desktop\.env"
)

foreach ($f in $filesToCheck) {
    if (Test-Path $f) {
        Write-Host "Found file: $f"
        $c = Get-Content $f -Raw
        if ($c -match "ghp_" -or $c -match "github_pat_" -or $c -match "oauth_token") {
            Write-Host "Token detected in $f"
        }
    }
}

# Check Windows Credential Manager using cmdkey
Write-Host "Checking Windows Credential Manager..."
cmdkey /list | Select-String "git"
