# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0](https://github.com/fabiocicerchia/cluster-info-collector/compare/v0.2.1...v0.3.0) (2026-08-25)


### Features

* **docs:** build the docs site in Actions and drop Read the Docs ([#33](https://github.com/fabiocicerchia/cluster-info-collector/issues/33)) ([be8d53c](https://github.com/fabiocicerchia/cluster-info-collector/commit/be8d53c6627dac7ec7cff0e35291e9f21e7228ad))

## [0.2.1](https://github.com/fabiocicerchia/cluster-info-collector/compare/v0.2.0...v0.2.1) (2026-08-13)


### Bug Fixes

* security and code-quality findings ([#28](https://github.com/fabiocicerchia/cluster-info-collector/issues/28)) ([75581ad](https://github.com/fabiocicerchia/cluster-info-collector/commit/75581ad9827b535fde36b0880c6c54261bd88596))

## [0.2.0](https://github.com/fabiocicerchia/cluster-info-collector/compare/v0.1.0...v0.2.0) (2026-08-06)


### Features

* **chart:** add Helm chart ([ec34991](https://github.com/fabiocicerchia/cluster-info-collector/commit/ec3499125b24c827569d990d648c96b406031bbf))


### Bug Fixes

* exempt Helm templates from check-yaml ([3f685a9](https://github.com/fabiocicerchia/cluster-info-collector/commit/3f685a9334d3fcf2787753400343e27c2e5eb7ab))
* **security:** skip the SARIF upload on private repos ([1040a7f](https://github.com/fabiocicerchia/cluster-info-collector/commit/1040a7f5eb71381038199f45dd57187ad852d2b0))
* verify the kubectl download against its published checksum ([24191d3](https://github.com/fabiocicerchia/cluster-info-collector/commit/24191d375af45baedb7db6e441b51cebe761f76d))

## [Unreleased]

## [0.1.0]

### Added

- `collect` script: cluster + namespace snapshot (nodes, events, resource
  dumps, describes, current + previous container logs, `kubectl top`).
- Optional upload of the resulting bundle to S3 via `BUNDLE_S3_URI`.
- Kubernetes Job manifest (`manifests/job.yaml`) for in-cluster runs.

[Unreleased]: https://github.com/fabiocicerchia/cluster-info-collector/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fabiocicerchia/cluster-info-collector/releases/tag/v0.1.0
