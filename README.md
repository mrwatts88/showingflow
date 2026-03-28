# ShowingFlow

ShowingFlow is a small full-stack system designed to simulate a modern production software stack. The goal of the project is not primarily the product itself, but to maintain and demonstrate senior-level engineering skills across backend services, frontend applications, infrastructure, CI/CD, and observability.

The system models a simple real-estate showing platform where brokerages manage listings and availability, and buyers request showings and submit deposits. The domain is intentionally simple so that the engineering focus can remain on architecture, deployment, and system design.

## Goals

This project is built as a realistic engineering exercise. It focuses on building a complete system that resembles how modern production systems are developed and deployed.

Key goals include:

- A full stack architecture (frontend + backend services)
- Multi-tenant B2B2C style domain
- Event-driven service interaction
- Infrastructure as Code
- Kubernetes deployment
- CI/CD automation
- Production-style observability

The intention is to build the system incrementally in small daily sessions.

## High Level Architecture

The platform will consist of several components:

- **Frontend**
  A React + TypeScript web application for agents and buyers.

- **Main API Service**
  A Spring Boot service that manages core business entities such as listings, brokerages, showing slots, and appointment requests.

- **Automation / Worker Service**
  A secondary service (NestJS) responsible for background workflows such as notifications, reminders, and event processing.

- **Database**
  PostgreSQL used locally via Docker and deployed using Amazon RDS.

- **Infrastructure**
  AWS infrastructure managed using Terraform and deployed on Amazon EKS.

- **CI/CD**
  GitHub Actions for build pipelines and container publishing, with ArgoCD used for GitOps-based deployment to Kubernetes.

- **Observability**
  OpenTelemetry instrumentation with metrics, traces, and logs exposed through standard tooling.

## Core Domain (Initial MVP)

The first version of the system focuses on a minimal set of entities:

- Brokerage
- User
- Listing
- ShowingSlot
- ShowingRequest

Agents manage listings and available showing times. Buyers can request showings and later submit deposits through payment integrations.

Additional features such as payments, notifications, and audit history will be introduced after the core platform is stable.

## Technology Stack

### Backend

- Java 21
- Spring Boot
- Gradle
- Spring Web
- Spring Data JPA
- Flyway (database migrations)
- PostgreSQL
- Lombok

### Frontend

- React
- TypeScript
- Vite

### Infrastructure

- Docker (local development)
- PostgreSQL via Docker Compose
- Terraform (AWS infrastructure)
- Amazon EKS (Kubernetes)
- Helm (deployment packaging)
- ArgoCD (GitOps deployment)

### CI/CD

- GitHub Actions
- Container builds to Amazon ECR
- Automated deployments to EKS

### Observability

- Spring Boot Actuator
- OpenTelemetry
- CloudWatch / metrics pipeline

## Repository Structure

The repository is organized as a small monorepo so multiple services and infrastructure can evolve together.

```
showingflow
│
├─ services
│  ├─ showingflow-api
│  └─ showingflow-worker
│
├─ frontend
│
├─ infra
│
├─ docker
│
├─ docs
│
└─ README.md
```

## Local Development

There are currently two supported local runtime modes.

Run PostgreSQL only in Docker, then run the API on the host:

```
docker compose -f docker/docker-compose.yml up -d postgres

cd services/showingflow-api
./gradlew bootRun
```

Run the full local stack in Docker Compose:

```
docker compose -f docker/docker-compose.yml up -d --build
```

Verify the service is running:

```
http://localhost:8080/actuator/health
```

Expected response:

```
{"status":"UP"}
```

## Current Delivery Status

The project now has the first pieces of a real deployment path:

- the Spring API builds into a Docker image
- the API and PostgreSQL run together in Docker Compose
- Terraform creates an Amazon ECR repository for the API image
- a manual image push from Docker to ECR has been completed successfully
- GitHub Actions runs API tests and image builds
- on `push` to `main`, GitHub Actions authenticates to AWS through OIDC and pushes commit-SHA plus `latest` image tags to ECR
- the main Terraform root uses an S3 remote backend with lockfile-based locking
- a dedicated Terraform CI workflow now exists for `fmt`, `validate`, and `plan`
- the Terraform plan role was tightened to allow the read operations Terraform needs during CI refresh
- Terraform `fmt`, `validate`, and `plan` have now been verified in GitHub Actions
- billing guardrails now exist in AWS through Terraform-managed budget and anomaly alert resources
- Terraform `apply` remains manual-only for now
- a top-level `Makefile` now exists for the common local dev, infrastructure, EKS, and verification commands
- a minimal Amazon EKS cluster now exists in `us-east-2`
- the cluster has one managed node group with one worker node
- local `kubectl` access is configured through `aws eks update-kubeconfig`
- Kubernetes manifests now exist under `infra/k8s`
- the API and a demo PostgreSQL instance are now running in the cluster
- the API is exposed through a Kubernetes `LoadBalancer` service
- the public load balancer endpoint has been verified with a real `POST /brokerages` request

What does not exist yet:

- Helm packaging
- automated deployment to Kubernetes
- a production-grade Kubernetes data layer
- hardened EKS networking and access controls

## Future Work

Planned areas of expansion include:

- Stripe payment integration
- multi-tenant authorization
- event-driven workflow service
- email/SMS notifications
- audit and activity history
- automated container publishing and deployment
- EKS hardening and deployment refinement
- distributed tracing and metrics

## Purpose

ShowingFlow exists primarily as a hands-on system architecture project. It allows experimentation with modern backend engineering patterns while maintaining a realistic application domain.
