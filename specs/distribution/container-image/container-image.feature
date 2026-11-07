@domain:distribution @area:container-image @from:cluster-info-collector/dockerfile
Feature: Running the collector from its container image
  Gives operators a minimal, self-contained image that runs the collector unprivileged and carries every tool a collection and S3 upload need.

  Background:
    Given the operator has the cluster-info-collector container image

  @id:distribution.container-image.001 @rule:distribution.container-image.collector-is-entry-point @inferred @source:Dockerfile#ENTRYPOINT
  Scenario: Starting the image runs the collector with the given namespaces
    Given a cluster with namespaces "payments" and "checkout"
    When the operator runs the image with the arguments "payments checkout"
    Then the collector starts without any command being named
    And the namespaces "payments" and "checkout" are collected
    And the container exits once the bundle is written

  @id:distribution.container-image.002 @rule:distribution.container-image.runs-as-non-root @inferred @source:Dockerfile#USER
  Scenario: The collector runs as an unprivileged user, never root
    When the operator runs the image without overriding its user
    Then the collector runs as user id 10001
    And the collector has no root privileges inside the container

  @id:distribution.container-image.003 @rule:distribution.container-image.bundled-tooling @inferred @source:Dockerfile#RUN apk add
  Scenario: The image carries everything needed to collect, package and upload a bundle
    When the operator runs the image on a host with no Kubernetes or AWS tooling installed
    Then kubectl is available to the collector
    And tar and gzip are available to package the bundle
    And the AWS CLI is available to upload the bundle to S3

  @id:distribution.container-image.004 @rule:distribution.container-image.verified-kubectl @inferred @source:Dockerfile#fetch
  Scenario: The image only ships a kubectl whose published checksum matches
    Given the official kubectl release for the requested version and architecture
    When the operator builds the image
    Then the downloaded kubectl is checked against its published SHA-256 checksum
    And the build fails when the checksum does not match or the download fails
