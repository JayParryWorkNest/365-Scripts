# Detect-CurlVersion.ps1
# Intune detection script to check for curl.exe versions under C:\Windows that are below 8.16.0

$minVersion = [version]"8.16.0"
$searchPaths = Get-ChildItem -Path "C:\Windows\" -Filter "curl.exe" -Recurse -ErrorAction SilentlyContinue

$badVersions = @()

foreach ($file in $searchPaths) {
    try {
        $versionInfo = (Get-Item $file.FullName).VersionInfo
        $fileVersion = [version]$versionInfo.ProductVersion

        if ($fileVersion -lt $minVersion) {
            $badVersions += [PSCustomObject]@{
                Path = $file.FullName
                Version = $fileVersion.ToString()
            }
        }
    } catch {
        Write-Verbose "Failed to check version for $($file.FullName): $_"
    }
}

if ($badVersions.Count -gt 0) {
    Write-Output "Outdated curl.exe found:"
    $badVersions | ForEach-Object { Write-Output " - $($_.Path): version $($_.Version)" }
    # Intune: detection failed → remediation needed
    exit 1
} else {
    Write-Output "All curl.exe versions are up to date (≥ $minVersion) or not present."
    # Intune: detection passed
    exit 0
}
