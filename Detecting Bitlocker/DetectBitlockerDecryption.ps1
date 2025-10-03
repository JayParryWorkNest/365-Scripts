
$compliant = $true

$volumes = Get-BitLockerVolume | Where-Object {$_.VolumeType -eq 'Fixed'}

foreach ($volume in $volumes) {
    if ($volume.ProtectionStatus -ne 'On' -or $volume.EncryptionMethod -ne 'XtsAes256') {
        $compliant = $false
        break
    }
}

if ($compliant) {
    Write-Output "Compliant"
    exit 0
} else {
    Write-Output "Non-Compliant"
    exit 1
}
