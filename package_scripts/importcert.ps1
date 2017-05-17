$pass = ConvertTo-SecureString -String "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==" -Force -AsPlainText
$output = Import-PfxCertificate -FilePath .\CosmosDBEmulatorCert.pfx cert:\localMachine\my -Password $pass
$output = Import-PfxCertificate -FilePath .\CosmosDBEmulatorCert.pfx cert:\localMachine\root -Password $pass
