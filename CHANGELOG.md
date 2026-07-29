# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 (2026-07-29)


### Features

* add docker-collect.sh wrapper for local kubectl context ([d830181](https://github.com/fabiocicerchia/cluster-info-collector/commit/d830181e8bcfd3859820807d01c985c857542556))
* add install.sh one-liner installer ([5df31f3](https://github.com/fabiocicerchia/cluster-info-collector/commit/5df31f3eb8151863943dbaa36e5bbe0c2123ef38))
* add REDACT_ENV pass for secret-like env var values ([9893da0](https://github.com/fabiocicerchia/cluster-info-collector/commit/9893da081f9cb9d27bc7c5c25b5f98e7fa236623))
* add SINCE time-boxing and MAX_BUNDLE_MB size budget ([a1042de](https://github.com/fabiocicerchia/cluster-info-collector/commit/a1042de287ce33e67282b3b67fa59d748cc49151))


### Bug Fixes

* allow multi-document manifests/job.yaml and follow shellcheck source ([f781366](https://github.com/fabiocicerchia/cluster-info-collector/commit/f781366f937fad00daac25d798fd71d10a382f86))
* suppress SC2044 on find-based loops (paths are k8s object names, not arbitrary input) ([353726e](https://github.com/fabiocicerchia/cluster-info-collector/commit/353726e88e9bb04cd6ff92ba7ee027d7a678023e))

## [Unreleased]

## [0.1.0]

### Added

- `collect` script: cluster + namespace snapshot (nodes, events, resource
  dumps, describes, current + previous container logs, `kubectl top`).
- Optional upload of the resulting bundle to S3 via `BUNDLE_S3_URI`.
- Kubernetes Job manifest (`manifests/job.yaml`) for in-cluster runs.

[Unreleased]: https://github.com/fabiocicerchia/cluster-info-collector/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fabiocicerchia/cluster-info-collector/releases/tag/v0.1.0
