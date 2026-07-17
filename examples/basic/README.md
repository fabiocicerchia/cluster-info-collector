# Basic Example

What it shows: collect one namespace from your laptop using the published
image and your local kubeconfig, writing the bundle to the current directory.

## Run

```sh
../../docker-collect.sh payments
```

The tarball appears as `./out/cluster-bundle-<UTC-timestamp>.tar.gz`. Add
`--s3 s3://bucket/prefix/` to upload instead.

Equivalent by hand, for the manual/no-wrapper form:

```sh
docker run --rm \
  -v ~/.kube:/home/collector/.kube:ro \
  -v "$PWD":/out \
  -e OUTPUT_DIR=/out \
  ghcr.io/fabiocicerchia/cluster-info-collector:latest payments
```
