# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: keep the manual Terraform apply policy disciplined while planning the first EKS-facing infrastructure slice.

## Apply Policy

- Keep `terraform apply` manual-only for now.
- If `apply` moves toward CI later, define the guardrails first.
- Require branch/environment protections before CI-driven apply is even considered.

## Billing Guardrails

- Verify the live monthly AWS Budget in the console.
- Verify the live anomaly monitor and daily anomaly email subscription in the console.
- Revisit thresholds later if the `$25` budget or `$5` anomaly threshold prove too noisy or too weak.

## Backend Follow-Through

- Decide whether the bootstrap state bucket config should remain a separate local-state layer.
- Decide whether the backend bucket needs additional hardening beyond versioning, encryption, and public-access blocking.

## EKS Direction

- Decide what the first EKS-facing Terraform slice should be.
- Keep that first slice small enough that manual reviewed apply remains practical.

## Follow-Through After Terraform Is Production-Shaped

- Keep the docs current once the Terraform workflow has been verified in GitHub.
- Then decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Revisit whether a remote backend strategy is sufficient before creating EKS resources.
