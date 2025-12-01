SHELL := /bin/bash
REGISTRY ?= docker.io
GIT_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null)
IMAGE_NAME ?= $(notdir $(GIT_ROOT))
DEFAULT_BRANCH ?= main
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
PUSH ?= true

ci:
	@set -euo pipefail; \
	if [ -z "$(BRANCH_NAME)" ]; then \
		echo "Unable to determine branch name"; \
		exit 1; \
	fi; \
	if [ -z "$(IMAGE_NAME)" ]; then \
		echo "Set IMAGE_NAME to continue"; \
		exit 1; \
	fi; \
	TAGS="--tag $(REGISTRY)/$(IMAGE_NAME):$(BRANCH_NAME)"; \
	if [ "$(BRANCH_NAME)" = "$(DEFAULT_BRANCH)" ]; then \
		TAGS="$$TAGS --tag $(REGISTRY)/$(IMAGE_NAME):latest"; \
	fi; \
	if [ "$(PUSH)" = "true" ]; then \
		BUILD_FLAG="--push"; \
	else \
		BUILD_FLAG="--load"; \
	fi; \
	docker buildx build --platform linux/arm64 $$TAGS $$BUILD_FLAG .
