# CosmosDB Emulator OpenTelemetry Integration

This document provides instructions for using OpenTelemetry with Cosmos DB Emulator to monitor and trace your application. OpenTelemetry provides a standardized approach for collecting telemetry data, including traces, metrics, and logs.

## What is OpenTelemetry (OTLP)?

[OpenTelemetry](https://opentelemetry.io/) (OTLP) is an open-source observability framework that provides a collection of tools, APIs, and SDKs for instrumenting, generating, collecting, and exporting telemetry data. It's vendor-neutral and has broad industry support, making it an ideal choice for standardizing telemetry across your applications.

OTLP (OpenTelemetry Protocol) is the protocol used by OpenTelemetry to transmit telemetry data between components. It is designed to be efficient and compatible with various backends.

## Configuration Options

Cosmos DB Emulator supports several telemetry options, which can be configured through environment variables or command-line flags when running the Docker container:

| Flag | Environment Variable | Description | Default |
|------|---------------------|-------------|---------|
| `--enable-otlp` | `ENABLE_OTLP_EXPORTER` | Enable OTLP exporter for sending telemetry to external collectors | `false` |
| `--enable-console` | `ENABLE_CONSOLE_EXPORTER` | Enable console output of telemetry data (useful for debugging) | `false` |
| `--log-level` | `LOG_LEVEL` | Set logging verbosity level | `info` |
| `--enable-telemetry` | `ENABLE_TELEMETRY` | Enable usage info being sent to Microsoft | `true` |

## Setting Up OpenTelemetry with Docker Compose

The simplest way to set up OpenTelemetry with Cosmos DB Emulator is using Docker Compose. This configuration automatically connects Cosmos DB Emulator with Jaeger for distributed tracing.

### Sample Docker Compose Configuration

Create a `docker-compose.yml` file with the following content:

```yaml
services:
  traces:
    image: jaegertracing/jaeger:latest
    container_name: jaeger
    ports:
      - "16686:16686"  # Jaeger UI
      - "4317:4317"    # OTLP gRPC
      - "4318:4318"    # OTLP HTTP
    networks:
      - cosmos-network

  pgcosmos:
    image: mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:vnext-latest
    container_name: emulator
    ports:
      - "8081:8081"
      - "1234:1234"
      - "9712:9712"    # PostgreSQL metrics endpoint
    environment:
      - ENABLE_TELEMETRY=true
      - ENABLE_OTLP_EXPORTER=true
      - ENABLE_CONSOLE_EXPORTER=true
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317
    networks:
      - cosmos-network

networks:
  cosmos-network:
```

### Starting the Stack

Start the complete observability stack:

```bash
docker-compose up -d
```

## Manual Setup with Docker

If you prefer to run Cosmos DB Emulator directly with Docker, you can use the following commands:

### 1. Start Jaeger

```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/jaeger:latest
```

### 2. Start CosmosDB Emulator with OpenTelemetry enabled

```bash
docker run -d --name pgcosmos \
  -p 8081:8081 \
  -p 1234:1234 \
  -p 9712:9712 \
  --link jaeger \
  -e ENABLE_OTLP_EXPORTER=true \
  -e ENABLE_CONSOLE_EXPORTER=false \
  -e OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317 \
  -e LOG_LEVEL=trace \
  cosmosemulator:latest
```

## Accessing the Monitoring UIs

- **Jaeger UI**: http://localhost:16686

## Trace Information

Cosmos DB Emulator includes comprehensive tracing for all Cosmos DB operations. When OTLP exporting is enabled, you'll see traces for the following operations:

### Document Operations
- `CosmosDB.DocumentOperation.Create`
- `CosmosDB.DocumentOperation.Replace`
- `CosmosDB.DocumentOperation.Upsert`
- `CosmosDB.DocumentOperation.Delete`
- `CosmosDB.DocumentOperation.Read`
- `CosmosDB.DocumentOperation.Batch`
- `CosmosDB.DocumentOperation.Patch`

### Database Operations
- `CosmosDB.Database.Create`
- `CosmosDB.Database.Read`
- `CosmosDB.Database.Delete`
- `CosmosDB.Database.List`
- `CosmosDB.Database.GetOrFind`

### Collection Operations
- `CosmosDB.Collection.Create`
- `CosmosDB.Collection.Read`
- `CosmosDB.Collection.Delete`
- `CosmosDB.Collection.List`

### Query Operations
- `CosmosDB.Query.Execute`
- `CosmosDB.Query.ReadQueryPlan`

### Other Operations
- `CosmosDB.Document.ReadFeed`
- `CosmosDB.DatabaseAccount.Read`
- `CosmosDB.PartitionKeyRange.Read`
- `CosmosDB.Offer.List`

Each trace includes detailed information such as:
- Database name
- Collection name
- Document ID (when applicable)
- Operation type and resource type
- HTTP method and path
- For queries: the original query text and translated query
- For queries with results: the number of items returned

## Enabling the Console Exporter

The console exporter is useful for debugging telemetry issues. It prints telemetry data directly to the console logs. To enable it:

```bash
docker run -d --name pgcosmos \
  -p 8081:8081 \
  -e ENABLE_CONSOLE_EXPORTER=true \
  cosmosemulator:latest
```

Then check the logs:

```bash
docker logs pgcosmos
```

## OpenTelemetry Collector Configuration

CosmosDB Emulator uses the OpenTelemetry Collector for processing telemetry data. The default configuration is:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:
  postgresql:
    endpoint: localhost:9712
    username: otel
    password: otel
    tls:
      insecure: true

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024

exporters:
  debug:
    verbosity: detailed
  
  otlp/traces:
    endpoint: traces:4317
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp/traces]

  telemetry:
    logs:
      level: "WARN"
```

For custom configuration, you can override this file by mounting your own configuration file when running the container:

```bash
docker run -d --name pgcosmos \
  -v $(pwd)/custom-otel-config.yaml:/etc/otel/config.yaml \
  -e ENABLE_TELEMETRY=true \
  -e ENABLE_OTLP_EXPORTER=true \
  cosmosemulator:latest
```

## Troubleshooting (Dev)

### View OpenTelemetry Collector Logs

To see the OpenTelemetry collector logs:

```bash
docker exec -it pgcosmos cat /logs/otel/collector.log
```

### Check OpenTelemetry User Setup

The PostgreSQL metrics require that the "otel" user is properly set up. To verify:

```bash
docker exec -it pgcosmos /scripts/setup_otel_user.sh
```

### Ensure PostgreSQL is Ready

Before the OpenTelemetry collector can collect metrics, PostgreSQL needs to be fully started:

```bash
docker exec -it pgcosmos pg_isready -p 9712 -U cosmosdev -h /socket
```
