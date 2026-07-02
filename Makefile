.PHONY: help build start stop restart shell zshell logs status check-sec init env prepare-configs clean clean-image prune

# --- configuration ---
CONTAINER_NAME := tartarus
IMAGE_NAME := tartarus-core
HOSTNAME := tartarus

# local paths
PROJECT_ROOT := $(shell pwd)
WORKSPACE_DIR := $(PROJECT_ROOT)/workspace
CONFIGS_DIR := $(PROJECT_ROOT)/configs

# port mapping (host:container) - block of 10 ports for agents
PORT_MAP := -p 18000-18010:8000-8010

help: ## show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1musage:\033[0m\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } \
	/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ setup & initialization

env: ## create .env file from example
	@cp -n .env.example .env || true

prepare-configs: ## ensure directories and files exist with correct permissions before starting
	@mkdir -p $(WORKSPACE_DIR)
	@mkdir -p $(CONFIGS_DIR)/ssh
	@if [ -d "$(CONFIGS_DIR)/gitconfig" ]; then rm -rf "$(CONFIGS_DIR)/gitconfig"; fi
	@touch $(CONFIGS_DIR)/gitconfig
	@chmod 700 $(CONFIGS_DIR)/ssh
	@chmod 600 $(CONFIGS_DIR)/ssh/* 2>/dev/null || true

init: ## setup zsh, locales and ai agents inside container
	@echo "initializing container environment..."
	@docker exec -it $(CONTAINER_NAME) /usr/local/bin/setup_shell.sh
	@docker exec -it $(CONTAINER_NAME) /usr/local/bin/setup_opencode.sh

##@ container lifecycle

build: ## build docker image
	@echo "building $(IMAGE_NAME)..."
	@docker build -t $(IMAGE_NAME) .

start: prepare-configs ## start daemon with mounted workspace, configs, and env
	@echo "starting $(CONTAINER_NAME)..."
	@docker run -d \
		--name $(CONTAINER_NAME) \
		--hostname $(HOSTNAME) \
		--restart always \
		--env-file .env \
		$(PORT_MAP) \
		-v $(WORKSPACE_DIR):/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(CONFIGS_DIR)/ssh:/root/.ssh:ro \
		-v $(CONFIGS_DIR)/gitconfig:/root/.gitconfig:ro \
		$(IMAGE_NAME)
	@echo "$(CONTAINER_NAME) is running."

stop: ## stop and remove container
	@docker stop $(CONTAINER_NAME) || true
	@docker rm $(CONTAINER_NAME) || true

restart: stop start ## safely restart container and reload .env

##@ cleanup & maintenance

clean: stop ## stop container and remove it (preserves workspace data and image)
	@echo "container cleaned."

clean-image: clean ## completely remove the tartarus docker image
	@docker rmi $(IMAGE_NAME) || true
	@echo "image removed. you will need to run 'make build' again."

prune: ## clean up unused docker networks, dangling images, and build cache
	@echo "pruning docker system..."
	@docker system prune -f

##@ access & monitoring

shell: ## enter container with bash
	@docker exec -it $(CONTAINER_NAME) /bin/bash

zshell: ## enter container with zsh
	@docker exec -it $(CONTAINER_NAME) /bin/zsh

logs: ## tail container logs
	@docker logs -f $(CONTAINER_NAME)

status: ## show container resources
	@docker stats $(CONTAINER_NAME)

##@ security & network tests

check-sec: ## test filesystem isolation
	@echo "=== checking isolation ==="
	@docker exec -it $(CONTAINER_NAME) bash -c "ls -la /Users 2>/dev/null || echo 'SUCCESS: mac host is isolated.'"
