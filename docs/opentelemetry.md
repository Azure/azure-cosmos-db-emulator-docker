# CosmosDB Emulator OpenTelemetry Integration

This document provides instructions for using OpenTelemetry with CosmosDB Emulator to monitor and trace your application. OpenTelemetry provides a standardized approach for collecting telemetry data, including traces, metrics, and logs.

## What is OpenTelemetry (OTLP)?

[OpenTelemetry](https://opentelemetry.io/) (OTLP) is an open-source observability framework that provides a collection of tools, APIs, and SDKs for instrumenting, generating, collecting, and exporting telemetry data. It's vendor-neutral and has broad industry support, making it an ideal choice for standardizing telemetry across your applications.

OTLP (OpenTelemetry Protocol) is the protocol used by OpenTelemetry to transmit telemetry data between components. It's designed to be efficient and compatible with various backends.

## Configuration Options

CosmosDB Emulator supports several telemetry options, which can be configured through environment variables or command-line flags when running the Docker container:

| Flag | Environment Variable | Description | Default |
|------|---------------------|-------------|---------|
| `--enable-telemetry` | `ENABLE_TELEMETRY` | Enable telemetry collection | `true` |
| `--enable-otlp` | `ENABLE_OTLP_EXPORTER` | Enable OTLP exporter for sending telemetry to external collectors | `false` |
| `--enable-console` | `ENABLE_CONSOLE_EXPORTER` | Enable console output of telemetry data (useful for debugging) | `false` |
| `--log-level` | `LOG_LEVEL` | Set logging verbosity level | `info` |

## Setting Up OpenTelemetry with Docker Compose

The simplest way to set up OpenTelemetry with CosmosDB Emulator is using Docker Compose. This configuration automatically connects CosmosDB Emulator with Jaeger for distributed tracing and Prometheus for metrics collection.

### Sample Docker Compose Configuration

Create a `docker-compose.yml` file with the following content:

```yaml
services:
  jaeger:
    image: jaegertracing/jaeger:latest
    container_name: jaeger
    ports:
      - "16686:16686"  # Jaeger UI
      - "4317:4317"    # OTLP gRPC
      - "4318:4318"    # OTLP HTTP
    networks:
      - cosmos-network

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - cosmos-network
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--web.enable-otlp-receiver'
      - '--storage.tsdb.path=/prometheus'

  pgcosmos:
    image: cosmosemulator:latest
    container_name: pgcosmos
    ports:
      - "8081:8081"
      - "1234:1234"
      - "9712:9712"    # PostgreSQL metrics endpoint
    environment:
      - ENABLE_TELEMETRY=true
      - ENABLE_OTLP_EXPORTER=true
      - ENABLE_CONSOLE_EXPORTER=false
    networks:
      - cosmos-network

networks:
  cosmos-network:
```

### Prometheus Configuration

Create a `prometheus.yml` file in the same directory as your `docker-compose.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'otlp'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

### Starting the Stack

Start the complete observability stack:

```bash
docker-compose up -d
```

## Manual Setup with Docker

If you prefer to run CosmosDB Emulator directly with Docker, you can use the following commands:

### 1. Start Jaeger

```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/jaeger:latest
```

### 2. Start Prometheus

First, create a prometheus.yml configuration file:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'otlp'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

Then start Prometheus:

```bash
docker run -d --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.enable-otlp-receiver
```

### 3. Start CosmosDB Emulator with OpenTelemetry enabled

```bash
docker run -d --name pgcosmos \
  -p 8081:8081 \
  -p 1234:1234 \
  -p 9712:9712 \
  --link jaeger \
  --link prometheus \
  -e ENABLE_TELEMETRY=true \
  -e ENABLE_OTLP_EXPORTER=true \
  -e ENABLE_CONSOLE_EXPORTER=false \
  cosmosemulator:latest
```

## Accessing the Monitoring UIs

- **Jaeger UI**: http://localhost:16686
- **Prometheus UI**: http://localhost:9090

## Trace Information

CosmosDB Emulator includes comprehensive tracing for all Cosmos DB operations. When OTLP exporting is enabled, you'll see traces for the following operations:

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
  -e ENABLE_TELEMETRY=true \
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
      
  otlphttp/metrics:
    endpoint: "http://metrics:9090/api/v1/otlp"
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp/traces]
    metrics:
      receivers: [postgresql, otlp]
      processors: [batch]
      exporters: [otlphttp/metrics]

  telemetry:
    logs:
      level: "WARN"
    metrics:
      level: "normal"
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

## Using with Kubernetes

If you're running CosmosDB Emulator in Kubernetes, you can deploy the OpenTelemetry collector as a sidecar container:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgcosmos
spec:
  selector:
    matchLabels:
      app: pgcosmos
  template:
    metadata:
      labels:
        app: pgcosmos
    spec:
      containers:
      - name: pgcosmos
        image: cosmosemulator:latest
        env:
        - name: ENABLE_TELEMETRY
          value: "true"
        - name: ENABLE_OTLP_EXPORTER
          value: "true"
      - name: otel-collector
        image: otel/opentelemetry-collector-contrib:latest
        volumeMounts:
        - name: otel-config
          mountPath: /etc/otel
      volumes:
      - name: otel-config
        configMap:
          name: otel-config
```

## Metrics Information

CosmosDB Emulator exports the following metrics:

- **Request Rates:** Shows the traffic patterns for different operation types
- **Query Execution Times:** Measures the time taken to execute different queries
- **Resource Utilization:** CPU, memory usage and connection pool metrics
- **Error Rates:** Tracking of errors by type and endpoint

These metrics are available through any metrics backend that supports OTLP and provides valuable insights into the database's performance and health.
