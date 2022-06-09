# powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools
$password = "Wind0wsazure" 
$hostName = "cats.internet.local"
$port = "443"
$storeLocation = "Cert:\LocalMachine\My"
$certificate = New-SelfSignedCertificate -DnsName $hostName -CertStoreLocation $storeLocation
$thumbPrint = $certificate.Thumbprint
$bindingInformation = "*:" + $port + ":" + $hostName
$certificatePath = ("cert:\localmachine\my\" + $certificate.Thumbprint)
$securedString = ConvertTo-SecureString -String $password -Force -AsPlainText
mkdir C:\cats
cp cats.jpg C:\cats
cp index.html C:\cats
Export-PfxCertificate -FilePath "C:\inetpub\temp\temp.pfx" -Cert $certificatePath -Password $securedString
Import-PfxCertificate -FilePath "C:\inetpub\temp\temp.pfx" -CertStoreLocation "Cert:\LocalMachine\Root" -Password $securedString
New-IISSite -Name "CatsSite" -PhysicalPath "C:\cats" -BindingInformation $bindingInformation -CertificateThumbPrint $thumbPrint -CertStoreLocation $storeLocation -Protocol https
$file = "C:\Windows\System32\drivers\etc\hosts"
$hostfile = Get-Content $file
$hostfile += "10.25.1.4   cats.internet.local"
$hostfile += "10.25.1.5   cats.internet.local"
Set-Content -Path $file -Value $hostfile -Force
