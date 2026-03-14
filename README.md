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

PostgreSQL is run locally using Docker.

Start the database:

```
docker compose up -d
```

Run the Spring Boot service:

```
cd services/showingflow-api
./gradlew bootRun
```

Verify the service is running:

```
http://localhost:8080/actuator/health
```

Expected response:

```
{"status":"UP"}
```

## Future Work

Planned areas of expansion include:

- Stripe payment integration
- multi-tenant authorization
- event-driven workflow service
- email/SMS notifications
- audit and activity history
- containerized deployment
- Kubernetes infrastructure
- distributed tracing and metrics

## Purpose

ShowingFlow exists primarily as a hands-on system architecture project. It allows experimentation with modern backend engineering patterns while maintaining a realistic application domain.
