# Basic Example

What it shows: collect one namespace from your laptop using the published
image and your local kubeconfig, writing the bundle to the current directory.

## Run

```sh
docker run --rm \
  -v ~/.kube:/home/collector/.kube:ro \
  -v "$PWD":/out \
  -e OUTPUT_DIR=/out \
  ghcr.io/fabiocicerchia/cluster-info-collector:latest payments
```

The tarball appears as `./cluster-bundle-<UTC-timestamp>.tar.gz`. Add
`-e BUNDLE_S3_URI=s3://bucket/prefix/` (and mount AWS creds) to upload instead.
