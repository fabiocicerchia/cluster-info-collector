IMAGE     ?= fabiocicerchia/cluster-info-collector
VERSION   ?= 0.1.0
PLATFORMS ?= linux/amd64,linux/arm64

# Every verb this repository exposes lives here; `make` on its own prints them.
# FC-GEN-057: the same eight verbs in every repo, each either wired or a
# declared no-op that says why. None of them exit 0 quietly.

.DEFAULT_GOAL := help

.PHONY: help setup install uninstall build test lint run format analyze push release

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install the pre-commit hook
	pre-commit install

build: ## Build the image locally
	docker build -t $(IMAGE):$(VERSION) .

lint: ## Run the whole gate — every hook, every file
	pre-commit run --all-files

test: build test-unit ## Build + smoke test
	./test.sh $(IMAGE):$(VERSION)

test-unit: ## Unit tests for lib.sh, no docker/kubectl required
	./test-unit.sh

install: ## Install the tools and their man pages (DESTDIR/PREFIX honoured)
	install -d "$(DESTDIR)$(PREFIX)/bin" "$(DESTDIR)$(PREFIX)/share/man/man1"
	install -m 0755 cluster-collect "$(DESTDIR)$(PREFIX)/bin/cluster-collect"
	install -m 0644 man/cluster-collect.1 "$(DESTDIR)$(PREFIX)/share/man/man1/cluster-collect.1"
	install -d "$(DESTDIR)$(PREFIX)/lib/cluster-info-collector"
	install -m 0644 lib.sh "$(DESTDIR)$(PREFIX)/lib/cluster-info-collector/lib.sh"
	@echo "installed cluster-collect into $(DESTDIR)$(PREFIX)/bin"

uninstall: ## Remove what `make install` put down
	rm -f "$(DESTDIR)$(PREFIX)/bin/cluster-collect" "$(DESTDIR)$(PREFIX)/share/man/man1/cluster-collect.1"
	rm -f "$(DESTDIR)$(PREFIX)/lib/cluster-info-collector/lib.sh"

run: build ## Run the collector from the image (ARGS are its arguments)
	docker run --rm $(IMAGE):$(VERSION) $(ARGS)

format: ## Rewrite what the gate can fix: whitespace, line endings, final newline
	@# A fixing hook exits 1 when it rewrites a file. That is this target doing
	@# its job, not failing, so the exits are ignored — make still prints what
	@# each hook said.
	-pre-commit run --all-files trailing-whitespace
	-pre-commit run --all-files end-of-file-fixer
	-pre-commit run --all-files mixed-line-ending

analyze: ## Scan the tree the way CI does — vulnerabilities, misconfig, secrets
	@command -v trivy >/dev/null 2>&1 || { \
		echo "analyze needs trivy: https://trivy.dev/latest/getting-started/installation/" >&2; \
		exit 69; }
	trivy fs --scanners vuln,misconfig,secret --severity CRITICAL,HIGH .

push: build ## Push single-arch image
	docker push $(IMAGE):$(VERSION)

release: ## Build & push multi-arch image + latest
	docker buildx build --platform $(PLATFORMS) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
