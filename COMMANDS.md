# ShowingFlow Commands

This file tracks the CLI commands that are valid for the project in its current state.

## Prerequisites

- Java 21 for local Gradle runs
- Docker Desktop or a compatible Docker engine

## Full Stack In Docker Compose

Start the full local stack:

```bash
docker compose -f docker/docker-compose.yml up -d
```

Start the full local stack and rebuild the API image:

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

Start the full local stack on alternate host ports:

```bash
SHOWINGFLOW_POSTGRES_PORT=5433 SHOWINGFLOW_API_PORT=8081 \
docker compose -f docker/docker-compose.yml up -d --build
```

Start only PostgreSQL:

```bash
docker compose -f docker/docker-compose.yml up -d postgres
```

Stop the local stack:

```bash
docker compose -f docker/docker-compose.yml down
```

Stop the local stack and remove the volume:

```bash
docker compose -f docker/docker-compose.yml down -v
```

View PostgreSQL logs:

```bash
docker compose -f docker/docker-compose.yml logs -f postgres
```

View API logs:

```bash
docker compose -f docker/docker-compose.yml logs -f api
```

Note: in Docker Compose, the API uses `jdbc:postgresql://postgres:5432/showingflow` because `postgres` is the Compose service name on the shared Docker network.

## API On Host With PostgreSQL In Docker

Change into the API service directory:

```bash
cd services/showingflow-api
```

Run the API locally:

```bash
./gradlew bootRun
```

Run the API on the host against PostgreSQL in Docker:

```bash
docker compose -f docker/docker-compose.yml up -d postgres
cd services/showingflow-api
./gradlew bootRun
```

Run the API on the host against PostgreSQL in Docker on an alternate host port:

```bash
SHOWINGFLOW_POSTGRES_PORT=5433 docker compose -f docker/docker-compose.yml up -d postgres
cd services/showingflow-api
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/showingflow ./gradlew bootRun
```

Run the API on the host with explicit datasource overrides:

```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/showingflow \
SPRING_DATASOURCE_USERNAME=postgres \
SPRING_DATASOURCE_PASSWORD=postgres \
./gradlew bootRun
```

Run the test suite:

```bash
./gradlew test
```

Build the application jar:

```bash
./gradlew bootJar
```

Note: the integration tests use Testcontainers, so Docker must be running for `./gradlew test`.

## API Checks

Health check:

```bash
curl http://localhost:8080/actuator/health
```

Create a brokerage:

```bash
curl -X POST http://localhost:8081/brokerages \
  -H "Content-Type: application/json" \
  -d '{"name":"Compass"}'
```

List brokerages:

```bash
curl http://localhost:8080/brokerages
```

Get a brokerage by ID:

```bash
curl http://localhost:8080/brokerages/1
```

## API Image

Build the API image from the repository root:

```bash
docker build -t showingflow-api -f services/showingflow-api/Dockerfile services/showingflow-api
```

Build the API image from the service directory:

```bash
cd services/showingflow-api
docker build -t showingflow-api .
```

Run the API container against PostgreSQL exposed on the host:

```bash
docker run --rm -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/showingflow \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=postgres \
  showingflow-api
```
