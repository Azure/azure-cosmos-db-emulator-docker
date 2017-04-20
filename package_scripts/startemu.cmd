@echo off
echo Starting Emulator
rem start /WAIT "" "c:\Program Files\DocumentDB Emulator\DocumentDB.Emulator.exe" /noui /GenKeyFile=c:\DocumentDBEmulator\keyfile.txt 
rem start "" "c:\Program Files\DocumentDB Emulator\DocumentDB.Emulator.exe" /noui /AllowNetworkAccess /NoFirewall /KeyFile=c:\DocumentDBEmulator\keyfile.txt
rem echo Authorization key:
rem type c:\DocumentDBEmulator\keyfile.txt
start "" "c:\Program Files\DocumentDB Emulator\DocumentDB.Emulator.exe" /noui /AllowNetworkAccess /NoFirewall /Key=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==
powershell -File c:\DocumentDBEmulator\getaddr.ps1
echo Master Key: C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==
echo Exporting SSL Certificate
powershell -File c:\DocumentDBEmulator\exportcert.ps1
copy /y c:\DocumentDBEmulator\importcert.ps1 c:\DocumentDBEmulator\DocumentDBEmulatorCert >nul
echo You can import the SSL certificate from an administrator command prompt on the host by running:
echo cd /d ^%%LOCALAPPDATA^%%\DocumentDBEmulatorCert
echo powershell .\importcert.ps1
echo --------------------------------------------------------------------------------------------------
echo Starting interactive shell
cmd /K
