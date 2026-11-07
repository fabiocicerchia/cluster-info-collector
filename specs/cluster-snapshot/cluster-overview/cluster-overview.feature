@domain:cluster-snapshot @area:cluster-overview @from:cluster-info-collector/cluster-collect
Feature: Capturing cluster-wide facts
  Gives the support engineer reading a bundle the cluster-level picture of the incident in one place.

  @id:cluster-snapshot.cluster-overview.001 @rule:snapshot.overview.cluster-wide-files @inferred @source:cluster-collect#cluster-level snapshot
  Scenario: Every bundle carries the cluster-wide snapshot files
    Given a Kubernetes cluster reachable with the operator's credentials
    When the operator runs cluster-collect
    Then the bundle contains version.yaml, nodes.txt, nodes-describe.txt, events.txt, top-nodes.txt, pods-all.txt and api-resources.txt
    And events.txt lists events from all namespaces ordered by last timestamp
    And pods-all.txt lists the pods of every namespace, whatever namespaces were selected
