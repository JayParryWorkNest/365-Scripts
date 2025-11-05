
$nessusPath = "C:\Program Files\Tenable\Nessus Agent"
$versionFile = Join-Path $nessusPath "nessuscli.exe"

if (Test-Path $versionFile) {
    $versionOutput = & $versionFile --version
    if ($versionOutput -match "Nessus Agent\s+v11\.\d+\.\d+") {
        Write-Host "Nessus Agent v11 is installed."
        exit 0
    } else {
        Write-Host "Nessus Agent is installed but not v11."
        exit 1
    }
} else {
    Write-Host "Nessus Agent is not installed."
    exit 1
}
