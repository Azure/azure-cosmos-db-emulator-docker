# Azure DocumentDB Emulator Docker Container

This reposo
The [Azure DocumentDB Emulator](https://docs.microsoft.com/azure/documentdb/documentdb-nosql-local-emulator) provides a local environment that emulates the Azure DocumentDB service for development purposes. Using the DocumentDB Emulator, you can develop and test your application locally, without creating an Azure subscription or incurring any costs. When you're satisfied with how your application is working in the DocumentDB Emulator, you can switch to using an Azure DocumentDB account in the cloud.

## Running on Docker for Windows

The DocumentDB Emulator can be run on Docker for Windows. The Emulator does not work on Docker for Oracle Linux.

Once you have [Docker for Windows](https://www.docker.com/docker-windows) installed, you can pull the Emulator image from Docker Hub by running the following command from your favorite shell (cmd.exe, PowerShell, etc.).

```      
docker pull mominag/documentdb_emulator 
```
To start the image, run the following commands.

``` 
md %LOCALAPPDATA%\DocumentDBEmulatorCert 2>nul
docker run -v %LOCALAPPDATA%\DocumentDBEmulatorCert:c:\DocumentDBEmulator\DocumentDBEmulatorCert -P -t -i mominag/documentdb_emulator
```

The response looks similar to the following:

```
Starting Emulator
Emulator Endpoint: https://172.20.229.193:8081/
Master Key: C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==
Exporting SSL Certificate
You can import the SSL certificate from an administrator command prompt on the host by running:
cd /d %LOCALAPPDATA%\DocumentDBEmulatorCert
powershell .\importcert.ps1
--------------------------------------------------------------------------------------------------
Starting interactive shell
``` 

Closing the interactive shell once the Emulator has been started will shutdown the Emulator’s container.

Use the endpoint and master key in from the response in your client and import the SSL certificate into your host. To import the SSL certificate, do the following from an admin command prompt:

```
cd %LOCALAPPDATA%\DocumentDBEmulatorCert
powershell .\importcert.ps1
```
