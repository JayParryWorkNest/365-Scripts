# Detection script for Intune
# Returns 1 if Classic Teams is installed, 0 if not

$perUserPath = "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe"
$machineWidePath = "C:\Program Files (x86)\Teams Installer\Teams.exe"

if (Test-Path $perUserPath -or Test-Path $machineWidePath) {
    Write-Output "Classic Teams detected."
    exit 1  # Needs remediation
} else {
    Write-Output "Classic Teams not found."
    exit 0  # Nothing to do
}
