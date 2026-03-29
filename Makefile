.PHONY: help init plan apply destroy fmt validate lint security clean bootstrap

SHELL := /bin/bash
ENV ?= dev
TF_DIR := environments/$(ENV)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform for ENV (default: dev)
	cd $(TF_DIR) && terraform init

init-upgrade: ## Initialize with provider upgrade for ENV
	cd $(TF_DIR) && terraform init -upgrade

plan: ## Run Terraform plan for ENV
	cd $(TF_DIR) && terraform plan -out=tfplan

plan-target: ## Run targeted plan: make plan-target TARGET=module.networking
	cd $(TF_DIR) && terraform plan -target=$(TARGET) -out=tfplan

apply: ## Apply Terraform plan for ENV
	cd $(TF_DIR) && terraform apply tfplan

apply-auto: ## Apply with auto-approve for ENV (use with caution)
	cd $(TF_DIR) && terraform apply -auto-approve

destroy: ## Destroy infrastructure for ENV (requires confirmation)
	cd $(TF_DIR) && terraform destroy

fmt: ## Format all Terraform files
	terraform fmt -recursive

fmt-check: ## Check formatting without changes
	terraform fmt -check -recursive

validate: ## Validate Terraform configuration for ENV
	cd $(TF_DIR) && terraform init -backend=false && terraform validate

validate-all: ## Validate all environments
	@for env in dev staging prod; do \
		echo "==> Validating $$env..."; \
		(cd environments/$$env && terraform init -backend=false -input=false > /dev/null 2>&1 && terraform validate) || exit 1; \
	done

lint: ## Run TFLint
	tflint --recursive

security: ## Run Checkov security scan
	checkov -d . --framework terraform --config-file .checkov.yaml

docs: ## Generate module documentation
	terraform-docs markdown table --output-file README.md --output-mode inject modules/networking
	terraform-docs markdown table --output-file README.md --output-mode inject modules/security
	terraform-docs markdown table --output-file README.md --output-mode inject modules/iam
	terraform-docs markdown table --output-file README.md --output-mode inject modules/s3
	terraform-docs markdown table --output-file README.md --output-mode inject modules/ecr
	terraform-docs markdown table --output-file README.md --output-mode inject modules/compute
	terraform-docs markdown table --output-file README.md --output-mode inject modules/eks
	terraform-docs markdown table --output-file README.md --output-mode inject modules/ecs
	terraform-docs markdown table --output-file README.md --output-mode inject modules/rds
	terraform-docs markdown table --output-file README.md --output-mode inject modules/lambda
	terraform-docs markdown table --output-file README.md --output-mode inject modules/cloudfront
	terraform-docs markdown table --output-file README.md --output-mode inject modules/route53
	terraform-docs markdown table --output-file README.md --output-mode inject modules/monitoring

pre-commit: ## Run pre-commit hooks
	pre-commit run --all-files

bootstrap: ## Bootstrap state backend (run once)
	cd global/backend-bootstrap && terraform init && terraform apply

clean: ## Remove .terraform directories and plans
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tfplan" -delete 2>/dev/null || true
	find . -name "tfplan" -delete 2>/dev/null || true

cost: ## Estimate costs with Infracost for ENV
	infracost breakdown --path $(TF_DIR)

graph: ## Generate dependency graph for ENV
	cd $(TF_DIR) && terraform graph | dot -Tpng > ../../docs/graph-$(ENV).png
