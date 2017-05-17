$pass = ConvertTo-SecureString -String "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==" -Force -AsPlainText
$cert = Get-ChildItem cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "DocumentDbEmulatorCertificate" }
$output = Export-PfxCertificate -Cert $cert -FilePath c:\CosmosDBEmulator\CosmosDBEmulatorCert\CosmosDBEmulatorCert.pfx -Password $pass
