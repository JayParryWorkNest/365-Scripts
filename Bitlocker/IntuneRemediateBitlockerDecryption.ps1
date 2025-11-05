$encryptionMethod = "XtsAes256"
$drives = Get-BitLockerVolume | Where-Object { $_.VolumeType -eq 'Fixed' }

foreach ($drive in $drives) {
    $mountPoint = $drive.MountPoint
    Write-Output "Checking drive $mountPoint..."

    if ($drive.ProtectionStatus -eq 1 -and $drive.EncryptionMethod -eq $encryptionMethod) {
        Write-Output "BitLocker is already enabled with correct encryption on $mountPoint."
        continue
    }

    $attempts = 0
    $maxAttempts = 2
    $success = $false

    while (-not $success -and $attempts -lt $maxAttempts) {
        try {
            $attempts++
            Write-Output "Enabling BitLocker on $mountPoint with $encryptionMethod (Attempt $attempts)..."

            Enable-BitLocker -MountPoint $mountPoint `
                             -EncryptionMethod $encryptionMethod `
                             -TpmProtector `
                             -RecoveryPasswordProtector `
                             -UsedSpaceOnly

            Write-Output "Encryption started on $mountPoint."
            $success = $true
        } catch {
            Write-Output "Failed to enable BitLocker on ${mountPoint}: $($_.Exception.Message)"
            if ($attempts -lt $maxAttempts) {
                Write-Output "Retrying..."
                Start-Sleep -Seconds 5
            }
        }
    }

    if (-not $success) {
        Write-Output "Failed to enable BitLocker on $mountPoint after $maxAttempts attempts."
    }
}

Write-Output "BitLocker remediation script completed."
