# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: add Terraform CI discipline now that the main infra state uses a remote backend.

## Terraform CI Discipline

- Verify GitHub Actions checks for `terraform fmt`.
- Verify GitHub Actions checks for `terraform validate`.
- Verify GitHub Actions checks for `terraform plan`.
- Verify the Terraform CI role can access the remote backend and AWS resources as expected.

## Apply Policy

- Decide whether Terraform `apply` remains manual for now.
- If `apply` moves toward CI later, define the guardrails first.
- Decide what branch or environment protections are required before CI-driven apply.

## Backend Follow-Through

- Decide whether the bootstrap state bucket config should remain a separate local-state layer.
- Decide whether the backend bucket needs additional hardening beyond versioning, encryption, and public-access blocking.

## Follow-Through After Terraform Is Production-Shaped

- Keep the docs current once the Terraform workflow has been verified in GitHub.
- Then decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Revisit whether a remote backend strategy is sufficient before creating EKS resources.
