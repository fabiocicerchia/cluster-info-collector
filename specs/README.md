# Specifications of cluster-info-collector

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## Bundle Packaging & Delivery
Turning the collected files into a shareable artifact and getting it where it needs to go.

- **Bundle archive**: [Packaging the bundle](bundle-delivery/bundle-archive/bundle-archive.feature) (1)
- **S3 upload**: [Shipping the bundle to S3](bundle-delivery/s3-upload/s3-upload.feature) (2)
- **Size budget**: [Keeping the bundle within a size budget](bundle-delivery/size-budget/bundle-size-budget.feature) (3), [Capping bundle size](bundle-delivery/size-budget/size-budget.feature) (1)

## Cluster Snapshot
What the collector captures from a Kubernetes cluster to describe the state at incident time.

- **Cluster overview**: [Capturing cluster-wide facts](cluster-snapshot/cluster-overview/cluster-overview.feature) (1)
- **Container logs**: [Collecting container logs](cluster-snapshot/container-logs/container-logs.feature) (2)
- **Graceful degradation**: [Collecting when the cluster is unreachable](cluster-snapshot/graceful-degradation/graceful-degradation.feature) (2)
- **Namespace scope**: [Choosing which namespaces to collect](cluster-snapshot/namespace-scope/namespace-scope.feature) (2)

## Data Protection
Keeping sensitive values out of the support bundle.

- **Secret value redaction**: [Redacting secret-like values in dumps](data-protection/secret-redaction/secret-redaction.feature) (1), [Redacting secret-like values from describe and resource dumps](data-protection/secret-redaction/secret-value-redaction.feature) (4)

## Developer Tooling
Build, quality checks and docs that support people working on the project.

- **Unit tests**: [Running the unit test suite](developer-tooling/unit-tests/unit-test-suite.feature) (3)

## Distribution & Installation
How users obtain the collector.

- **Container image**: [Running the collector from its container image](distribution/container-image/container-image.feature) (4)
- **One-line installer**: [Installing the collector with one command](distribution/one-line-installer/one-line-installer.feature) (3)

## Running the Collector
The ways an operator launches a collection against a cluster.

- **Laptop wrapper**: [Running a collection from a laptop](running-the-collector/laptop-wrapper/laptop-wrapper.feature) (6)
- **Local cluster connectivity**: [Reaching local development clusters](running-the-collector/local-cluster-connectivity/local-cluster-connectivity.feature) (2)
- **Wrapper errors and exit codes**: [Telling wrapper failures apart](running-the-collector/wrapper-exit-codes/wrapper-exit-codes.feature) (2)
