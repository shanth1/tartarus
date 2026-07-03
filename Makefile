.PHONY: help build start stop restart shell zshell logs status check-sec init env prepare-configs clean clean-image prune backup

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
	@mkdir -p $(WORKSPACE_DIR) $(STATE_DIR) $(CONFIGS_DIR)/ssh $(CONFIGS_DIR)/git
	@touch $(CONFIGS_DIR)/git/.gitconfig
	@chmod 700 $(CONFIGS_DIR)/ssh
	@chmod 600 $(CONFIGS_DIR)/ssh/* 2>/dev/null || true

init: ## setup zsh and ai tools internally
	@docker exec -it $(CONTAINER_NAME) /usr/local/bin/setup_shell.sh
	@docker exec -it $(CONTAINER_NAME) /usr/local/bin/setup_opencode.sh

##@ lifecycle

build: ## build image
	@docker build -t $(IMAGE_NAME) .

start: prepare-configs ## start daemon
	@docker run -d \
		--name $(CONTAINER_NAME) \
		--hostname $(HOSTNAME) \
		--restart always \
		--env-file .env \
		$(PORT_MAP) \
		-v $(WORKSPACE_DIR):/workspace \
		-v $(STATE_DIR):/root/.openclaw \
		-v $(CONFIGS_DIR)/ssh:/root/.ssh:ro \
		-v $(CONFIGS_DIR)/git/.gitconfig:/root/.gitconfig:ro \
		$(IMAGE_NAME)

stop: ## stop and remove container
	@docker stop $(CONTAINER_NAME) || true
	@docker rm $(CONTAINER_NAME) || true

restart: stop start ## reload container

##@ maintenance & access

backup: ## backup openclaw state with timestamp
	@mkdir -p $(BACKUP_DIR)
	@eval TIMESTAMP=`date +%Y%m%d_%H%M%S`; \
	tar -czf $(BACKUP_DIR)/openclaw_$$TIMESTAMP.tar.gz -C $(PROJECT_ROOT) .openclaw; \
	echo "backup saved to $(BACKUP_DIR)/openclaw_$$TIMESTAMP.tar.gz"

shell: ## bash
	@docker exec -it $(CONTAINER_NAME) /bin/bash

zshell: ## zsh
	@docker exec -it $(CONTAINER_NAME) /bin/zsh

logs: ## view startup logs
	@docker logs -f $(CONTAINER_NAME)

status: ## resource monitoring
	@docker stats $(CONTAINER_NAME)

check-isolation: ## test isolation
	@docker exec -it $(CONTAINER_NAME) bash -c "ls -la /Users 2>/dev/null || echo 'SUCCESS: mac host isolated.'"
