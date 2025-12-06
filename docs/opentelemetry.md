# Cosmos DB Emulator OpenTelemetry Integration

This document provides instructions for using OpenTelemetry with Cosmos DB Emulator to monitor and trace your application. OpenTelemetry provides a standardized approach for collecting telemetry data, including traces, metrics, and logs.

## What is OpenTelemetry (OTLP)?

[OpenTelemetry](https://opentelemetry.io/) (OTLP) is an open-source observability framework that provides a collection of tools, APIs, and SDKs for instrumenting, generating, collecting, and exporting telemetry data. It's vendor-neutral and has broad industry support, making it an ideal choice for standardizing telemetry across your applications.

OTLP (OpenTelemetry Protocol) is the protocol used by OpenTelemetry to transmit telemetry data between components. It's designed to be efficient and compatible with various backends.

## Configuration Options

Cosmos DB Emulator supports several telemetry options, which can be configured through environment variables or command-line flags when running the Docker container:

| Flag | Environment Variable | Description | Default |
|------|---------------------|-------------|---------|
| `--enable-otlp` | `ENABLE_OTLP_EXPORTER` | Enable OTLP gRPC exporter for sending telemetry to external collectors | `false` |
| `--enable-console` | `ENABLE_CONSOLE_EXPORTER` | Enable console output of telemetry data (useful for debugging) | `false` |
| `--log-level` | `LOG_LEVEL` | Set logging verbosity level | `info` |

## Setting Up OpenTelemetry with Docker Compose

The simplest way to set up OpenTelemetry with Cosmos DB Emulator is using Docker Compose. This configuration automatically connects Cosmos DB Emulator with Jaeger for distributed tracing and Prometheus for metrics collection.

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
      - "9712:9712"      # PostgreSQL
      - "8889:8889"      # OpenTelemetry Collector Prometheus metrics endpoint
    environment:
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
  - job_name: 'cosmos-metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['pgcosmos:8889']  # OpenTelemetry Collector Prometheus exporter
```

### Starting the Stack

Start the complete observability stack:

```bash
docker-compose up -d
```

## Manual Setup with Docker

If you prefer to run Cosmos DB Emulator directly with Docker, you can use the following commands:

### 1. Create a Docker Network

All containers must be on the same network to communicate by name:

```bash
docker network create cosmos-network
```

### 2. Start Jaeger

```bash
docker run -d --name jaeger \
  --network cosmos-network \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/jaeger:latest
```

### 3. Start Prometheus

Using the same prometheus.yml as specified above, start Prometheus:

```bash
docker run -d --name prometheus \
  --network cosmos-network \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.enable-otlp-receiver \
  --storage.tsdb.path=/prometheus
```

### 4. Start Cosmos DB Emulator with OpenTelemetry enabled

```bash
docker run -d --name pgcosmos \
  --network cosmos-network \
  -p 8081:8081 \
  -p 1234:1234 \
  -p 9712:9712 \
  -p 8889:8889 \
  -e ENABLE_OTLP_EXPORTER=true \
  -e ENABLE_CONSOLE_EXPORTER=false \
  cosmosemulator:latest
```

## Accessing the Monitoring UIs

- **Jaeger UI**: http://localhost:16686
- **Prometheus UI**: http://localhost:9090

## Trace Information

Cosmos DB Emulator includes comprehensive tracing for Cosmos DB operations. When OTLP exporting is enabled, you'll see traces for such operations (with a sample rate of 0.1 to make it browser-friendly).

Each trace includes detailed information such as:
- Database name
- Collection name
- Document ID (when applicable)
- Operation type and resource type
- HTTP method and path
- For queries: query text
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

Cosmos DB Emulator uses the OpenTelemetry Collector for processing telemetry data. The default configuration is:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  postgresql:
    endpoint: localhost:9712
    username: ${env:OTEL_POSTGRES_USER}
    password: ${env:OTEL_POSTGRES_PASSWORD}
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
    endpoint: jaeger:4317
    tls:
      insecure: true

  prometheus:
    endpoint: 0.0.0.0:8889

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp/traces]
    metrics:
      receivers: [postgresql, otlp]
      processors: [batch]
      exporters: [prometheus, debug]

  telemetry:
    logs:
      level: "INFO"
    metrics:
      level: "normal"
```

For custom configuration, you can override this file by mounting your own configuration file when running the container:

```bash
docker run -d --name pgcosmos \
  -v $(pwd)/custom-otel-config.yaml:/etc/otel/config.yaml \
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

## Metrics Information

Cosmos DB Emulator exports the following metrics to Prometheus (via OpenTelemetry Collector on port 8889):

### Gateway Metrics

1. **`PGCosmos_Request_total`** (Counter)
   - Total number of requests processed
   - Labels: `Emulator_ID`, `Release_Version`

2. **`PGCosmos_Query_Local_total`** (Counter)
   - Query operations by type
   - Labels: `Query_Type` (e.g., "ReadFeed.Database", "Create.Document")

### PostgreSQL Metrics (optional)

3. **`postgresql_backends`** - Active connections
4. **`postgresql_commits_total`** - Total commits
5. **`postgresql_db_size_bytes`** - Database size
6. **`postgresql_operations_total`** - Database operations

### Example Prometheus Queries

```promql
# Total requests
PGCosmos_Request_total

# Requests per second
rate(PGCosmos_Request_total[1m])

# Query operations by type
sum by(Query_Type) (PGCosmos_Query_Local_total)
```

Alternatively, you can query metrics from the command line:
`curl -s http://localhost:8889/metrics | grep "^PGCosmos_"`
