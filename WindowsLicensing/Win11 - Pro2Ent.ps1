# Use the KMS key to upgrade to Windows Enterprise
slmgr.vbs //b /ipk XGVPP-NMH47-7TTHJ-W3FW7-8HV2C

# Reapply the original subscription license key
$subscriptionlicense = (Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey
slmgr.vbs /ipk $subscriptionlicense


# Force upgrade to Windows Enterprise using KMS Client Setup Key
$EnterpriseKey = "XGVPP-NMH47-7TTHJ-W3FW7-8HV2C"
Start-Process -FilePath "slmgr.vbs" -ArgumentList "/ipk $EnterpriseKey" -WindowStyle Hidden -Wait

# Trigger activation (subscription-based)
Start-Sleep -Seconds 5
Start-Process -FilePath "slmgr.vbs" -ArgumentList "/ato" -WindowStyle Hidden -Wait

# Optional: Confirm activation status
$activationStatus = (Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.Name -like "*Enterprise*" }).LicenseStatus
switch ($activationStatus) {
    0 { Write-Output "Unlicensed" }
    1 { Write-Output "Licensed" }
    2 { Write-Output "Out-of-Box Grace Period" }
    3 { Write-Output "Out-of-Tolerance Grace Period" }
    4 { Write-Output "Non-Genuine Grace Period" }
    default { Write-Output "Unknown status" }
}
