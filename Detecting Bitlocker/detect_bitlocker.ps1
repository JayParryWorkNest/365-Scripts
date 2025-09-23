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
    exit 1
     
     }