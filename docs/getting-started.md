# Getting Started

## Prerequisites

- `kubectl` with a working kubeconfig (context pointing at the cluster).
- For S3 upload: `aws` CLI with credentials, plus a `BUNDLE_S3_URI`.
- To run in-cluster instead: just `kubectl apply` the Job manifest.

## Run

Locally against your current context — collect everything:

```sh
./collect
```

Scope to specific namespaces and ship to S3:

```sh
BUNDLE_S3_URI=s3://incidents/2026-07-10-api-outage/ ./collect payments checkout
```

In-cluster, during an incident (RBAC ships with the manifest):

```sh
kubectl apply -f manifests/job.yaml
kubectl logs -f job/cluster-info-collector -n cluster-info-collector
```

The bundle lands at `$OUTPUT_DIR/cluster-bundle-<UTC-timestamp>.tar.gz`
(default `/tmp`). See the config table in the [README](README.md) for all knobs.
