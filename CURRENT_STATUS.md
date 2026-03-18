# Current Status

## Summary

ShowingFlow is established as an early-stage but correctly shaped production-style system. The repository has a clear monorepo layout, the primary Spring Boot API service is running with PostgreSQL-backed persistence, and the first vertical backend slice for `brokerages` is implemented end to end.

This is not yet a scalable system in the operational sense, but the project has crossed the first meaningful architecture checkpoint: the codebase now proves the core path from HTTP request to validated input, service orchestration, persistence, migration-managed schema, and standardized error handling.

## What Exists Today

### Repository and Platform Baseline

- Monorepo structure is in place for backend services, frontend, infrastructure, and docs.
- Root documentation defines the intended target architecture: Spring Boot API, worker service, frontend, AWS infrastructure, CI/CD, and observability.
- Local PostgreSQL development is configured through Docker Compose.
- The local runtime now supports both:
  - host-run API with PostgreSQL in Docker
  - full API + PostgreSQL execution in Docker Compose
- The `infra` directory now contains the first Terraform-managed AWS resource definition for image infrastructure.
- The first AWS infrastructure slice is live: an Amazon ECR repository for `showingflow-api` exists in `us-east-2`.
- The repository now has its first GitHub Actions workflow for API test execution and image build validation.
- Terraform now also defines GitHub Actions OIDC and an IAM role for ECR image publishing from CI.
- The GitHub Actions workflow now includes OIDC-based AWS auth and commit-SHA plus `latest` image push logic for `main`.
- The GitHub Actions workflow has now successfully published an API image to ECR.

### Main API Service

The `services/showingflow-api` service has a credible production baseline for an initial service:

- Spring Boot 4 application bootstrapped under `com.showingflow.api`
- Java 21 and Gradle selected as the backend runtime/build standard
- YAML-based Spring configuration
- Core dependencies in place:
  - Spring Web MVC
  - Spring Data JPA
  - Bean Validation
  - Flyway
  - PostgreSQL driver
  - Actuator
  - Lombok
- Multi-stage Docker image build via `Dockerfile`
- Environment-variable-driven datasource configuration with local defaults
- Manual image build, tag, and push flow to Amazon ECR has been proven
- GitHub Actions automation has started with an API test-and-build workflow
- AWS-side OIDC trust and ECR push permissions for GitHub Actions are now defined in Terraform
- CI workflow logic now exists for ECR login and commit-SHA plus `latest` image push on `main`
- End-to-end CI image publishing to ECR has been verified

### Database and Schema Management

- PostgreSQL is the system of record for the API service.
- Flyway is the sole schema management mechanism.
- Hibernate is configured with `ddl-auto: validate`, which is the correct posture for a production-oriented service where schema ownership belongs to migrations, not ORM auto-generation.
- The first migration creates the `brokerages` table.

### First Vertical Slice: Brokerage

The `brokerages` slice is implemented with clean feature-local packaging and explicit application boundaries:

- JPA entity: `Brokerage`
- Repository: `BrokerageRepository`
- Service boundary:
  - `BrokerageService`
  - `BrokerageServiceImpl`
  - `CreateBrokerageCommand`
  - `BrokerageResult`
- Web boundary:
  - `BrokerageController`
  - `CreateBrokerageRequest`
  - `BrokerageResponse`
- Exception translation:
  - `BrokerageNotFoundException`
  - `BrokerageExceptionHandler`

Implemented API behavior:

- `POST /brokerages`
- `GET /brokerages`
- `GET /brokerages/{id}`

This is not full CRUD yet, but it is a complete vertical read/create slice with the right layering.

## Engineering Quality Achieved

Several important engineering decisions are already aligned with senior-level backend practice:

- Feature-oriented packaging instead of premature cross-cutting layer buckets
- Separation between HTTP DTOs, service-layer models, and persistence entities
- Migration-owned schema management
- Explicit transaction demarcation in the service layer
- Standardized error responses for not-found, validation failure, and malformed request paths
- Real integration testing against PostgreSQL rather than relying on H2 or repository mocks

That combination is more important at this stage than adding more endpoints. It establishes a repeatable pattern for future slices.

## Test Coverage Status

The project now has an end-to-end integration test for the `brokerages` slice using:

- `MockMvc` for request-level application testing
- Testcontainers for real PostgreSQL infrastructure
- Flyway migrations applied during test startup

This proves:

- the application context boots
- the datasource is wired correctly
- migrations apply successfully
- request validation works
- standardized error responses are returned
- the API can persist and read back brokerage data through the full stack

Unit and controller-only tests are still outstanding, but the highest-value integration path is covered.

## What Is Still Missing

The project is still intentionally early relative to the stated target architecture.

Not yet implemented:

- additional domain slices such as users, listings, showing slots, and showing requests
- worker service behavior and event-driven workflows
- frontend application work
- Kubernetes deployment manifests/charts
- broader Terraform-managed AWS infrastructure beyond the initial ECR and GitHub OIDC slices
- OpenTelemetry instrumentation and broader observability
- structured logging and request correlation conventions
- broader test coverage strategy beyond the first vertical slice

## Assessment

From a senior engineering perspective, the project is in a healthy state for its age.

The important thing is not that there is a lot of code; it is that the existing code has the right shape:

- infrastructure and application concerns are separated
- the first API slice is implemented with production-credible boundaries
- the database lifecycle is disciplined
- the test strategy has started with a realistic integration path instead of toy tests
- the service can now run in a containerized local stack, which is the right bridge toward delivery work
- the first infrastructure step toward deployability now exists through Terraform-managed ECR definition and a validated manual image push path
- the first CI slice now exists through a GitHub Actions workflow that runs the API test suite and builds the image
- the AWS trust path for CI is now defined through Terraform-managed GitHub OIDC and an ECR push role
- the workflow logic for automated publish now exists and has been proven end to end in GitHub

The next major step should continue moving outward from application code and toward delivery and operations, but the priority should now be Terraform maturity rather than Kubernetes artifacts. Before EKS work grows, Terraform should move to a remote backend, gain CI checks such as `fmt`, `validate`, and `plan`, and have a deliberate policy for when `apply` is allowed. After that, the natural next layer is Kubernetes deployment and EKS automation.
