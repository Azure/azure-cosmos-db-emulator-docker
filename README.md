# Azure Cosmos DB Emulator Docker Container

This repository contains the scripts required to install and run the  [Azure Cosmos DB Emulator](https://learn.microsoft.com/en-us/azure/cosmos-db/docker-emulator-windows) as a Docker container. 

You can fetch the image from Docker Hub by running `docker pull mcr.microsoft.com/cosmosdb/windows/azure-cosmos-emulator`.

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
docker run -v %LOCALAPPDATA%\CosmosDBEmulatorCert:c:\CosmosDBEmulator\CosmosDBEmulatorCert -P -t -i mcr.microsoft.com/cosmosdb/windows/azure-cosmos-emulator
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
See [Developing against the emulator](https://learn.microsoft.com/en-us/azure/cosmos-db/docker-emulator-windows) for how to connect to the emulator using one of the supported APIs/SDKs.

## Linux-based emulator (preview)
The next generation of the Azure Cosmos DB emulator is entirely Linux-based and is available as a Docker container. It supports running on a wide variety of processors and operating systems, including Apple silicon and Microsoft ARM chips without any workarounds or virtual machines necessary. For more information, see documentation [here](https://aka.ms/CosmosVNextEmulator).

### Prerequisites

- [Docker](https://www.docker.com/)

### Installation

Get the Docker container image using `docker pull`. The container image is published to the [Microsoft Artifact Registry](https://mcr.microsoft.com/) as `mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:vnext-preview`.

```bash
docker pull mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:vnext-preview
```

### Running

To run the container, use `docker run`. Afterwards, use `docker ps` to validate that the container is running.

```bash
docker run --detach --publish 8081:8081 --publish 1234:1234 mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:vnext-preview

docker ps
```

```output
CONTAINER ID   IMAGE                                                             COMMAND                  CREATED         STATUS         PORTS                                                                                  NAMES
c1bb8cf53f8a   mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:vnext-preview  "/bin/bash -c /home/…"   5 seconds ago   Up 5 seconds   0.0.0.0:1234->1234/tcp, :::1234->1234/tcp, 0.0.0.0:8081->8081/tcp, :::8081->8081/tcp   <container-name>
```

If you encounter any problems with using this version of the emulator, please open an issue in this GitHub repository and tag it with the label `cosmosEmulatorVnextPreview`.

## Installing certificates for Java SDK

When using the [Java SDK for Azure Cosmos DB](https://learn.microsoft.com/java/api/overview/azure/cosmos-readme?view=azure-java-stable) with the Azure Cosmos DB emulator, or the [linux based emulator](https://aka.ms/CosmosVNextEmulator) in https mode, it is necessary to install it's certificates to your local Java trust store.

### Get certificate

In a `bash` window, run the following: 

```bash
# If the emulator was started with /AllowNetworkAccess, replace localhost with the actual IP address of it:
EMULATOR_HOST=localhost
EMULATOR_PORT=8081
EMULATOR_CERT_PATH=/tmp/cosmos_emulator.cert
openssl s_client -connect ${EMULATOR_HOST}:${EMULATOR_PORT} </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $EMULATOR_CERT_PATH
```

### Install certificate

Navigate to the directory of your java installation where `cacerts` file is located (replace below with correct directory):

```bash
cd "C:/Program Files/Eclipse Adoptium/jdk-17.0.10.7-hotspot/bin"
```

Import the cert (you may be asked for a password, the default value is "changeit"):

```bash
keytool -cacerts -importcert -alias cosmos_emulator -file $EMULATOR_CERT_PATH
```

If you get an error because the alias already exists, delete it and then run the above again:

```bash
keytool -cacerts -delete -alias cosmos_emulator
```


