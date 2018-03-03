# Azure Cosmos DB Emulator Docker Container

This repository contains the scripts required to install and run the  [Azure Cosmos DB Emulator](https://docs.microsoft.com/azure/documentdb/documentdb-nosql-local-emulator) as a Docker container. 

You can fetch the image from Docker Hub by running `docker pull Microsoft/azure-cosmosdb-emulator`.

## About the Azure Cosmos DB service
[Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/introduction) is Microsoft's globally distributed, multi-model database. With the click of a button, Azure Cosmos DB enables you to elastically and independently scale throughput and storage across any number of Azure's geographic regions. It offers throughput, latency, availability, and consistency guarantees with comprehensive service level agreements (SLAs), something no other database service can offer.

## About the Azure Cosmos DB emulator

The Azure Cosmos DB Emulator provides a local environment that emulates the Azure Cosmos DB service for development purposes. Using the emulator, you can develop and test your application locally, without creating an Azure subscription or incurring any costs. When you're satisfied with how your application is working in the Azure Cosmos DB Emulator, you can switch to using an Azure Cosmos DB account in the cloud.

## Running inside Docker

The Azure Cosmos DB Emulator can be run on Docker Windows containers. The emulator does not work on Linux containers. 

Once you have [Docker for Windows](https://www.docker.com/docker-windows) installed, you can pull the Emulator image from Docker Hub by running the following command from your favorite shell (cmd.exe, PowerShell, etc.).

```      
docker pull microsoft/azure-cosmosdb-emulator 
```
To start the image, run the following commands.

``` 
md %LOCALAPPDATA%\CosmosDBEmulatorCert 2>nul
docker run -v %LOCALAPPDATA%\CosmosDBEmulatorCert:c:\CosmosDBEmulator\CosmosDBEmulatorCert -P -t -i microsoft/azure-cosmosdb-emulator
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
cd %LOCALAPPDATA%\CosmosDBEmulatorCert
powershell .\importcert.ps1
```

## Developing against the emulator
See [Developing against the emulator](https://docs.microsoft.com/azure/documentdb/documentdb-nosql-local-emulator#developing-with-the-emulator) for how to connect to the emulator using one of the supported APIs/SDKs.

