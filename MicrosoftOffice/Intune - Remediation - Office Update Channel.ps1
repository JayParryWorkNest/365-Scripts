# Forces Office 365 Apps to the Current Channel

$currentChannelGuid = "492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
$officeConfigPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

if (Test-Path $officeConfigPath) {
    try {
        Set-ItemProperty -Path $officeConfigPath -Name "CDNBaseUrl" -Value "http://officecdn.microsoft.com/pr/$currentChannelGuid"
        Set-ItemProperty -Path $officeConfigPath -Name "UpdateChannel" -Value "http://officecdn.microsoft.com/pr/$currentChannelGuid"
        Write-Output "Office channel set to Current Channel"

        # Trigger immediate update
        $officeC2R = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
        if (Test-Path $officeC2R) {
            Start-Process -FilePath $officeC2R -ArgumentList "/update user" -Wait
            Write-Output "Office update triggered"
        } else {
            Write-Output "OfficeC2RClient.exe not found"
        }
    } catch {
        Write-Output "Failed to update channel: $_"
    }
} else {
    Write-Output "Office not found"
}