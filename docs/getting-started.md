# Getting Started

## Prerequisites

- `kubectl` with a working kubeconfig (context pointing at the cluster).
- For S3 upload: `aws` CLI with credentials, plus a `BUNDLE_S3_URI`.
- To run in-cluster instead: just `kubectl apply` the Job manifest.

## Run

Locally against your current context, without Docker — collect everything:

```sh
./collect
```

Scope to specific namespaces and ship to S3:

```sh
BUNDLE_S3_URI=s3://incidents/2026-07-10-api-outage/ ./collect payments checkout
```

From your laptop via Docker instead — `docker-collect.sh` auto-detects your
current kubectl context (kubeconfig cert paths, whether the API server is on
a local docker network like minikube/kind/k3d) and builds the `docker run`
for you:

```sh
./docker-collect.sh payments checkout
```

Bundle lands in `./out`; `--dry-run` prints the resolved `docker run` command
without running it, useful for seeing exactly what it detected. The manual
`docker run ... fabiocicerchia/cluster-info-collector` form documented in the
README still works if you'd rather not use the wrapper.

In-cluster, during an incident (RBAC ships with the manifest):

```sh
kubectl apply -f manifests/job.yaml
kubectl logs -f job/cluster-info-collector -n cluster-info-collector
```

The bundle lands at `$OUTPUT_DIR/cluster-bundle-<UTC-timestamp>.tar.gz`
(default `/tmp`). See the config table in the [README](README.md) for all knobs.
