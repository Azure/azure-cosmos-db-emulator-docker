@echo off
md %LOCALAPPDATA%\DocumentDBEmulatorCert 2>nul
docker run -v %LOCALAPPDATA%\DocumentDBEmulatorCert:c:\DocumentDBEmulator\DocumentDBEmulatorCert -P -t -i documentdb_emulator
