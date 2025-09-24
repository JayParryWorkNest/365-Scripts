try {

$Disk = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
            }
catch {
    Write-Output "Script needs to run as Admin"
    exit 2
}

$KeyProtector = $Disk.KeyProtector | ForEach-Object { $_.KeyprotectorType }
 
if ($KeyProtector -contains 'TpmPin' -or $KeyProtector -contains 'TPMAndPIN') {
    Write-Output "Bitlocker Pin Enabled"
    exit 0 }

else {
    Write-Output "No Bitlocker Pin Found"
    Write-Output "Generating bitlocker pin"
    $Pin =( Get-Random -Minimum 0 -Maximum 999999 ).ToString(‘000000’)
    Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -Pin $Pin -TPMandPinProtector -UsedSpaceOnly
    exit 1
    Write-Output "Bitlocker Pin Set to $Pin"
    
     }