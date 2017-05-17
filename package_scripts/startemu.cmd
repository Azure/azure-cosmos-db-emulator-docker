@echo off
echo Starting Emulator
rem start /WAIT "" "c:\Program Files\CosmosDB Emulator\CosmosDB.Emulator.exe" /noui /GenKeyFile=c:\CosmosDBEmulator\keyfile.txt
rem start "" "c:\Program Files\CosmosDB Emulator\CosmosDB.Emulator.exe" /noui /AllowNetworkAccess /NoFirewall /KeyFile=c:\CosmosDBEmulator\keyfile.txt
rem echo Authorization key:
rem type c:\CosmosDBEmulator\keyfile.txt
start "" "c:\Program Files\Azure Cosmos DB Emulator\CosmosDB.Emulator.exe" /noui /AllowNetworkAccess /NoFirewall /Key=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==
powershell -File c:\CosmosDBEmulator\getaddr.ps1
echo Master Key: C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==
echo Exporting SSL Certificate
powershell -File c:\CosmosDBEmulator\exportcert.ps1
copy /y c:\CosmosDBEmulator\importcert.ps1 c:\CosmosDBEmulator\CosmosDBEmulatorCert >nul
echo You can import the SSL certificate from an administrator command prompt on the host by running:
echo cd /d ^%%LOCALAPPDATA^%%\CosmosDBEmulatorCert
echo powershell .\importcert.ps1
echo --------------------------------------------------------------------------------------------------
echo Starting interactive shell
cmd /K
