@domain:cluster-snapshot @area:graceful-degradation @from:cluster-info-collector/cluster-collect
Feature: Collecting when the cluster is unreachable
  Ensures an operator still gets a bundle, including the errors, when parts of the cluster or the cluster itself cannot be reached.

  Background:
    Given no Kubernetes cluster is reachable

  @id:cluster-snapshot.graceful-degradation.001 @rule:snapshot.degradation.bundle-without-cluster @inferred @source:cluster-collect#cluster-level snapshot
  Scenario: A bundle is still produced when kubectl commands fail
    Given the operator names the namespace "checkout"
    When the operator runs cluster-collect
    Then /tmp/cluster-bundle-<UTC stamp>.tar.gz is written
    And nodes.txt and the other snapshot files hold kubectl's connection error text
    And namespaces/checkout exists with no pod logs

  @id:cluster-snapshot.graceful-degradation.002 @rule:snapshot.degradation.namespace-discovery-failure-aborts @inferred @source:cluster-collect#NAMESPACES @questionable
  Scenario: Without named namespaces, an unreachable cluster ends the run with no bundle
    Given no namespaces are given as arguments or in NAMESPACES
    When the operator runs cluster-collect
    Then the run exits with a non-zero status after the cluster-level snapshot
    And no cluster-bundle tarball is written
