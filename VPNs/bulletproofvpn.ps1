$Destination = $env:APPDATA
 
##DOWNLOAD CERT
$DownloadURL = "https://www.dropbox.com/scl/fi/zd5hf01mpv6hhhuuwi9pb/ClientCert.pfx?rlkey=mxpmntu9djljk9s96freshi6s&e=1&st=8xc06gra&dl=1%22"
Invoke-WebRequest $DownloadURL -OutFile ($Destination + "\ClientCert.pfx")
 
## EAP CONFIG
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
<IssuerHash>D5 D1 7A AB 6D 6C 2E B7 C0 1E 03 62 B5 B6 D1 49 A3 B1 22 B5 </IssuerHash>
 
						</CAHashList>
</FilteringInfo>
</TLSExtensions>
</EapType>
</Eap>
</Config>
</EapHostConfig>'
 
##REMOVE IF THERE AND ADD AFTER
if ((Get-VpnConnection -Name "BP VPN" -ErrorAction SilentlyContinue).Name -eq "BP VPN")
{
    Remove-VpnConnection -Name "BP VPN" -Force
}
 
Add-VpnConnection -Name "BP VPN" -ServerAddress wan.9dfg6uuf5av1tcoyq3nke0wd9.vpn.azure.com -TunnelType Ikev2 -AuthenticationMethod Eap -SplitTunneling:$true -RememberCredential -EncryptionLevel Optional -EapConfigXmlStream $EAP -PassThru
 
## ADD VPN ROUTES
Add-VpnConnectionRoute -ConnectionName "BP VPN" -DestinationPrefix 10.140.0.0/16
Add-VpnConnectionRoute -ConnectionName "BP VPN" -DestinationPrefix 172.16.215.0/24   
Add-VpnConnectionRoute -ConnectionName 'BP VPN' -DestinationPrefix 74.220.27.238/32 
Add-VpnConnectionRoute -ConnectionName 'BP VPN' -DestinationPrefix 74.220.25.103/32 
Add-VpnConnectionRoute -ConnectionName 'BP VPN' -DestinationPrefix 74.220.28.65/32
 
## IMPORT CERT INTO USER STORE
$filelocale = ($Destination + "\ClientCert.pfx")
$Pass = ConvertTo-SecureString -String 'wackyK!te28' -Force -AsPlainText
$Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "whatever", $Pass
Import-PfxCertificate -FilePath $filelocale -CertStoreLocation Cert:\CurrentUser\My -Password $Cred.Password
 
## REMOVE CERT FILE FROM PC
Remove-Item -Path ($Destination + "\ClientCert.pfx") -Force
 
## ADD EVENT TO EVENT LOG
Write-EventLog -LogName "Application" -Source "Application Error" -EventID 999 -EntryType Information -Message "VPN Profile added" -Category 1 -RawData 10,20