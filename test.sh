#!/usr/bin/env sh
# Smoke test: tooling present; collect degrades gracefully with no cluster
# (every kubectl call is `|| true`) and still produces a bundle.
set -eu
IMAGE="${1:?usage: test.sh <image:tag>}"
docker run --rm --entrypoint sh "$IMAGE" -c 'command -v kubectl aws tar >/dev/null && echo deps-ok'
docker run --rm --entrypoint sh "$IMAGE" -c 'NAMESPACES=none collect >/dev/null 2>&1; ls /tmp/cluster-bundle-*.tar.gz >/dev/null && echo bundle-ok'
echo PASS
