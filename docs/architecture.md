# Architecture

## Overview

One Bash script, `collect`. No daemon, no state — it runs once, writes a
timestamped tarball, and exits. Every `kubectl` call ends in `|| true` so a
single failing command (RBAC gap, missing metrics-server) never aborts the
collection.

## What the bundle contains

- **Cluster level**: `version`, `nodes -o wide`, `describe nodes`, cluster-wide
  `events`, `top nodes`, `pods -A`, `api-resources`.
- **Per namespace** (`namespaces/<ns>/`): `get all,cm,ingress,pvc,networkpolicy`,
  full `-o yaml` dump, `events`, `top pods`, and secret **names only**.
- **Per pod** (`namespaces/<ns>/logs/`): `describe pod`, and per-container logs —
  current plus `--previous` (crash) logs when `INCLUDE_PREVIOUS=true`.

## Data flow

```
collect → mktemp workdir → kubectl dumps → tar -czf bundle → [aws s3 cp]
```

## Decisions

- **Secret data is never collected** — only `get secrets` (names). This is a
  hard invariant; don't add anything that reads secret values.
- **Read-only RBAC** lives in `manifests/job.yaml`, scoped to exactly the kinds
  `collect` reads. Extend it there when the script grows.
- Runs as a **non-root** user on a **read-only root filesystem**; the bundle is
  built in an `emptyDir` mounted at `/tmp`.
