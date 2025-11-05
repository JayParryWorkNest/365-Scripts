## DOWNLOAD ALL THE FILES TO THE CORRECT DIR
$CoreDIR = 'C:\vpnsetup'
New-Item -ItemType Directory -Path $CoreDIR

## DOWNLOAD THE CERTIFICATE TO DEVICE
$CertDownload = 'https://www.dropbox.com/s/spctabriugawwjo/IMSMClientCert.pfx?st=c1pxs8y9&dl=1'
$SaveLocation = $CoreDIR + '\IMSMClientCert.pfx'
Invoke-WebRequest $CertDownload -OutFile $SaveLocation

## DOWNLOAD THE CERT INSTALL SCRIPT
$ImportDownload = 'https://www.dropbox.com/s/5oy6diiywvqfa77/IMSMInstallCert.ps1?st=b31scv6l&dl=1'
$ImportSaveLocation = $CoreDIR + '\userImportCert.ps1'
Invoke-WebRequest $ImportDownload -OutFile $ImportSaveLocation

## DOWNLOAD THE DIRECT ALWAYS ON
$DirtyDownload = 'https://www.dropbox.com/s/d230g2aee50i82u/AlwaysOnScript.ps1?st=llfwuf38&dl=1'
$DirtySaveLocation = $CoreDIR + '\AlwaysOnScript.ps1'
Invoke-WebRequest $DirtyDownload -OutFile $DirtySaveLocation

## SETUP THE VPN USING THE POWERSHELL SCRIPT
$EAP = '<EapHostConfig
	xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
	<EapMethod>
		<Type
			xmlns="http://www.microsoft.com/provisioning/EapCommon">13
		</Type>
		<VendorId
			xmlns="http://www.microsoft.com/provisioning/EapCommon">0
		</VendorId>
		<VendorType
			xmlns="http://www.microsoft.com/provisioning/EapCommon">0
		</VendorType>
		<AuthorId
			xmlns="http://www.microsoft.com/provisioning/EapCommon">0
		</AuthorId>
	</EapMethod>
	<Config
		xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
		<Eap
			xmlns="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1">
			<Type>13</Type>
			<EapType
				xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1">
				<CredentialsSource>
					<CertificateStore>
						<SimpleCertSelection>true</SimpleCertSelection>
					</CertificateStore>
				</CredentialsSource>
				<ServerValidation>
					<DisableUserPromptForServerValidation>false</DisableUserPromptForServerValidation>
					<ServerNames></ServerNames>
					<TrustedRootCA>DF 3C 24 F9 BF D6 66 76 1B 26 80 73 FE 06 D1 CC 8D 4F 82 A4 </TrustedRootCA>

				</ServerValidation>
				<DifferentUsername>false</DifferentUsername>
				<PerformServerValidation
					xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2">true
				</PerformServerValidation>
				<AcceptServerName
					xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2">false
				</AcceptServerName>
				<TLSExtensions
					xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2">
					<FilteringInfo
						xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV3">
						<CAHashList Enabled="true">
							<IssuerHash>33 77 8F 07 39 02 1B C5 17 B6 53 B8 63 AA 74 E1 19 67 B4 C4 </IssuerHash>

						</CAHashList>
					</FilteringInfo>
				</TLSExtensions>
			</EapType>
		</Eap>
	</Config>
</EapHostConfig>'

try
{
    
    Add-VpnConnection -Name 'IMSM Always On' -AllUserConnection -ServerAddress azuregateway-c1db0074-c57e-46b7-97d5-4ea059b91928-4c40f26dec14.vpn.azure.com -TunnelType Automatic -AuthenticationMethod Eap -SplitTunneling:$True -RememberCredential -EncryptionLevel Optional -EapConfigXmlStream $EAP -PassThru
}
catch
{
	Write-Error "Error while creating new connection: $_"
	exit
}

Add-VpnConnectionRoute -ConnectionName 'IMSM Always On' -DestinationPrefix 10.0.0.0/16
Add-VpnConnectionRoute -ConnectionName 'IMSM Always On' -DestinationPrefix 192.168.0.0/24 
Add-VpnConnectionRoute -ConnectionName 'IMSM Always On' -DestinationPrefix 192.168.2.0/24 
Add-VpnConnectionRoute -ConnectionName 'IMSM Always On' -DestinationPrefix 192.168.10.0/24 
Add-VpnConnectionRoute -ConnectionName 'IMSM Always On' -DestinationPrefix 172.16.215.0/24


## CREATE SCHEDULED TASK TO IMPORT CERTIFICATE TO THE LOCAL USER STORE
$User = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
$schAction = New-ScheduledTaskAction -Execute powershell.exe -Argument '-ExecutionPolicy Bypass -NoProfile -NonInteractive -File "C:\vpnsetup\userImportCert.ps1"'
$trigger = New-ScheduledTaskTrigger -User $User -AtLogOn

Register-ScheduledTask -TaskName "ImportUserCert" -Action $schAction -Trigger $trigger -User $User

## CREATE A SCHEDULED TASK FOR DIRTY VPN
$User = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
$schAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -NoProfile -NonInteractive -File "C:\vpnsetup\AlwaysOnScript.ps1"'
$trigger = New-ScheduledTaskTrigger -User $User -AtLogOn 
Register-ScheduledTask -TaskName "AlwaysOnVPN" -Action $schAction -Trigger $trigger -User $User -

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisableDomainCreds" -Value 1

## NOTES
# Unregister-ScheduledTask -TaskName "AlwaysOnVPN"
# Unregister-ScheduledTask -TaskName "ImportUserCert"
# $schAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-command "Start-Job -Name ''DirtyAlwaysOn'' -FilePath ''C:\vpnsetup\AlwaysOnScript.ps1''"'
