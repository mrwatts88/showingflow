# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: make the current system easier to operate and better understood before choosing the next EKS hardening step.

## Makefile

- Create a top-level `Makefile`.
- Include the real commands for local API work, Docker Compose, Terraform, EKS access, Kubernetes apply, and endpoint verification.
- Keep the targets grounded in commands that already work in this repo.

## EKS And Kubernetes Understanding

- Walk through the current EKS Terraform in detail and explain what each AWS resource is doing.
- Walk through the Kubernetes manifest in detail and explain how the API, Postgres, service discovery, and load balancing work.
- Capture the important tradeoffs in plain English so future hardening decisions are informed.

## Likely Hardening Decisions After The Review

- Decide whether worker nodes should move into private subnets.
- Decide whether the control plane public access CIDR should be narrowed from `0.0.0.0/0`.
- Decide whether PostgreSQL should move to a more durable setup next.
- Decide whether the Kubernetes deployment should stop using the floating `latest` image tag.
