# Check if BitLocker is enabled on the OS drive
$bitlockerStatus = Get-BitLockerVolume -MountPoint "C:"

# Check if the key protector includes TPM and PIN
$protectors = $bitlockerStatus.KeyProtector

$pinInUse = $false

foreach ($protector in $protectors) {
    if ($protector.KeyProtectorType -eq 'TpmPin') {
        $pinInUse = $true
        break
    }
}

# Output for Intune detection
if ($pinInUse) {
    Write-Output "BitLocker PIN is in use"
    exit 0  # Detection success
} else {
    Write-Output "BitLocker PIN is NOT in use"
    exit 1  # Detection failed
}
