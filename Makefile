.PHONY: help build start stop restart zshell logs sys-status sys-restart env prepare-configs backup

# --- configuration ---
CONTAINER_NAME := tartarus
IMAGE_NAME := tartarus-image
HOSTNAME := tartarus

# local paths
PROJECT_ROOT := $(shell pwd)
CONFIGS_DIR := $(PROJECT_ROOT)/.configs
STATE_DIR := $(PROJECT_ROOT)/.openclaw
WORKSPACE_DIR := $(PROJECT_ROOT)/.workspace
BACKUP_DIR := $(PROJECT_ROOT)/.backups

# port mapping (host:container) - block of 100 ports for agents
PORT_MAP := -p 18000-18100:8000-8100

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1musage:\033[0m\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ setup

env: ## scaffold .env
	@cp -n .env.example .env || true

prepare-configs: ## ensure directories and permissions
	@mkdir -p $(WORKSPACE_DIR) $(STATE_DIR) $(CONFIGS_DIR)/ssh $(CONFIGS_DIR)/git $(BACKUP_DIR)
	@touch $(CONFIGS_DIR)/git/.gitconfig
	@chmod 700 $(CONFIGS_DIR)/ssh
	@find $(CONFIGS_DIR)/ssh -type f -exec chmod 600 {} \; 2>/dev/null || true

##@ lifecycle

build: ## build image
	@docker build -t $(IMAGE_NAME) .

start: prepare-configs ## start environment (always-on)
	@docker run -d \
		--name $(CONTAINER_NAME) \
		--hostname $(HOSTNAME) \
		--restart unless-stopped \
		--env-file .env \
		$(PORT_MAP) \
		-v $(WORKSPACE_DIR):/workspace \
		-v $(STATE_DIR):/root/.openclaw \
		-v $(CONFIGS_DIR)/ssh:/root/.ssh:ro \
		-v $(CONFIGS_DIR)/git/.gitconfig:/root/.gitconfig:ro \
		$(IMAGE_NAME)

stop: ## stop and remove container safely
	@docker stop $(CONTAINER_NAME) || true
	@docker rm $(CONTAINER_NAME) || true

restart: stop start ## reload entire container

##@ maintenance & agents

zshell: ## enter environment terminal
	@docker exec -it $(CONTAINER_NAME) /bin/zsh

sys-status: ## check background agents status (Supervisor)
	@docker exec -it $(CONTAINER_NAME) supervisorctl status

sys-restart: ## restart background agents without restarting container
	@docker exec -it $(CONTAINER_NAME) supervisorctl restart all

logs: ## view supervisor system logs
	@docker logs -f $(CONTAINER_NAME)

backup: ## backup openclaw state
	@eval TIMESTAMP=`date +%Y%m%d_%H%M%S`; \
	tar -czf $(BACKUP_DIR)/openclaw_$$TIMESTAMP.tar.gz -C $(PROJECT_ROOT) .openclaw; \
	echo "backup saved to $(BACKUP_DIR)/openclaw_$$TIMESTAMP.tar.gz"
