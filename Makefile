.DEFAULT_GOAL := help

.PHONY: \
	help \
	local-up \
	local-up-build \
	local-up-postgres \
	local-down \
	local-down-volume \
	local-logs-postgres \
	local-logs-api \
	api-run \
	api-run-docker-db \
	api-test \
	api-jar \
	api-health \
	api-create-brokerage \
	api-list-brokerages \
	api-get-brokerage \
	image-build \
	tf-init \
	tf-bootstrap-init \
	tf-bootstrap-apply \
	tf-plan \
	tf-apply \
	eks-kubeconfig \
	eks-nodes \
	k8s-apply \
	k8s-pods \
	k8s-services \
	k8s-api-logs \
	k8s-lb-host \
	k8s-health \
	k8s-create-brokerage

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "%-24s %s\n", $$1, $$2}' Makefile | sort

local-up: ## Start the local Docker Compose stack
	docker compose -f docker/docker-compose.yml up -d

local-up-build: ## Start the local Docker Compose stack and rebuild the API image
	docker compose -f docker/docker-compose.yml up -d --build

local-up-postgres: ## Start only PostgreSQL in Docker Compose
	docker compose -f docker/docker-compose.yml up -d postgres

local-down: ## Stop the local Docker Compose stack
	docker compose -f docker/docker-compose.yml down

local-down-volume: ## Stop the local Docker Compose stack and remove the volume
	docker compose -f docker/docker-compose.yml down -v

local-logs-postgres: ## Stream PostgreSQL logs from Docker Compose
	docker compose -f docker/docker-compose.yml logs -f postgres

local-logs-api: ## Stream API logs from Docker Compose
	docker compose -f docker/docker-compose.yml logs -f api

api-run: ## Run the API on the host
	cd services/showingflow-api && ./gradlew bootRun

api-run-docker-db: ## Run PostgreSQL in Docker Compose, then run the API on the host
	docker compose -f docker/docker-compose.yml up -d postgres
	cd services/showingflow-api && ./gradlew bootRun

api-test: ## Run the API test suite
	cd services/showingflow-api && ./gradlew test

api-jar: ## Build the API jar
	cd services/showingflow-api && ./gradlew bootJar

api-health: ## Hit the local API health endpoint
	curl http://localhost:8080/actuator/health

api-create-brokerage: ## Create a brokerage against the local API
	curl -X POST http://localhost:8080/brokerages \
		-H "Content-Type: application/json" \
		-d '{"name":"Compass"}'

api-list-brokerages: ## List brokerages from the local API
	curl http://localhost:8080/brokerages

api-get-brokerage: ## Get brokerage ID 1 from the local API
	curl http://localhost:8080/brokerages/1

image-build: ## Build the API Docker image
	docker build -t showingflow-api -f services/showingflow-api/Dockerfile services/showingflow-api

tf-init: ## Initialize the main Terraform root
	terraform -chdir=infra init

tf-bootstrap-init: ## Initialize the bootstrap Terraform root
	terraform -chdir=infra/bootstrap init

tf-bootstrap-apply: ## Apply the bootstrap Terraform root
	terraform -chdir=infra/bootstrap apply

tf-plan: ## Run Terraform plan for the main infrastructure
	terraform -chdir=infra plan

tf-apply: ## Apply the main Terraform root
	terraform -chdir=infra apply

eks-kubeconfig: ## Write the EKS cluster context into local kubeconfig
	aws eks update-kubeconfig --region us-east-2 --name showingflow-eks

eks-nodes: ## Show EKS nodes
	kubectl get nodes -o wide

k8s-apply: ## Apply the current Kubernetes workload
	kubectl apply -f infra/k8s/showingflow-stack.yaml

k8s-pods: ## Show Kubernetes pods in the showingflow namespace
	kubectl get pods -n showingflow -o wide

k8s-services: ## Show Kubernetes services in the showingflow namespace
	kubectl get svc -n showingflow -o wide

k8s-api-logs: ## Stream API pod logs from Kubernetes
	kubectl logs deployment/showingflow-api -n showingflow -f

k8s-lb-host: ## Print the public load balancer hostname
	kubectl get svc showingflow-api -n showingflow -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
	@printf "\n"

k8s-health: ## Hit the public health endpoint through the Kubernetes load balancer
	@LB_HOST=$$(kubectl get svc showingflow-api -n showingflow -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
	curl "http://$$LB_HOST/actuator/health"

k8s-create-brokerage: ## Create a brokerage through the Kubernetes load balancer
	@LB_HOST=$$(kubectl get svc showingflow-api -n showingflow -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
	curl -X POST "http://$$LB_HOST/brokerages" \
		-H "Content-Type: application/json" \
		-d '{"name":"Compass"}'
