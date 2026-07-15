# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0]

### Added

- `collect` script: cluster + namespace snapshot (nodes, events, resource
  dumps, describes, current + previous container logs, `kubectl top`).
- Optional upload of the resulting bundle to S3 via `BUNDLE_S3_URI`.
- Kubernetes Job manifest (`manifests/job.yaml`) for in-cluster runs.

[Unreleased]: https://github.com/fabiocicerchia/cluster-info-collector/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fabiocicerchia/cluster-info-collector/releases/tag/v0.1.0
