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
  `collect` reads. Extend it there when the script grows — and in
  `chart/values.yaml`, which mirrors it. The chart used to default to
  `apiGroups: ["*"], resources: ["*"]`, i.e. cluster-wide read on secrets too,
  which made the invariant above unverifiable for anyone installing with Helm.
- **Neither RBAC grants `secrets`.** `collect` runs `kubectl get secrets` for
  the name list, so under both it writes a Forbidden error to
  `secret-names.txt` rather than a list — the same graceful degradation every
  other command relies on, and visible in the bundle.

  There is no RBAC verb for "names but not data": `list` on secrets returns
  whole objects over the API, base64 payload and all, and `kubectl` simply
  declines to print it in table form. So granting it costs the invariant, and
  the rule is commented into `chart/values.yaml` for an operator who decides
  that trade is worth one file.
- Runs as a **non-root** user on a **read-only root filesystem**; the bundle is
  built in an `emptyDir` mounted at `/tmp`.
