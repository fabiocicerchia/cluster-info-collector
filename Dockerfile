# cluster-info-collector — support-bundle collector (logs, events, resource
# dumps) for incident snapshots. Run it once, get a tarball of evidence.
ARG KUBECTL_VERSION=1.33.2

FROM alpine:3.22@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce AS fetch
ARG KUBECTL_VERSION
ARG TARGETOS=linux
ARG TARGETARCH=amd64
# Versions pinned for alpine 3.22; dependabot/renovate bumps them.
RUN apk add --no-cache curl=8.14.1-r2 ca-certificates=20260611-r0
RUN curl -fsSLo /kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
 && chmod 0755 /kubectl

FROM alpine:3.22@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce
LABEL org.opencontainers.image.title="cluster-info-collector" \
      org.opencontainers.image.description="Support-bundle collector: logs, events, resource dumps for incident snapshots" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/cluster-info-collector"
RUN apk add --no-cache bash=5.2.37-r0 tar=1.35-r3 gzip=1.14-r1 aws-cli=2.27.25-r0 ca-certificates=20260611-r0 \
 && adduser -D -u 10001 collector
COPY --from=fetch /kubectl /usr/local/bin/kubectl
COPY collect /usr/local/bin/collect
USER 10001
# Run-once collector: it starts, writes a bundle, and exits — nothing to poll.
HEALTHCHECK NONE
ENTRYPOINT ["/usr/local/bin/collect"]
