Add-Type -AssemblyName System.Windows.Forms

try {
    $Disk = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
    $KeyProtector = $Disk.KeyProtector | ForEach-Object { $_.KeyprotectorType }
    if ($KeyProtector -contains 'TpmPin' -or $KeyProtector -contains 'TPMAndPIN') {
        $result = "Bitlocker Pin Enabled. Your laptop is protected by an encryption policy."
    } else {
        $Pin = (Get-Random -Minimum 0 -Maximum 999999).ToString('000000')
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -Pin $Pin -TPMandPinProtector -UsedSpaceOnly
        $result = "No Bitlocker Pin Found. A new Bitlocker pin has been generated. You will need to enter the following pin when the computer starts up:`n`nYour Pin is $Pin."
    }
} catch {
    $result = "Script needs to run as Admin"
}

# Create a hidden form to act as the owner
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.WindowState = 'Minimized'
$form.Show()

# Show the MessageBox with the form as owner and display the result
[System.Windows.Forms.MessageBox]::Show($form, $result, "Bitlocker Status")

# Close the hidden form after the message box is dismissed
$form.Close()