IMAGE     ?= fabiocicerchia/cluster-info-collector
VERSION   ?= 0.1.0
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: help setup build lint test test-unit push release

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install git hooks and dev tooling
	git config core.hooksPath .githooks
	@command -v pre-commit >/dev/null 2>&1 && pre-commit install || true

build: ## Build the image locally
	docker build -t $(IMAGE):$(VERSION) .

lint: ## hadolint + shellcheck
	docker run --rm -i hadolint/hadolint < Dockerfile
	shellcheck collect lib.sh test.sh test-unit.sh

test: build test-unit ## Build + smoke test
	./test.sh $(IMAGE):$(VERSION)

test-unit: ## Unit tests for lib.sh, no docker/kubectl required
	./test-unit.sh

push: build ## Push single-arch image
	docker push $(IMAGE):$(VERSION)

release: ## Build & push multi-arch image + latest
	docker buildx build --platform $(PLATFORMS) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
