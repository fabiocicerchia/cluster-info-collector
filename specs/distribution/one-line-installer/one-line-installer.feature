@domain:distribution @area:one-line-installer @from:cluster-info-collector/install
Feature: Installing the collector with one command
  Gives an operator a single curl-pipe command that readies the collector on their machine and tells them how to run it, so they can start an incident snapshot without reading the docs first.

  Background:
    Given the operator runs the published one-line installer from the project's README or website

  @id:distribution.one-line-installer.001 @rule:distribution.installer.pulls-latest-published-image @inferred @source:install.sh#IMAGE @questionable
  Scenario: The installer fetches the latest published collector image
    Given docker is available on the operator's machine
    And the registry ghcr.io is reachable
    When the operator runs the installer
    Then the image ghcr.io/fabiocicerchia/cluster-info-collector:latest is present in the local docker image store
    And the operator sees "cluster-info-collector ready. Run it against a cluster with:"
    And no cluster-collect command is added to the operator's PATH

  @id:distribution.one-line-installer.002 @rule:distribution.installer.prints-run-options @inferred @source:install.sh#IMAGE
  Scenario: After installing, the operator is shown how to run the collector
    Given the collector image has been pulled
    When the installer finishes
    Then the operator sees the command "docker run --rm -v ~/.kube:/home/collector/.kube:ro ghcr.io/fabiocicerchia/cluster-info-collector:latest"
    And the operator is told that ./docker-collect.sh from a repo checkout auto-detects the kubectl context
    And the operator is told they can apply manifests/job.yaml to run it in-cluster
    And the operator is pointed to https://github.com/fabiocicerchia/cluster-info-collector for usage

  @id:distribution.one-line-installer.003 @rule:distribution.installer.stops-when-image-unavailable @inferred @source:install.sh#IMAGE
  Scenario Outline: The installer stops without claiming success when the image cannot be fetched
    Given <condition>
    When the operator runs the installer
    Then the installer exits with a non-zero status
    And the operator does not see "cluster-info-collector ready"

    Examples:
      | condition                                         |
      | docker is not installed on the operator's machine |
      | the registry ghcr.io is unreachable               |
