# cluster-info-collector — support-bundle collector (logs, events, resource
# dumps) for incident snapshots. Run it once, get a tarball of evidence.
ARG KUBECTL_VERSION=1.33.2

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS fetch
ARG KUBECTL_VERSION
ARG TARGETOS=linux
ARG TARGETARCH=amd64
# Versions pinned for alpine 3.24; dependabot/renovate bumps them.
RUN apk add --no-cache curl=8.21.0-r0 ca-certificates=20260611-r0
# pipefail so the checksum comparison below can't be silently skipped
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN curl -fsSLo /kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
 && curl -fsSLo /kubectl.sha256 "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl.sha256" \
 && echo "$(cat /kubectl.sha256)  /kubectl" | sha256sum -c - \
 && chmod 0755 /kubectl

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
LABEL org.opencontainers.image.title="cluster-info-collector" \
      org.opencontainers.image.description="Support-bundle collector: logs, events, resource dumps for incident snapshots" \
      org.opencontainers.image.licenses="Apache-2.0 AND GPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/cluster-info-collector"
RUN apk add --no-cache bash=5.3.9-r1 tar=1.35-r5 gzip=1.14-r2 aws-cli=2.34.63-r0 ca-certificates=20260611-r0 \
 && adduser -D -u 10001 collector
COPY --from=fetch /kubectl /usr/local/bin/kubectl
COPY collect lib.sh /usr/local/bin/
USER 10001
# Run-once collector: it starts, writes a bundle, and exits — nothing to poll.
HEALTHCHECK NONE
ENTRYPOINT ["/usr/local/bin/collect"]
