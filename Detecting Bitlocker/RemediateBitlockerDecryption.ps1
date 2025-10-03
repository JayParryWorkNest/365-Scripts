$volumes = Get-BitLockerVolume | Where-Object {$_.VolumeType -eq 'Fixed'}

foreach ($volume in $volumes) {
    if ($volume.ProtectionStatus -ne 'On' -or $volume.EncryptionMethod -ne 'XtsAes256') {
        Enable-BitLocker -MountPoint $volume.MountPoint `
                         -EncryptionMethod XtsAes256 `
                         -UsedSpaceOnly `
                         -TpmProtector

        # Optional: Backup recovery key to AD
        Backup-BitLockerKeyProtector -MountPoint $volume.MountPoint
    }
}
