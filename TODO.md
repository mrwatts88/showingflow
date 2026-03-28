# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: use the new top-level `Makefile` and a deeper EKS review to understand the current system before choosing the next hardening step.

## Makefile Follow-Through

- Use the new top-level `Makefile` as the default operator surface.
- Use the teardown targets when the cluster does not need to stay live between sessions.
- Refine target names or add missing targets if the next EKS/Kubernetes review exposes gaps.
- Keep the targets grounded in commands that already work in this repo.

## EKS And Kubernetes Understanding

- Walk through the current EKS Terraform in detail and explain what each AWS resource is doing.
- Walk through the Kubernetes manifest in detail and explain how the API, Postgres, service discovery, and load balancing work.
- Capture the important tradeoffs in plain English so future hardening decisions are informed.

## Likely Hardening Decisions After The Review

- Stop deploying Kubernetes with the floating `latest` image tag.
- Decide how the Kubernetes deployment should consume an explicit image version.
- Separate runtime configuration from the raw manifest more cleanly.
- Decide whether the next packaging step should be Kustomize, Helm, or a smaller templating approach.

## Higher-Cost Hardening Later

- Decide later whether worker nodes should move into private subnets.
- Decide later whether the control plane public access CIDR should be narrowed from `0.0.0.0/0`.
- Decide later whether PostgreSQL should move to a more durable infrastructure option such as RDS.
