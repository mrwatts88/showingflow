# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: automate API image build, tag, and push to Amazon ECR from GitHub Actions.

## CI Image Pipeline

- Run the Spring test suite in CI.
- Decide whether to also publish a `latest` tag from the default branch.
- Verify end-to-end GitHub Actions push to ECR using the OIDC role.
- Decide how image tags should be consumed by deployment manifests.

## Follow-Through After CI Push Works

- Update docs with the exact CI-driven image publishing flow.
- Decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Decide when to introduce a remote Terraform backend for state.
