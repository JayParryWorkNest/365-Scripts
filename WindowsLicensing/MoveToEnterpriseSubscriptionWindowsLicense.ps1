# Use the KMS key to upgrade to Windows Enterprise
slmgr.vbs /ipk XGVPP-NMH47-7TTHJ-W3FW7-8HV2C

# Reapply the original subscription license key
$subscriptionlicense = (Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey
slmgr.vbs /ipk $subscriptionlicense