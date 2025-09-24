# Prompt for user email
$UserEmail = Read-Host "Enter the user's email address (UPN)"

# Connect to Exchange Online (if not already connected)
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
	Write-Host "Installing ExchangeOnlineManagement module..." -ForegroundColor Yellow
	Install-Module ExchangeOnlineManagement -Force -Scope CurrentUser
}
Import-Module ExchangeOnlineManagement
if (-not (Get-ConnectionInformation)) {
	Connect-ExchangeOnline -ShowBanner:$false
}

# Get all mailboxes (unlimited)
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$Results = @()

foreach ($Mailbox in $Mailboxes) {
	$FullAccess = Get-MailboxPermission -Identity $Mailbox.Identity | Where-Object { $_.User -eq $UserEmail -and $_.AccessRights -contains 'FullAccess' -and $_.IsInherited -eq $false }
	$SendAs = Get-RecipientPermission -Identity $Mailbox.Identity | Where-Object { $_.Trustee -eq $UserEmail -and $_.AccessRights -contains 'SendAs' }
	$SendOnBehalf = $Mailbox.GrantSendOnBehalfTo | Where-Object { $_.PrimarySmtpAddress -eq $UserEmail }

	if ($FullAccess -or $SendAs -or $SendOnBehalf) {
		$Results += [PSCustomObject]@{
			Mailbox              = $Mailbox.PrimarySmtpAddress
			FullAccess           = if ($FullAccess) { 'Yes' } else { 'No' }
			SendAs               = if ($SendAs) { 'Yes' } else { 'No' }
			SendOnBehalf         = if ($SendOnBehalf) { 'Yes' } else { 'No' }
		}
	}
}

if ($Results.Count -eq 0) {
	Write-Host "No mailbox permissions found for $UserEmail." -ForegroundColor Yellow
} else {
	$Results | Format-Table -AutoSize
}
