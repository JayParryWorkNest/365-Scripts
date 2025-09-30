# Check if BitLocker is enabled on the OS drive
$bitlockerStatus = Get-BitLockerVolume -MountPoint $env:SystemDrive

if ($bitlockerStatus.ProtectionStatus -eq 'On') {
    Write-Host "BitLocker is enabled"
    exit 0  # Detection successful
} else {
    Write-Host "BitLocker is not enabled"
    exit 1  # Detection failed
}
