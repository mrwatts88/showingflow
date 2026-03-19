# ShowingFlow Details

This file is meant to be a learning resource, not just a status note. It explains the system in plain English as it exists today, why it is structured the way it is, and what each part is doing.

## Brief Overview

ShowingFlow is a small monorepo for a real-estate showing platform. The business domain is intentionally simple. The real purpose of the project is to practice building a backend system with a production-shaped architecture and delivery path.

Today, the project already proves several important things:

- a Spring Boot API can boot, validate requests, talk to PostgreSQL, and persist real data
- database schema changes are managed through Flyway migrations
- the API can run both locally on the host and in Docker
- the API image can be built locally and in GitHub Actions
- the image can be pushed to Amazon ECR manually and from CI
- GitHub Actions can authenticate to AWS through OIDC instead of long-lived AWS keys

That is a strong early foundation. It means the project is no longer just application code. It has the beginnings of real runtime, packaging, and cloud delivery discipline.

## What The System Is Trying To Become

The long-term target is a small but complete production-style platform with:

- a Spring API
- additional services as needed
- a frontend
- AWS-managed infrastructure
- CI/CD automation
- observability
- eventually Kubernetes and EKS

The project is not there yet. The important point is that the path toward that shape is already visible in the codebase and docs.

## Repository Shape

The repo is a monorepo. That matters because application code, infrastructure code, and documentation are evolving together in one place.

The important directories today are:

- `services/showingflow-api`
  The main Spring Boot application
- `docker`
  Local Docker Compose runtime for PostgreSQL and the API
- `infra`
  Terraform infrastructure definitions
- `.github/workflows`
  GitHub Actions workflows

There are also placeholder areas for broader system growth such as frontend, worker services, and future infrastructure work.

## What Exists Today

The main implemented system is the Spring API service in `services/showingflow-api`.

That service currently has:

- Spring Boot 4
- Java 21
- Gradle
- Spring Web MVC
- Spring Data JPA
- Bean Validation
- Flyway
- PostgreSQL
- Spring Actuator

The first implemented domain slice is `brokerages`.

That slice currently supports:

- `POST /brokerages`
- `GET /brokerages`
- `GET /brokerages/{id}`

This matters because it proves a complete vertical path:

- a request enters the controller
- the request body is validated
- the service layer handles application logic
- the repository persists data
- PostgreSQL stores the data
- the response is returned with structured error handling where needed

That is the first real checkpoint for a serious backend system. It is more valuable than having many shallow endpoints.

## How The API Is Structured

The API is intentionally not written as a pile of controllers and entities.

The brokerage slice is structured with separate concerns:

- web models for HTTP input and output
- service-level command/result types
- persistence entities and repositories
- feature-local exception handling

That separation is important because it keeps:

- HTTP concerns from leaking everywhere
- database models from becoming the public API
- business logic from getting trapped in controllers

This is a common senior-level backend pattern: keep feature slices coherent and keep boundaries explicit.

## Database And Schema Management

PostgreSQL is the system of record.

The important design choice is that schema ownership belongs to Flyway, not Hibernate.

That means:

- database changes happen through versioned SQL migrations
- schema history is explicit
- environments can be upgraded in a controlled way
- the ORM does not silently create or mutate schema behind your back

Hibernate is configured with `ddl-auto: validate`, which is the correct posture for a production-oriented system. It checks that the code matches the database, but it does not attempt to own the database lifecycle.

The first migration creates the `brokerages` table.

## Testing Strategy

The project already uses the right kind of early tests.

Instead of relying on mocks or an in-memory substitute database, the main integration test uses:

- Spring Boot test support
- MockMvc
- Testcontainers
- real PostgreSQL
- Flyway migrations during test startup

That proves much more than a toy unit test:

- the application context boots
- the database wiring works
- migrations apply
- validation behaves correctly
- error handling is real
- data can be written and read back through the full stack

This is one of the strongest engineering choices in the project so far.

## Runtime Modes

The system currently supports two useful local runtime modes.

### 1. API On Host, Database In Docker

In this mode:

- PostgreSQL runs in Docker
- the API runs on your machine with Gradle
- the API connects to PostgreSQL through `localhost`

This mode is best for normal development because the app can be restarted quickly while the database stays isolated and repeatable.

### 2. Full Stack In Docker Compose

In this mode:

- PostgreSQL runs in one container
- the API runs in another container
- Docker Compose provides shared networking and startup orchestration
- the API connects to PostgreSQL by service name: `postgres`

This mode is best for proving the application behaves like a real containerized service rather than only working from an IDE-driven host environment.

## Why Environment Variables Matter

The datasource configuration is environment-driven through standard Spring properties:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

The application also provides sensible local defaults.

That combination matters because the same code can run in different places:

- on a developer laptop
- in Docker Compose
- in CI
- later in Kubernetes

This is a core production habit: keep code stable, vary configuration by environment.

## Docker And Image Packaging

The API has a multi-stage Dockerfile.

That means:

- one image stage builds the Spring Boot jar with Java 21
- another, smaller runtime image runs the built artifact

Why this matters:

- image builds are reproducible
- the runtime image is leaner than the build image
- the same packaging approach works locally and in CI

This is the bridge from “application code” to “deployable artifact.”

## Amazon ECR And Image Registry Flow

The project now has a real image registry path in AWS.

Terraform created an ECR repository named `showingflow-api`.

The image flow now exists in two forms:

### Manual Path

The manual path has already been proven:

- build the image with Docker
- log Docker into ECR through the AWS CLI
- tag the image for the ECR repository
- push the image

This is important because it proved the artifact path before CI automation was added.

### CI Path

The CI path is also now real:

- GitHub Actions runs the Spring tests
- GitHub Actions builds the Docker image
- on `push` to `main`, GitHub Actions assumes an AWS role through OIDC
- GitHub Actions logs in to ECR
- GitHub Actions tags and pushes the image

The workflow currently publishes:

- a short commit-SHA tag
- `latest`

That means the project now has a credible, working build-and-publish pipeline for the API image.

## GitHub Actions And OIDC

A very important production-style decision has already been made here.

CI does not use stored long-lived AWS access keys.

Instead:

- AWS trusts GitHub's OIDC provider
- Terraform defines an IAM role for GitHub Actions
- GitHub Actions requests an OIDC token
- AWS issues short-lived credentials for that run

Why this matters:

- no static AWS secrets are sitting in GitHub
- access is temporary
- the trust policy can be restricted
- the current trust is limited to this repository and the `main` branch

This is a much better security posture than the older secret-key pattern.

That same pattern is now used for two separate CI concerns:

- image publishing to ECR
- Terraform planning for the main infrastructure root

## What Terraform Is Doing Today

Terraform currently manages the first AWS slices:

- the ECR repository
- the GitHub OIDC provider
- the IAM role used by GitHub Actions for ECR push

That means Terraform is already part of the system, not a future idea.

Terraform now also has a remote backend for the main infrastructure state.

The current backend model is split into two layers:

- `infra/bootstrap`
  A small bootstrap Terraform config that creates the S3 bucket used for Terraform state
- `infra`
  The main infrastructure config, which now stores its state in that S3 bucket

The main infra backend uses:

- S3 for remote state storage
- versioning on the bucket
- encryption at rest
- public access blocking
- lockfile-based state locking with `use_lockfile = true`

That is a meaningful improvement because the main infrastructure state is no longer local-only.

However, Terraform is still not fully production-shaped yet.

That means:

- the bootstrap layer still needs to be handled carefully
- the Terraform CI workflow exists, but it has not yet been observed running in GitHub
- plan visibility is still limited because the current plan job only runs on `push` to `main`
- apply policy is still informal
- EKS would still add too much complexity if Terraform process discipline does not improve further

This is why Terraform maturity is now the right next initiative.

The next layer of maturity has now started as well:

- GitHub Actions has a dedicated Terraform workflow
- Terraform formatting and validation can run in CI
- the main `infra` root can run `terraform plan` in CI using a dedicated OIDC-backed IAM role

This is the right sequence. First get shared state. Then get CI visibility and safety checks. Only after that consider stronger automation such as CI-driven apply.

## Why Terraform Maturity Comes Before EKS

It is tempting to go straight from ECR to Kubernetes, but that would be backward.

Before EKS work grows, Terraform should become more production-ready:

- remote backend for shared durable state
- CI checks such as `fmt`, `validate`, and `plan`
- a deliberate policy for when `terraform apply` is allowed

Why that matters:

- infrastructure changes should have the same discipline as application builds
- shared state becomes the source of truth instead of one laptop
- infra plans become reviewable
- risky automation can be gated properly before the AWS footprint gets larger

This is the right “next layer of seriousness” for the project.

## What Is Still Missing

The project is still early. It is not yet a full production system.

Still missing:

- more domain slices such as listings, users, and showing slots
- worker service behavior
- frontend implementation
- verified Terraform planning in GitHub and a deliberate apply policy
- Kubernetes deployment artifacts
- EKS infrastructure
- broader observability
- security and authorization design beyond the current CI trust path

That is normal. The project already has enough shape to make the next steps meaningful.

## How To Think About The Current State

The best summary is this:

ShowingFlow is now a real backend foundation with:

- disciplined schema management
- realistic integration testing
- containerized runtime
- cloud image registry
- CI-based image publishing to AWS

That is a very solid base.

The next challenge is not “write random new features.” It is to keep improving the operational maturity of the system in the right order.

## Related Files

- `README.md`
  High-level project framing
- `CURRENT_STATUS.md`
  Current checkpoint and assessment
- `COMMANDS.md`
  Commands that actually work today
- `NEXT_STEPS.md`
  Active handoff for the next session
- `TODO.md`
  Current initiative checklist
