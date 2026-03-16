# ShowingFlow Details

This file explains the system in plain English as it exists today. It is meant to be a study guide for understanding how a small but production-shaped backend system is put together, why certain choices were made, and what is still missing.

## What ShowingFlow Is

ShowingFlow is a small monorepo for a real-estate showing platform. The product domain is intentionally simple. The real purpose of the project is to practice building a system with the shape of a serious production application.

That means the project is not mainly about shipping a lot of end-user features quickly. It is about building the habits and structure of a senior-level system:

- clear service boundaries
- disciplined database migrations
- containerized local runtime
- realistic testing
- room to grow into CI/CD, cloud deployment, and observability

## What Exists Right Now

Today, the main real implementation is the Spring API service in `services/showingflow-api`.

That service currently has:

- Spring Boot 4
- Java 21
- Gradle
- PostgreSQL
- Flyway migrations
- Spring Data JPA
- Bean Validation
- Spring Actuator

The first full backend slice is `brokerages`. It supports:

- `POST /brokerages`
- `GET /brokerages`
- `GET /brokerages/{id}`

This is important because it proves the full request path works:

- HTTP request enters the controller
- request validation is applied
- service-layer logic runs
- data is saved to PostgreSQL
- Flyway controls the schema
- standardized errors are returned when needed

That is the first meaningful checkpoint for a real backend service.

## Why This Is Production-Shaped

Even though the project is still small, several decisions already match a production-oriented system:

- The database schema is owned by Flyway migrations, not by Hibernate auto-creation.
- Hibernate is set to validate the schema, not invent it.
- The code separates web DTOs, service models, and persistence entities.
- Integration tests run against real PostgreSQL through Testcontainers instead of a fake in-memory database.
- The app exposes actuator endpoints for basic operational visibility.

These are the kinds of choices that matter more than having lots of endpoints early on.

## How The System Runs

There are currently two main local runtime modes.

### 1. API On The Host, PostgreSQL In Docker (via Compose)

This is the normal development-friendly mode.

In this setup:

- PostgreSQL runs in Docker
- the Spring API runs on your machine with `./gradlew bootRun`
- the API connects to PostgreSQL through `localhost`

This is useful because application iteration is fast while the database is still isolated and repeatable.

### 2. Full Stack In Docker Compose

This is the more deployment-like local mode.

In this setup:

- PostgreSQL runs as one container
- the Spring API runs as another container
- Docker Compose places both services on the same Docker network
- the API connects to the database by service name: `postgres`

This matters because it proves the application can run as a real containerized service instead of only working through a local IDE workflow.

## Why Docker Compose Matters

Docker Compose is doing more than just starting containers.

It gives the project:

- a repeatable local stack definition
- shared networking between services
- basic startup orchestration
- service discovery by container/service name

Because of that shared network, the API container can connect to PostgreSQL with:

`jdbc:postgresql://postgres:5432/showingflow`

That hostname works because `postgres` is the Compose service name. This is standard container-to-container communication.

## Why Environment Variables Matter

The Spring service is configured so the datasource can be overridden with environment variables:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

The application config also provides defaults for local development. That means the same application can work in different environments without changing code:

- local host-run API with default `localhost`
- host-run API with explicit overrides
- containerized API with Docker Compose values

This is a core production habit. Configuration should come from the environment, while the application code stays the same.

## How The Container Setup Works

The API service has a Dockerfile that:

- builds the Spring Boot jar in a Java 21 builder image
- runs the jar in a smaller Java 21 runtime image

The Compose stack then uses that image build and provides the datasource environment variables. PostgreSQL has a health check, and the API waits for PostgreSQL to be healthy before startup.

That gives the project a real local deployment shape, not just a codebase.

## Testing Posture

The project already has an important high-value test path.

The brokerage integration test verifies:

- the Spring application boots
- PostgreSQL is available
- Flyway migrations apply
- requests can create and read data
- validation failures are returned in a standardized way
- not-found and malformed request handling works

This is a better early investment than large amounts of low-value unit testing.

## What This Does Not Yet Have

The project is still early. It is not yet a complete production system.

Still missing:

- more domain slices such as listings, users, and showing slots
- the worker service behavior
- frontend implementation
- CI/CD pipelines
- image publishing
- cloud deployment
- infrastructure as code for real environments
- tracing, logging conventions, and broader observability
- security and authorization design

So the system is production-shaped, but not production-complete.

## How To Think About The Current State

The best way to understand the project today is this:

It is a correctly structured backend foundation with a real database, real migrations, real integration testing, and a real containerized local runtime.

That is exactly the right base to build on. From here, every next step can be layered on top of something credible:

- more API slices
- CI automation
- container publishing
- Kubernetes deployment
- operational instrumentation

## Related Files

- `README.md` describes the broader project goal.
- `CURRENT_STATUS.md` summarizes the current implementation state.
- `COMMANDS.md` lists the commands that currently work.
- `docker/docker-compose.yml` defines the local container stack.
- `services/showingflow-api/src/main/resources/application.yaml` defines the current Spring configuration defaults and env-var overrides.
