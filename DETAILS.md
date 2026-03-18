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

The infrastructure side has also now started in a minimal way:

- Terraform exists under `infra`
- the first Terraform-managed AWS resource is an ECR repository for the API image
- the ECR repository has been created in AWS
- a manual Docker login, tag, and push flow to ECR has been proven
- Terraform now also defines the GitHub Actions OIDC provider and an IAM role for CI-based ECR pushes

This is intentionally small, but it matters because it starts the path from "local Docker image" to "publishable deployment artifact."

The CI side has also now started in a minimal way:

- GitHub Actions is introduced for the API service
- the first workflow runs the Spring test suite and builds the API Docker image
- on `push` to `main`, the workflow also assumes the AWS role via OIDC and pushes the image to ECR with a commit-SHA tag

This is the correct early CI slice because it proves the repository can validate the service automatically and can reproduce the Docker build before CI is trusted with image publishing.

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

## How The AWS Image Path Works

The deployment artifact path has now started to take shape.

Right now the process is:

- build the API image locally with Docker
- authenticate Docker to Amazon ECR using the AWS CLI
- tag the local image with the ECR repository path
- push the image to the ECR repository

This has already been done manually once, which is important because it proves the path from source code to cloud image registry is real.

The next step is not to keep doing this manually forever. That automation path is now mostly in place in GitHub Actions using:

- AWS OIDC for short-lived CI credentials
- image tags based on the Git commit SHA
- optionally `latest` for a simple moving tag on the main branch later

The AWS-side trust model for that is now defined in Terraform:

- AWS trusts GitHub's OIDC provider
- only this repository is trusted
- the initial trust policy is restricted to the `main` branch
- the IAM role permissions are limited to pushing images to the `showingflow-api` ECR repository

The workflow behavior matches that trust model:

- pull requests can test and build
- only `push` to `main` can authenticate to AWS and publish an image

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

That same test path is now the first CI checkpoint as well. The initial GitHub Actions workflow runs the API tests and builds the image before push and deploy automation are introduced.

## What This Does Not Yet Have

The project is still early. It is not yet a complete production system.

Still missing:

- more domain slices such as listings, users, and showing slots
- the worker service behavior
- frontend implementation
- broader CI/CD pipeline beyond the initial API test-build-push workflow
- cloud deployment
- broader infrastructure as code beyond the first ECR slice
- tracing, logging conventions, and broader observability
- security and authorization design

So the system is production-shaped, but not production-complete.

## How To Think About The Current State

The best way to understand the project today is this:

It is a correctly structured backend foundation with a real database, real migrations, real integration testing, and a real containerized local runtime.

That is exactly the right base to build on. From here, every next step can be layered on top of something credible:

- more API slices
- CI automation
- automated container publishing
- Kubernetes deployment
- operational instrumentation

## Related Files

- `README.md` describes the broader project goal.
- `CURRENT_STATUS.md` summarizes the current implementation state.
- `COMMANDS.md` lists the commands that currently work.
- `docker/docker-compose.yml` defines the local container stack.
- `services/showingflow-api/src/main/resources/application.yaml` defines the current Spring configuration defaults and env-var overrides.
