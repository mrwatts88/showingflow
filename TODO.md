# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: harden the first working EKS slice without losing the small, verified public runtime.

## EKS Hardening

- Decide whether worker nodes should move into private subnets.
- Decide whether the control plane public access CIDR should be narrowed from `0.0.0.0/0`.
- Decide whether the current direct `LoadBalancer` service is the right short-term exposure model.

## Data Durability

- Replace the in-cluster `emptyDir` PostgreSQL setup with a more durable option.
- Decide whether the next step is RDS, EBS-backed stateful Kubernetes storage, or another short-term bridge.

## Deployment Shape

- Stop deploying Kubernetes with the floating `latest` image tag.
- Decide how the Kubernetes manifest should consume a specific ECR image version.

## Terraform Discipline

- Keep `terraform apply` manual-only for now.
- Keep reviewing a fresh `terraform plan` before apply.
- Revisit CI-driven apply only after stronger deployment protections exist.

## Cost Follow-Through

- Watch the live budget and anomaly alerts now that EKS resources exist.
- Revisit the `$25` budget and `$5` anomaly threshold if the cluster makes them too noisy or too weak.
