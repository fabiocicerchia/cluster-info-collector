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
```

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
