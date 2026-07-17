#!/usr/bin/env bash
# docker-collect.sh — run cluster-info-collector against the current
# kubectl context from your laptop, without hand-assembling `docker run`.
#
# Auto-detects, from the current context: cert files the kubeconfig points
# at (so they get mounted too), and whether the API server lives on a local
# docker network (so `--network` gets set). Neither is needed for a normal
# remote cluster; both matter for minikube/kind/k3d.
#
# Usage: ./docker-collect.sh [options] [namespace ...]
#   --output DIR       bundle destination on the host   (default ./out)
#   --s3 URI            s3://bucket/prefix upload
#   --image IMAGE       image to run   (default ghcr.io/fabiocicerchia/cluster-info-collector)
#   --tag TAG            image tag      (default latest)
#   --kubeconfig PATH   kubeconfig to use (default $KUBECONFIG or ~/.kube/config)
#   --env KEY=VALUE      extra env var for collect, repeatable (LOG_TAIL_LINES, SINCE, ...)
#   --dry-run            print the docker command instead of running it
set -euo pipefail

log() { echo "docker-collect: $*" >&2; }
die() { log "$*"; exit 1; }

command -v docker >/dev/null 2>&1 || die "docker not found on PATH"
command -v kubectl >/dev/null 2>&1 || die "kubectl not found on PATH"

OUTPUT_DIR="./out"
S3_URI=""
IMAGE="ghcr.io/fabiocicerchia/cluster-info-collector"
TAG="latest"
KUBECONFIG_PATH="${KUBECONFIG:-$HOME/.kube/config}"
DRY_RUN="false"
ENV_VARS=()
NAMESPACES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    --s3) S3_URI="$2"; shift 2 ;;
    --image) IMAGE="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    --kubeconfig) KUBECONFIG_PATH="$2"; shift 2 ;;
    --env) ENV_VARS+=("$2"); shift 2 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    -h|--help) awk '/^#!/{next} /^[^#]/{exit} {print substr($0,3)}' "$0"; exit 0 ;;
    --) shift; NAMESPACES+=("$@"); break ;;
    -*) die "unknown option: $1 (see --help)" ;;
    *) NAMESPACES+=("$1"); shift ;;
  esac
done

[[ -f "$KUBECONFIG_PATH" ]] || die "kubeconfig not found: $KUBECONFIG_PATH"

# One call, four lines: CA / client-cert / client-key / server, in that order.
CTX_INFO="$(kubectl --kubeconfig "$KUBECONFIG_PATH" config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority}{"\n"}{.users[0].user.client-certificate}{"\n"}{.users[0].user.client-key}{"\n"}{.clusters[0].cluster.server}{"\n"}' 2>/dev/null || true)"
mapfile -t CTX_LINES <<<"$CTX_INFO"
CA_PATH="${CTX_LINES[0]:-}"
CLIENT_CERT="${CTX_LINES[1]:-}"
CLIENT_KEY="${CTX_LINES[2]:-}"
SERVER="${CTX_LINES[3]:-}"

# Cert files a file-based kubeconfig points at live outside ~/.kube (e.g.
# minikube's ~/.minikube) — mount their parent dirs too. Embedded
# (*-data) certs need nothing extra.
declare -A MOUNT_DIRS=()
add_mount_dir() {
  [[ -n "$1" && "$1" == /* ]] || return 0
  MOUNT_DIRS["$(dirname "$1")"]=1
}
add_mount_dir "$CA_PATH"
add_mount_dir "$CLIENT_CERT"
add_mount_dir "$CLIENT_KEY"

# If the API server is a container on a local docker network (minikube,
# kind, k3d), find that network so the collector container can reach it.
NETWORK=""
if [[ -n "$SERVER" ]]; then
  HOST="${SERVER#*://}"
  HOST="${HOST%%:*}"
  HOST="${HOST%%/*}"
  if [[ -n "$HOST" ]]; then
    for NET in $(docker network ls -q 2>/dev/null); do
      if docker network inspect "$NET" -f '{{range .Containers}}{{.IPv4Address}} {{end}}' 2>/dev/null | grep -qF "${HOST}/"; then
        NETWORK="$(docker network inspect "$NET" -f '{{.Name}}')"
        break
      fi
    done
  fi
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR_ABS="$(cd "$OUTPUT_DIR" && pwd)"

DOCKER_ARGS=(run --rm)
[[ -n "$NETWORK" ]] && DOCKER_ARGS+=(--network "$NETWORK")
DOCKER_ARGS+=(
  --user "$(id -u):$(id -g)"
  -e "KUBECONFIG=/home/collector/.kube/config"
  -v "${KUBECONFIG_PATH}:/home/collector/.kube/config:ro"
  -v "${OUTPUT_DIR_ABS}:/out"
  -e "OUTPUT_DIR=/out"
)
for DIR in "${!MOUNT_DIRS[@]}"; do
  DOCKER_ARGS+=(-v "${DIR}:${DIR}:ro")
done
if [[ -n "$S3_URI" ]]; then
  DOCKER_ARGS+=(-e "BUNDLE_S3_URI=$S3_URI")
  [[ -d "$HOME/.aws" ]] && DOCKER_ARGS+=(-v "$HOME/.aws:/home/collector/.aws:ro")
fi
for KV in "${ENV_VARS[@]+"${ENV_VARS[@]}"}"; do
  DOCKER_ARGS+=(-e "$KV")
done
DOCKER_ARGS+=("${IMAGE}:${TAG}")
DOCKER_ARGS+=("${NAMESPACES[@]+"${NAMESPACES[@]}"}")

log "docker ${DOCKER_ARGS[*]}"
[[ "$DRY_RUN" == "true" ]] && exit 0
exec docker "${DOCKER_ARGS[@]}"
