# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: automate API image build, tag, and push to Amazon ECR from GitHub Actions.

## CI Image Pipeline

- Run the Spring test suite in CI.
- Tag images with the Git commit SHA.
- Decide whether to also publish a `latest` tag from the default branch.
- Push the image to ECR from GitHub Actions.
- Use AWS OIDC and an assumable IAM role instead of stored long-lived AWS secrets.

## Follow-Through After CI Push Works

- Update docs with the exact CI-driven image publishing flow.
- Decide whether the next step is Kubernetes manifests, Helm, or direct EKS scaffolding.
- Decide when to introduce a remote Terraform backend for state.
