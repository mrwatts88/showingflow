# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: make Terraform production-ready before EKS work begins.

## Terraform State And Backend

- Choose the remote backend approach for Terraform state.
- Create the backend infrastructure needed for remote state.
- Move Terraform state out of local `terraform.tfstate`.
- Decide how state locking will work for this repo.

## Terraform CI Discipline

- Add GitHub Actions checks for `terraform fmt`.
- Add GitHub Actions checks for `terraform validate`.
- Add GitHub Actions checks for `terraform plan`.
- Use OIDC for Terraform CI access as well, not static AWS secrets.

## Apply Policy

- Decide whether Terraform `apply` remains manual for now.
- If `apply` moves toward CI later, define the guardrails first.
- Decide what branch or environment protections are required before CI-driven apply.

## Follow-Through After Terraform Is Production-Shaped

- Update docs with the exact Terraform backend and CI workflow.
- Then decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Revisit whether a remote backend strategy is sufficient before creating EKS resources.
