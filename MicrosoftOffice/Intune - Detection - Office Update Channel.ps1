# Checks if Microsoft 365 Apps are on the Current Channel

# GUID for Current Channel (Production)
$currentChannelGuid = "492350f6-3a01-4f97-b9c0-c7c6ddf67d60"

# Registry path
$officeConfigPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

# Check if Office Click-to-Run is installed
if (Test-Path $officeConfigPath) {
    $officeProps = Get-ItemProperty -Path $officeConfigPath -ErrorAction SilentlyContinue

    $cdnUrl = $officeProps.CDNBaseUrl
    $updateChannel = $officeProps.UpdateChannel

    if ($cdnUrl -match $currentChannelGuid -or $updateChannel -match $currentChannelGuid) {
        Write-Output "Compliant: Current Channel"
        exit 0
    } else {
        Write-Output "Non-Compliant: Wrong Channel"
        exit 1
    }
} else {
    Write-Output "No Office installation found"
    exit 0
}