# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repo.

## Project

`cluster-info-collector` is a support-bundle collector for Kubernetes incident
snapshots. It's a single Bash script (`collect`) that dumps nodes, events,
resources, `describe`s, per-container logs (current + previous crash), and
`kubectl top`, tars them with a UTC timestamp, and optionally ships the bundle
to S3. Secret **names** are listed; secret **data is never collected**. Shipped
as a minimal Alpine image; runs as a one-shot Kubernetes Job
(`manifests/job.yaml`) or via `docker run`. Entry point: `collect`.

## Commands

```sh
# build: make build            # docker build
# test:  make test             # build + ./test.sh smoke test
# lint:  make lint             # hadolint + shellcheck
# run:   ./collect [namespace ...]   # or: docker run … cluster-info-collector
make help      # Show this help
make setup     # Install the pre-commit hook
make build     # Build the image locally
make lint      # hadolint + shellcheck
make test      # Build + smoke test
make test-unit # Unit tests for lib.sh, no docker/kubectl required
make push      # Push single-arch image
make release   # Build & push multi-arch image + latest
```

## Tooling

- `make setup` installs the pre-commit hook, and that is the whole of it.
  Don't add a `.githooks/` directory: `core.hooksPath` replaces `.git/hooks/`
  wholesale, so setting it silently stops every pre-commit hook from running.
- Hooks are pinned by commit SHA with the tag in a trailing comment. A tag can
  be moved, a SHA cannot.
- CI runs this same `.pre-commit-config.yaml` through `pre-commit/action`, so
  what passes locally is what gates the pull request.

## Conventions

- Match existing style; don't reformat unrelated code. `collect` is `set -euo
  pipefail` Bash with 2-space indent; every `kubectl` call ends in `|| true`
  so collection degrades gracefully with no cluster.
- Conventional Commits for messages (see CONTRIBUTING.md); they drive the
  release-please version bump. `CHANGELOG.md` is generated — don't edit it.
- Update `docs/`, `examples/`, and the README config table with behavior changes.
- Never commit secrets; CI runs gitleaks. Keep `.env` out of git.

## Guardrails

- Don't add dependencies without a clear reason; prefer POSIX/stdlib. Keep the
  runtime image small and its apk versions pinned (dependabot bumps them).
- Never collect secret **data** — names only.
- Keep the RBAC in `manifests/job.yaml` scoped to exactly what `collect` reads;
  add kinds there if the script grows.
- Ask before large refactors or destructive operations.
