#!/usr/bin/env bash
set -euo pipefail
# One-line installer for cluster-info-collector
# Usage: curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/cluster-info-collector/main/install.sh | bash

IMAGE="ghcr.io/fabiocicerchia/cluster-info-collector:latest"

echo "Pulling cluster-info-collector from GHCR..."
docker pull "$IMAGE"
echo ""
echo "cluster-info-collector ready. Run it against a cluster with:"
echo "  docker run --rm -v ~/.kube:/home/collector/.kube:ro $IMAGE"
echo "Or, from a repo checkout, ./docker-collect.sh auto-detects your kubectl"
echo "context (kubeconfig certs, local-cluster docker networks) for you."
echo "Or apply manifests/job.yaml to run it in-cluster."
echo "See https://github.com/fabiocicerchia/cluster-info-collector for usage."
