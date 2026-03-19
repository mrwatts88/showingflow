# ShowingFlow Commands

This file tracks the CLI commands that are valid for the project in its current state.

## Prerequisites

- Java 21 for local Gradle runs
- Docker Desktop or a compatible Docker engine
- AWS CLI for AWS access
- Terraform for infrastructure provisioning
- GitHub Actions for CI workflows

## Full Stack In Docker Compose

Start the full local stack:

```bash
docker compose -f docker/docker-compose.yml up -d
```

Start the full local stack and rebuild the API image:

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

Start the full local stack on alternate host ports:

```bash
SHOWINGFLOW_POSTGRES_PORT=5433 SHOWINGFLOW_API_PORT=8081 \
docker compose -f docker/docker-compose.yml up -d --build
```

Start only PostgreSQL:

```bash
docker compose -f docker/docker-compose.yml up -d postgres
```

Stop the local stack:

```bash
docker compose -f docker/docker-compose.yml down
```

Stop the local stack and remove the volume:

```bash
docker compose -f docker/docker-compose.yml down -v
```

View PostgreSQL logs:

```bash
docker compose -f docker/docker-compose.yml logs -f postgres
```

View API logs:

```bash
docker compose -f docker/docker-compose.yml logs -f api
```

Note: in Docker Compose, the API uses `jdbc:postgresql://postgres:5432/showingflow` because `postgres` is the Compose service name on the shared Docker network.

## API On Host With PostgreSQL In Docker

Change into the API service directory:

```bash
cd services/showingflow-api
```

Run the API locally:

```bash
./gradlew bootRun
```

Run the API on the host against PostgreSQL in Docker:

```bash
docker compose -f docker/docker-compose.yml up -d postgres
cd services/showingflow-api
./gradlew bootRun
```

Run the API on the host against PostgreSQL in Docker on an alternate host port:

```bash
SHOWINGFLOW_POSTGRES_PORT=5433 docker compose -f docker/docker-compose.yml up -d postgres
cd services/showingflow-api
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/showingflow ./gradlew bootRun
```

Run the API on the host with explicit datasource overrides:

```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/showingflow \
SPRING_DATASOURCE_USERNAME=postgres \
SPRING_DATASOURCE_PASSWORD=postgres \
./gradlew bootRun
```

Run the test suite:

```bash
./gradlew test
```

Build the application jar:

```bash
./gradlew bootJar
```

Note: the integration tests use Testcontainers, so Docker must be running for `./gradlew test`.

## GitHub Actions

Current workflow:

- `.github/workflows/api-test.yml` runs the Spring API test suite and builds the API Docker image on pushes and pull requests that touch the API service or the workflow itself.
- On `push` to `main`, the workflow also:
  - assumes the AWS OIDC role
  - logs in to ECR
  - tags the image with the short Git commit SHA and `latest`
  - pushes both tags to ECR

## API Checks

Health check:

```bash
curl http://localhost:8080/actuator/health
```

Create a brokerage:

```bash
curl -X POST http://localhost:8080/brokerages \
  -H "Content-Type: application/json" \
  -d '{"name":"Compass"}'
```

List brokerages:

```bash
curl http://localhost:8080/brokerages
```

Get a brokerage by ID:

```bash
curl http://localhost:8080/brokerages/1
```

## API Image

Build the API image from the repository root:

```bash
docker build -t showingflow-api -f services/showingflow-api/Dockerfile services/showingflow-api
```

Build the API image from the service directory:

```bash
cd services/showingflow-api
docker build -t showingflow-api .
```

Run the API container against PostgreSQL exposed on the host:

```bash
docker run --rm -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/showingflow \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=postgres \
  showingflow-api
```

## Terraform

Change into the Terraform directory:

```bash
cd infra
```

Initialize Terraform:

```bash
terraform init
```

Initialize the bootstrap Terraform for the state bucket:

```bash
terraform -chdir=bootstrap init
```

Create the S3 bucket used for remote Terraform state:

```bash
terraform -chdir=bootstrap apply
```

Migrate the main infra state into the S3 backend:

```bash
terraform init -migrate-state -force-copy
```

Preview the ECR repository creation:

```bash
terraform plan
```

Create the ECR repository:

```bash
terraform apply
```

Destroy the ECR repository:

```bash
terraform destroy
```

Apply the GitHub Actions OIDC provider and ECR push role:

```bash
terraform apply
```

Current backend model:

- `infra/bootstrap` manages the S3 state bucket
- `infra` uses the S3 backend at `showingflow-terraform-state-409415529879-us-east-2`
- the main infra state key is `infra/terraform.tfstate`
- backend locking is enabled with `use_lockfile = true`

## Amazon ECR

Authenticate Docker to ECR:

```bash
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 409415529879.dkr.ecr.us-east-2.amazonaws.com
```

Tag the local image as `latest` for ECR:

```bash
docker tag showingflow-api:latest 409415529879.dkr.ecr.us-east-2.amazonaws.com/showingflow-api:latest
```

Tag the local image with the current commit SHA for ECR:

```bash
IMAGE_TAG=$(git rev-parse --short HEAD)
docker tag showingflow-api:latest 409415529879.dkr.ecr.us-east-2.amazonaws.com/showingflow-api:${IMAGE_TAG}
```

Push the `latest` tag:

```bash
docker push 409415529879.dkr.ecr.us-east-2.amazonaws.com/showingflow-api:latest
```

Push the current commit SHA tag:

```bash
IMAGE_TAG=$(git rev-parse --short HEAD)
docker push 409415529879.dkr.ecr.us-east-2.amazonaws.com/showingflow-api:${IMAGE_TAG}
```

List images in the ECR repository:

```bash
aws ecr list-images --repository-name showingflow-api --region us-east-2
```

Describe images in the ECR repository:

```bash
aws ecr describe-images --repository-name showingflow-api --region us-east-2
```

## GitHub Actions AWS Auth

Terraform now defines:

- a GitHub Actions OIDC provider in AWS
- an IAM role named `github-actions-showingflow-ecr-push`

The role is intended for:

- repository: `mrwatts88/showingflow`
- branch: `main`
