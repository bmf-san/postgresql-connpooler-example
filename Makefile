.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

up=docker-compose up -d
down=docker-compose down

.PHONY: up
up: ## Start containers.
	@$(up)

.PHONY: down
down: ## Stop containers.
	@$(down)

.PHONY: open
open: ## Open services.
	@open http://localhost:3001
	@open http://localhost:9090
	@open http://localhost:8089
