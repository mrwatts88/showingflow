# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: add Terraform CI discipline now that the main infra state uses a remote backend.

## Terraform CI Discipline

- Add GitHub Actions checks for `terraform fmt`.
- Add GitHub Actions checks for `terraform validate`.
- Add GitHub Actions checks for `terraform plan`.
- Use OIDC for Terraform CI access as well, not static AWS secrets.

## Apply Policy

- Decide whether Terraform `apply` remains manual for now.
- If `apply` moves toward CI later, define the guardrails first.
- Decide what branch or environment protections are required before CI-driven apply.

## Backend Follow-Through

- Decide whether the bootstrap state bucket config should remain a separate local-state layer.
- Decide whether the backend bucket needs additional hardening beyond versioning, encryption, and public-access blocking.

## Follow-Through After Terraform Is Production-Shaped

- Update docs with the exact Terraform backend and CI workflow.
- Then decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Revisit whether a remote backend strategy is sufficient before creating EKS resources.
