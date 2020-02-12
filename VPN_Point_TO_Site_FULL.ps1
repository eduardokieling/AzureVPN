################################################################
#Autor: Eduardo Kieling
#Blog: Https://eduardokieling.com
#Microsoft Azure MVP
#############################################################################################################
#>>>Create a certificate root and client + Key For PointTOSite VPN on Azure<<<
#############################################################################################################
#
################################################################
#GLOBAL VARIABLES
################################################################
$exportpath = "C:\" #File Path
$certname = Read-Host "Certificate Name"
$pass = Read-Host  "Certificate Password" -AsSecureString
#
#
#
#PS:Openssl requirement
#
#
################################################################

#LOCAL VARIABLES
$rootcertcn="CN="+$certname+"_ROOT"
$clientcertcn="CN="+$certname+"_CLIENT" 

#CREATE ROOT CERTIFICATE
$certroot = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject $rootcertcn -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign


#CREATE CLIENT CERTIFICATE
$certclient = New-SelfSignedCertificate -Type Custom -DnsName $clientcertcn -KeySpec Signature -Subject $clientcertcn -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -Signer $certroot -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

#EXPORT ROOT AND CLIENT CERTIFICATES
$certrootpfx = Export-PfxCertificate -Cert $certclient -FilePath $exportpath\VPN_CLIENT.pfx -ChainOption EndEntityCertOnly -NoProperties -Password $pass
Write-Host "                                                    " -ForegroundColor DarkRed -BackgroundColor White
Write-Host "     Write the same password you entered before     " -ForegroundColor DarkRed -BackgroundColor White
Write-Host "                                                    " -ForegroundColor DarkRed -BackgroundColor White
openssl pkcs12 -in $exportpath\VPN_CLIENT.pfx -nodes -out $exportpath\"VPN_CLIENT_KEY_"$certname".txt"
Remove-Item  $certrootpfx
$certroot64 = Export-Certificate -Cert $certroot -FilePath $exportpath\VPN_ROOT.cer -Type CER
certutil -encode $certroot64 $exportpath\"VPN_ROOT64_"$certname".cer"
Remove-Item  $certroot64
$certclient64 = Export-Certificate -Cert $certclient -FilePath $exportpath\VPN_CLIENT.cer -Type CER
certutil -encode $certclient64 $exportpath\"VPN_CLIENT64_"$certname".cer"
Remove-Item $certclient64 

