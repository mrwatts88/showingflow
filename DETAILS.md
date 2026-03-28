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
- a real EKS cluster can run the API behind a public AWS load balancer
- local `kubectl` access to that cluster works

That is a strong early foundation. It means the project is no longer just application code. It has the beginnings of real runtime, packaging, and cloud delivery discipline.

## What The System Is Trying To Become

The long-term target is a small but complete production-style platform with:

- a Spring API
- additional services as needed
- a frontend
- AWS-managed infrastructure
- CI/CD automation
- observability
- a more mature Kubernetes runtime

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
- `infra/k8s`
  Kubernetes manifests for the current demo workload
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

## Makefile And Operator Commands

The repository now has a top-level `Makefile`.

This does not replace the underlying commands. It collects the commands that already work and gives them one obvious operator entry point.

That matters because a growing system becomes harder to operate if every workflow has to be reconstructed from docs each session.

The current `Makefile` groups the real commands for:

- local Docker Compose runtime
- host-run API development
- API tests and jar builds
- Terraform init, plan, and apply
- EKS kubeconfig and node access
- Kubernetes workload apply and inspection
- public endpoint verification

This is the right kind of convenience layer. It reduces friction without hiding the actual tools underneath.

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

## What EKS Is Doing Today

The project now has its first live Kubernetes runtime in AWS.

Terraform currently creates:

- a dedicated VPC for EKS
- two public subnets
- an internet gateway and public routing
- an EKS control plane
- one managed node group
- an EKS access entry that gives the local IAM user cluster-admin access

The current cluster is intentionally small:

- cluster name: `showingflow-eks`
- one node group: `showingflow-general`
- exactly one worker node
- worker instance type: `t3.small`

This was a deliberate tradeoff. The goal was to prove the end-to-end Kubernetes path with the smallest practical AWS footprint, not to jump straight to a hardened production topology.

## How Local kubectl Access Works

The cluster does not rely on the old `aws-auth` ConfigMap approach.

Instead, Terraform creates:

- an EKS access entry for `arn:aws:iam::409415529879:user/cli`
- an EKS cluster-admin policy association for that principal

Then local access is established with:

- `aws eks update-kubeconfig --region us-east-2 --name showingflow-eks`

That writes the cluster context into the local kubeconfig so normal `kubectl` commands work.

This matters because it proves the cluster is not just present in AWS. It is actually manageable from the local development machine.

## What Is Running In Kubernetes

The current Kubernetes manifest is intentionally simple and lives in `infra/k8s/showingflow-stack.yaml`.

It creates:

- a `showingflow` namespace
- a PostgreSQL `Deployment`
- a PostgreSQL `ClusterIP` service
- a `showingflow-api` `Deployment`
- a `showingflow-api` `LoadBalancer` service

The API container uses the same environment-driven Spring datasource model as the rest of the project:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

In Kubernetes, those point the API at the in-cluster Postgres service:

- `jdbc:postgresql://postgres.showingflow.svc.cluster.local:5432/showingflow`

That is a useful checkpoint because it proves the same application artifact can run:

- on the host
- in Docker Compose
- in GitHub Actions image builds
- in EKS

## Public Endpoint And Load Balancing

The API is currently exposed with a Kubernetes service of type `LoadBalancer`.

In EKS, that causes AWS to provision a public load balancer and route HTTP traffic to the API pod on port `8080`.

This has already been verified in two ways:

- `/actuator/health` returned `200`
- a real `POST /brokerages` request through the public load balancer succeeded and returned a persisted brokerage record

That is an important distinction. The public endpoint is not just alive at the infrastructure level. It has been proven to serve application traffic end to end.

## What Terraform Is Doing Today

Terraform currently manages the first AWS slices:

- the ECR repository
- the GitHub OIDC provider
- the IAM role used by GitHub Actions for ECR push
- the EKS cluster, node group, and supporting network/IAM resources
- billing guardrails through budget and anomaly detection resources

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

Terraform is no longer just image-registry infrastructure. It now manages a real running compute environment.

However, the EKS setup is intentionally not production-grade yet.

That means:

- the bootstrap layer still needs to be handled carefully
- the Terraform CI workflow is now verified in GitHub for `fmt`, `validate`, and `plan`
- plan visibility is still limited because the current plan job only runs on `push` to `main`
- apply is now manual-only by policy, but stronger guardrails do not exist yet
- the cluster currently uses public subnets only
- the control plane currently allows public access from `0.0.0.0/0`
- the node group is intentionally minimal and not highly available

That Terraform maturity work is what made the first EKS slice reasonable.

The next layer of maturity has now started as well:

- GitHub Actions has a dedicated Terraform workflow
- Terraform formatting and validation can run in CI
- the main `infra` root can run `terraform plan` in CI using a dedicated OIDC-backed IAM role
- the Terraform plan role now includes the extra read permissions Terraform needed during resource refresh, including ECR tag reads and IAM attached-policy listing

This is the right sequence. First get shared state. Then get CI visibility and safety checks. Only after that consider stronger automation such as CI-driven apply.

## Terraform Apply Policy

The current Terraform apply policy is intentionally conservative.

For now:

- `terraform apply` is manual only
- it should be run from a trusted local machine
- it should target the `main` branch state, not an arbitrary local divergence
- it should happen only after a fresh `terraform plan` has been reviewed
- it should happen only after the latest Terraform CI run is green

Why this is the current policy:

- the project now has remote state and CI planning, which is enough to make manual apply disciplined
- it does not yet have GitHub environment protections, approval gates, or a mature release process for infrastructure mutation
- EKS would add enough cost and blast radius that CI-driven apply would be premature right now

This is a normal intermediate stage for a production-shaped system:

- shared remote state
- CI `fmt`, `validate`, and `plan`
- manual reviewed apply
- only later, if needed, gated CI apply

## Billing Guardrails

The billing guardrails are now live in the Terraform root.

What is live now:

- a monthly AWS Budget named `showingflow-monthly-cost`
- budget amount set to `$25`
- an actual spend email alert at `80%`
- a forecasted spend email alert at `100%`
- a Cost Anomaly Detection monitor named `showingflow-service-anomaly-monitor`
- a daily anomaly email subscription named `showingflow-daily-anomaly-email`
- anomaly alerts configured for absolute anomaly impact `>= $5`

Those alerts go to:

- `mattryanwatts@gmail.com`

One nuance: AWS automatically created a default anomaly monitor and subscription when Cost Explorer was enabled. Those default resources were deleted in the console so that the Terraform-managed monitor could become the single source of truth.

## Why This EKS Shape Is Only A First Slice

The cluster is real and useful, but several shortcuts were taken to keep the first slice small and affordable.

Important current limitations:

- worker nodes are in public subnets
- there is no NAT/private-subnet topology
- the Kubernetes service is a direct public `LoadBalancer`
- PostgreSQL runs inside the cluster as a single pod
- PostgreSQL storage is `emptyDir`, so it is ephemeral
- the API deployment currently uses the `latest` image tag rather than an immutable release reference

Those are acceptable choices for a first proving step. They are not the final target architecture.

This is how the system should be understood right now:

- the Kubernetes path is proven
- the cost-conscious starter shape is deliberate
- the next work is hardening and durability, not proving that EKS can run the app at all

For this project, the most sensible hardening order is not “most infrastructure first.”

The better next steps are the cheaper, higher-signal ones:

- stop deploying `latest`
- improve manifest and deployment packaging
- separate runtime configuration more cleanly

That work improves operational discipline without immediately increasing AWS cost through NAT, private-subnet redesign, or managed database infrastructure.

## What Is Still Missing

The project is still early. It is not yet a full production system.

Still missing:

- more domain slices such as listings, users, and showing slots
- worker service behavior
- frontend implementation
- a hardened EKS network topology
- a durable database strategy for cloud runtime
- Helm packaging or a cleaner deployment packaging story
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
- a live EKS cluster
- local `kubectl` access
- a publicly reachable API endpoint running in Kubernetes

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
