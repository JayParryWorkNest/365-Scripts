# Script to audit which calendars a 365 user has access to
Import-module ExchangeOnlineManagement
# Requires Exchange Online PowerShell module

# Connect to Exchange Online
Connect-ExchangeOnline

# Specify the user to audit
$UserEmail = Read-Host "Enter the user's email address to audit calendar access"

# Get all mailboxes (unlimited results)
$mailboxes = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited

foreach ($mailbox in $mailboxes) {
	$calendarPermissions = Get-MailboxFolderPermission -Identity "$($mailbox.PrimarySmtpAddress):\Calendar" -User $UserEmail -ErrorAction SilentlyContinue
	if ($calendarPermissions) {
		Write-Output "$UserEmail has access to $($mailbox.PrimarySmtpAddress)'s calendar with permission: $($calendarPermissions.AccessRights)"
	}
}

# Disconnect session
Disconnect-ExchangeOnline
