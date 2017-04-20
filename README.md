# Azure DocumentDB Emulator Docker Container

This repository contains the scripts required to install and run the  [Azure DocumentDB Emulator](https://docs.microsoft.com/azure/documentdb/documentdb-nosql-local-emulator) as a Docker container. 

You can fetch the image from Docker Hub by running `docker pull Microsoft/azure-documentdb-emulator`.

## About the Azure DocumentDB service
[DocumentDB](https://azure.microsoft.com/services/documentdb/) is Microsoft's multi-tenant, globally distributed database system designed to enable developers to build planet scale applications. DocumentDB allows you to elastically scale both, throughput and storage across any number of geographical regions. The service offers guaranteed low latency at P99, 99.99% high availability, predictable throughput, and multiple well-defined consistency models, all backed by comprehensive SLAs. By virtue of its schema-agnostic and write optimized database engine, by default DocumentDB is capable of automatically indexing all the data it ingests and serve SQL, MongoDB, and JavaScript language-integrated queries in a scale-independent manner. As a cloud service, DocumentDB is carefully engineered with multi-tenancy and global distribution from the ground up.

## About the Azure DocumentDB emulator

The Azure DocumentDB Emulator provides a local environment that emulates the Azure DocumentDB service for development purposes. Using the DocumentDB Emulator, you can develop and test your application locally, without creating an Azure subscription or incurring any costs. When you're satisfied with how your application is working in the DocumentDB Emulator, you can switch to using an Azure DocumentDB account in the cloud.

## Running inside Docker

The DocumentDB Emulator can be run on Docker Windows containers. The emulator does not work on Linux containers. 

Once you have [Docker for Windows](https://www.docker.com/docker-windows) installed, you can pull the Emulator image from Docker Hub by running the following command from your favorite shell (cmd.exe, PowerShell, etc.).

```      
docker pull Microsoft/azure-documentdb-emulator 
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

## Developing against the emulator
See [Developing against the emulator](https://docs.microsoft.com/azure/documentdb/documentdb-nosql-local-emulator#developing-with-the-emulator) for how to connect to the emulator using the DocumentDB SDKs or REST API.

