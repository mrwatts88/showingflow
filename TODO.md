# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: define Terraform apply policy and add billing safeguards before EKS work.

## Apply Policy

- Decide whether Terraform `apply` remains manual for now.
- If `apply` moves toward CI later, define the guardrails first.
- Decide what branch or environment protections are required before CI-driven apply.

## Billing Guardrails

- Add at least one monthly AWS Budget with alert thresholds.
- Add a forecasted budget alert so spend is flagged before the monthly limit is crossed.
- Add AWS Cost Anomaly Detection alerts for unusual spend.
- Document the chosen billing guardrails once they exist.

## Backend Follow-Through

- Decide whether the bootstrap state bucket config should remain a separate local-state layer.
- Decide whether the backend bucket needs additional hardening beyond versioning, encryption, and public-access blocking.

## Follow-Through After Terraform Is Production-Shaped

- Keep the docs current once the Terraform workflow has been verified in GitHub.
- Then decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Revisit whether a remote backend strategy is sufficient before creating EKS resources.
