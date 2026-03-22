# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: define Terraform apply policy now that billing safeguards are in place before EKS work.

## Apply Policy

- Decide whether Terraform `apply` remains manual for now.
- If `apply` moves toward CI later, define the guardrails first.
- Decide what branch or environment protections are required before CI-driven apply.

## Billing Guardrails

- Verify the live monthly AWS Budget in the console.
- Verify the live anomaly monitor and daily anomaly email subscription in the console.
- Revisit thresholds later if the `$25` budget or `$5` anomaly threshold prove too noisy or too weak.

## Backend Follow-Through

- Decide whether the bootstrap state bucket config should remain a separate local-state layer.
- Decide whether the backend bucket needs additional hardening beyond versioning, encryption, and public-access blocking.

## Follow-Through After Terraform Is Production-Shaped

- Keep the docs current once the Terraform workflow has been verified in GitHub.
- Then decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Revisit whether a remote backend strategy is sufficient before creating EKS resources.
