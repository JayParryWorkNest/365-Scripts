<#
.SYNOPSIS
 Intune detection script: returns 0 when all fixed volumes are FullyEncrypted (compliant).
 Returns 1 when any fixed volume is NOT FullyEncrypted (non-compliant).
 Returns 2 if the check cannot be performed (cmdlet not present or no volumes found).

Note: Intune treats exit code 0 as "detected". Any non-zero is "not detected".
#>

# Ensure script runs non-interactively and with errors handled
$ErrorActionPreference = 'Stop'

try {
    # Check availability of the cmdlet
    if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction SilentlyContinue)) {
        Write-Output "Get-BitLockerVolume cmdlet not available on this system."
        exit 2
    }

    # Collect BitLocker volumes that have a mountpoint (practical proxy for fixed volumes)
    $bitlockerVolumes = Get-BitLockerVolume | Where-Object {
        # include volumes with a drive letter/mount point (e.g. C:, D:)
        $_.MountPoint -and ($_.MountPoint -match '^[A-Za-z]:')
    }

    if (-not $bitlockerVolumes -or $bitlockerVolumes.Count -eq 0) {
        Write-Output "No fixed/drive-letter BitLocker volumes found to evaluate."
        exit 2
    }

    # Find any volumes that are NOT fully encrypted
    $nonCompliantVolumes = $bitlockerVolumes | Where-Object {
        # Use case-insensitive compare for VolumeStatus
        ($_.VolumeStatus -ne $null) -and -not ($_.VolumeStatus.ToString().ToLower() -eq 'fullyencrypted')
    }

    if ($nonCompliantVolumes.Count -eq 0) {
        Write-Output "All evaluated volumes are FullyEncrypted. (Compliant)"
        # Optionally list volumes and statuses
        $bitlockerVolumes | ForEach-Object {
            Write-Output ("{0} - {1}" -f ($_.MountPoint), ($_.VolumeStatus))
        }
        exit 0
    }
    else {
        Write-Output "Non-compliant volume(s) detected (not FullyEncrypted):"
        $nonCompliantVolumes | ForEach-Object {
            Write-Output ("{0} - VolumeStatus: {1} - ProtectionStatus: {2} - EncryptionPercentage: {3}" -f `
                ($_.MountPoint), ($_.VolumeStatus), ($_.ProtectionStatus), ($_.EncryptionPercentage))
        }
        exit 1
    }
}
catch {
    # Unexpected error — provide message and exit with "unknown" code
    Write-Output "Error evaluating BitLocker status: $($_.Exception.Message)"
    exit 2
}
