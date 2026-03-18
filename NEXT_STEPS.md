# Next Steps

This file is the live handoff for the next session. It should be updated whenever a meaningful chunk of work is completed.

## Last Completed

- Added a multi-stage Dockerfile for `services/showingflow-api`.
- Switched Spring datasource config to support `SPRING_DATASOURCE_*` environment variable overrides with local defaults.
- Expanded Docker Compose so the API and PostgreSQL can run together as a local stack.
- Added `COMMANDS.md` and `DETAILS.md` to document runtime flows and system behavior.
- Added a minimal Terraform configuration for an AWS ECR repository in `infra`.
- Added `.dockerignore` for `services/showingflow-api`.
- Applied Terraform and created the `showingflow-api` ECR repository in AWS.
- Built, tagged, and pushed the API image manually to ECR.
- Added the first GitHub Actions workflow to run the Spring API test suite and build the API image.
- Added Terraform definitions for GitHub Actions OIDC and an IAM role for ECR push from CI.
- Updated the GitHub Actions workflow to assume the AWS role via OIDC and push a commit-SHA-tagged image to ECR on `push` to `main`.
- Verified in GitHub that the workflow successfully pushed an updated image to ECR.
- Updated the workflow to also tag and push `latest` on `main`.

## Current Verified State

- The Spring API service exists in `services/showingflow-api`.
- The `brokerages` slice is implemented end to end.
- PostgreSQL can run by itself in Docker Compose.
- The full local stack can run in Docker Compose with:
  - `postgres` as the database service
  - `api` as the Spring container
- The containerized API connects to PostgreSQL by service name using:
  - `jdbc:postgresql://postgres:5432/showingflow`
- The API also supports host-run mode with local defaults using:
  - `jdbc:postgresql://localhost:5432/showingflow`
- Host ports in Compose are configurable with:
  - `SHOWINGFLOW_POSTGRES_PORT`
  - `SHOWINGFLOW_API_PORT`
- The repository now has a minimal Terraform entry point in `infra/main.tf` for creating the `showingflow-api` ECR repository in `us-east-2`.
- The ECR repository exists in AWS account `409415529879`.
- A manual ECR push path has been verified:
  - AWS CLI authentication works
  - Docker can log in to ECR
  - the API image can be tagged and pushed to `showingflow-api`
- ECR currently contains a tagged `latest` image plus related OCI artifacts from the push.
- The repository now contains `.github/workflows/api-test.yml` for API test execution and Docker image build in GitHub Actions.
- Terraform now defines AWS-side GitHub OIDC trust for:
  - repository `mrwatts88/showingflow`
  - branch `main`
  - IAM role `github-actions-showingflow-ecr-push`
- The workflow is now configured to:
  - request `id-token: write`
  - assume `github-actions-showingflow-ecr-push`
  - log in to ECR
  - tag the image with the short commit SHA and `latest`
  - push both tags to ECR on `push` to `main`
- That CI publish path has been observed working end to end in GitHub Actions.

## Recommended Next Tasks

1. Push this workflow change and verify that `main` now publishes both commit-SHA and `latest` tags to ECR.
2. Start the first Kubernetes deployment artifact, likely a simple manifest or Helm chart that references the ECR image.
3. Decide whether to keep Terraform state local for now or introduce a remote backend before EKS work grows.

## Risks And Gaps

- `README.md` likely lags behind the current containerized runtime setup.
- There is still only one implemented domain slice.
- CI/CD does not exist yet.
- CI now includes a proven ECR publish path, but deployment beyond image publishing does not exist yet.
- The new `latest` tag behavior has not yet been re-verified in GitHub from this session.
- The worker service, frontend, infrastructure, and observability remain mostly planned rather than implemented.
- Terraform state is currently local and should be treated carefully until a remote backend strategy exists.

## Resume Commands

Start the full stack:

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

Start the full stack on alternate host ports:

```bash
SHOWINGFLOW_POSTGRES_PORT=5433 SHOWINGFLOW_API_PORT=8081 \
docker compose -f docker/docker-compose.yml up -d --build
```

Run PostgreSQL only, then run the API on the host:

```bash
docker compose -f docker/docker-compose.yml up -d postgres
cd services/showingflow-api
./gradlew bootRun
```

Check health:

```bash
curl http://localhost:8080/actuator/health
```

Stop the stack:

```bash
docker compose -f docker/docker-compose.yml down
```

Initialize Terraform:

```bash
cd infra
terraform init
```

Preview and apply the ECR repository:

```bash
terraform plan
terraform apply
```

Manual ECR push flow:

```bash
docker build -t showingflow-api -f services/showingflow-api/Dockerfile services/showingflow-api
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 409415529879.dkr.ecr.us-east-2.amazonaws.com
IMAGE_TAG=$(git rev-parse --short HEAD)
docker tag showingflow-api:latest 409415529879.dkr.ecr.us-east-2.amazonaws.com/showingflow-api:${IMAGE_TAG}
docker push 409415529879.dkr.ecr.us-east-2.amazonaws.com/showingflow-api:${IMAGE_TAG}
```

Current CI workflow:

```bash
.github/workflows/api-test.yml
```

## Verification Notes

- The Compose file was validated with `docker compose config`.
- The full stack was brought up successfully in Compose.
- Compose verification required using an alternate PostgreSQL host port on this machine because port `5432` was already in use locally.
- API container logs showed successful Spring startup, Flyway migration execution, and a live database connection to `postgres:5432`.
- `terraform init` and `terraform apply` were run successfully and created the ECR repository in AWS.
- Docker authenticated to ECR successfully using `aws ecr get-login-password`.
- The API image was tagged and pushed to ECR successfully.
- `aws ecr describe-images --repository-name showingflow-api --region us-east-2` confirmed the tagged image plus related OCI artifacts in the repository.
- The GitHub Actions workflow was observed succeeding in GitHub, including AWS OIDC auth and pushing an updated image to ECR.
- The new `latest` tagging and push logic exists in the workflow but has not yet been observed in GitHub from this session.
