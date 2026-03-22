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
- Created a bootstrap Terraform config for the remote state bucket and migrated the main infra state to an S3 backend with lockfile-based locking.
- Added a dedicated Terraform GitHub Actions workflow and Terraform CI IAM role for `fmt`, `validate`, and `plan`.
- Fixed the Terraform CI role policy after the first workflow run exposed missing refresh permissions for ECR tag reads and IAM attached-policy listing.
- Fixed the Terraform CI role policy again after a later workflow run exposed missing Cost Explorer anomaly read permissions.
- Verified in GitHub that the Terraform CI workflow now succeeds for `fmt`, `validate`, and `plan`.
- Applied a monthly AWS Budget for billing alerts.
- Enabled Cost Explorer, removed the AWS-created default anomaly resources, and applied the Terraform-managed anomaly monitor and anomaly subscription successfully.
- Defined the Terraform apply policy as manual-only for the current phase of the project.
- Added a first EKS Terraform slice with VPC, public subnets, cluster, node group, and local access entry.
- Applied the EKS infrastructure successfully in AWS.
- Added a Kubernetes manifest for in-cluster PostgreSQL and the API service.
- Verified local `kubectl` access to the cluster.
- Verified the public API endpoint through the AWS load balancer with a real `POST /brokerages` request.

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
- The main `infra` state is now stored remotely in S3:
  - bucket `showingflow-terraform-state-409415529879-us-east-2`
  - key `infra/terraform.tfstate`
  - `use_lockfile = true`
- The repository now contains `.github/workflows/terraform-ci.yml`.
- The dedicated Terraform CI role exists in AWS:
  - `github-actions-showingflow-terraform-plan`
- The Terraform CI workflow has been observed succeeding in GitHub Actions for:
  - `terraform fmt`
  - `terraform validate`
  - `terraform plan`
- The workflow is now configured to:
  - request `id-token: write`
  - assume `github-actions-showingflow-ecr-push`
  - log in to ECR
  - tag the image with the short commit SHA and `latest`
  - push both tags to ECR on `push` to `main`
- That CI publish path has been observed working end to end in GitHub Actions.
- The account now has a live AWS Budget:
  - `showingflow-monthly-cost`
  - `$25` monthly limit
  - `80%` actual email alert
  - `100%` forecasted email alert
- The account now also has live Terraform-managed Cost Anomaly Detection resources:
  - monitor `showingflow-service-anomaly-monitor`
  - subscription `showingflow-daily-anomaly-email`
  - anomaly threshold `>= $5` absolute impact
- A live EKS cluster now exists:
  - cluster `showingflow-eks`
  - node group `showingflow-general`
  - desired worker count `1`
- Local `kubectl` access works through:
  - `aws eks update-kubeconfig --region us-east-2 --name showingflow-eks`
- The current Kubernetes workload exists in `infra/k8s/showingflow-stack.yaml`.
- The cluster currently runs:
  - one PostgreSQL pod exposed internally as `postgres`
  - one API pod exposed publicly as `showingflow-api`
- The public `LoadBalancer` service has been verified end to end:
  - `/actuator/health` returned `200`
  - `POST /brokerages` returned a created brokerage payload
- `terraform -chdir=infra plan` now returns `No changes` after the EKS apply.

## Recommended Next Tasks

1. Create a top-level `Makefile` that gathers the real day-to-day commands for local development, infrastructure, Kubernetes, and verification into one operator entry point.
2. Review the current EKS and Kubernetes setup in detail and document the important moving parts so the system can be explained and reasoned about at a senior level.
3. Only after that review, decide which hardening change should come first: network shape, database durability, or image pinning.

## Risks And Gaps

- There is still only one implemented domain slice.
- The cluster is intentionally cheap rather than production-grade:
  - worker nodes are in public subnets
  - the control plane currently allows public access from `0.0.0.0/0`
  - there is only one worker node
- PostgreSQL is currently running inside the cluster with `emptyDir` storage, so it is not durable.
- The Kubernetes deployment currently uses the floating `latest` image tag.
- The worker service, frontend, infrastructure, and observability remain mostly planned rather than implemented.
- Terraform apply is intentionally manual-only, so infrastructure changes still depend on local operator discipline.
- EKS now exists, but hardening and durability work still need to happen before calling the cluster production-ready.

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

Initialize and apply the bootstrap state bucket config:

```bash
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply
```

Migrate the main infra state into the S3 backend:

```bash
terraform init -migrate-state -force-copy
```

Preview and apply the main infrastructure:

```bash
terraform plan
terraform apply
```

Configure local access to EKS:

```bash
aws eks update-kubeconfig --region us-east-2 --name showingflow-eks
kubectl get nodes -o wide
```

Apply the Kubernetes workload:

```bash
kubectl apply -f infra/k8s/showingflow-stack.yaml
kubectl get pods -n showingflow -o wide
kubectl get svc -n showingflow -o wide
```

Check the current public endpoint:

```bash
LB_HOST=$(kubectl get svc showingflow-api -n showingflow -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl "http://${LB_HOST}/actuator/health"
curl -X POST "http://${LB_HOST}/brokerages" \
  -H "Content-Type: application/json" \
  -d '{"name":"Compass"}'
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

Terraform CI workflow:

```bash
.github/workflows/terraform-ci.yml
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
- The remote state bucket was created successfully in S3.
- `terraform init -migrate-state -force-copy` succeeded for the main infra config.
- `terraform -chdir=infra plan` returned `No changes` after migration, confirming the remote backend is working.
- The Terraform CI workflow was added in code and the Terraform CI IAM role was applied in AWS.
- The first GitHub run exposed missing read permissions for Terraform refresh, and the plan role policy was updated in AWS to add `ecr:ListTagsForResource` and `iam:ListAttachedRolePolicies`.
- The Terraform workflow rerun was observed succeeding in GitHub for `fmt`, `validate`, and `plan`.
- A later CI refresh failure exposed missing Cost Explorer read permissions, and the plan role policy was updated in AWS to add `ce:GetAnomalyMonitors` and `ce:GetAnomalySubscriptions`.
- `terraform -chdir=infra validate` succeeded for the billing-guardrail changes.
- `terraform -chdir=infra plan` showed three new billing resources: one budget, one anomaly monitor, and one anomaly subscription.
- `terraform -chdir=infra apply -auto-approve` created the budget successfully.
- After Cost Explorer was enabled, Terraform still could not create the service monitor until the AWS-created default anomaly monitor and subscription were deleted from the console.
- A final `terraform -chdir=infra apply -auto-approve` created the Terraform-managed anomaly monitor and subscription successfully.
- `terraform -chdir=infra validate` succeeded for the EKS changes.
- `terraform -chdir=infra apply -auto-approve` created the VPC, IAM, EKS cluster, node group, and access entry successfully.
- `terraform -chdir=infra plan` returned `No changes` after the EKS apply.
- `aws eks update-kubeconfig --region us-east-2 --name showingflow-eks` succeeded.
- `kubectl get nodes -o wide` showed one Ready worker node.
- `kubectl apply -f infra/k8s/showingflow-stack.yaml` created the namespace, Postgres service/deployment, API deployment, and `LoadBalancer` service.
- `kubectl logs deployment/showingflow-api -n showingflow --tail=200` showed successful Spring startup and Flyway migration execution against in-cluster PostgreSQL.
- The public load balancer endpoint returned `200` from `/actuator/health`.
- A real `POST /brokerages` request through the public load balancer returned a created brokerage payload.

## Next Initiative

The next initiative is to make the current system easier to operate and better understood before changing its shape again.

The most valuable follow-through now is:

- add a top-level `Makefile` for the real operator and development commands
- study the current EKS and Kubernetes setup until each piece is understood clearly at a senior level
- then choose the next hardening step from a position of understanding rather than guesswork

The important shift is that EKS is no longer hypothetical. The cluster and public service already work. The next session should focus first on operability and understanding, then on refinement and hardening.
