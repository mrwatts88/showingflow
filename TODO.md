# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: automate API image build, tag, and push to Amazon ECR from GitHub Actions.

## CI Image Pipeline

- Decide how image tags should be consumed by deployment manifests.

## Follow-Through After CI Push Works

- Update docs with the exact CI-driven image publishing flow.
- Decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Decide when to introduce a remote Terraform backend for state.
