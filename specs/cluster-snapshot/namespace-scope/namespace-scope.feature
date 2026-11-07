@domain:cluster-snapshot @area:namespace-scope @from:cluster-info-collector/cluster-collect
Feature: Choosing which namespaces to collect
  Lets an operator narrow an incident snapshot to the namespaces that matter, or take everything by default.

  Background:
    Given a Kubernetes cluster reachable with the operator's credentials

  @id:cluster-snapshot.namespace-scope.001 @rule:snapshot.namespaces.arguments-override-config @inferred @source:cluster-collect#NAMESPACES
  Scenario Outline: Namespaces given on the command line win over the NAMESPACES setting
    Given NAMESPACES is set to "<configured>"
    When the operator runs cluster-collect with the arguments "<arguments>"
    Then the bundle has a namespaces folder for each of "<collected>"
    And the bundle has no folder for any other namespace

    Examples:
      | configured | arguments    | collected    |
      | payments   | checkout web | checkout web |
      | payments   |              | payments     |
      |            | checkout     | checkout     |

  @id:cluster-snapshot.namespace-scope.002 @rule:snapshot.namespaces.default-all @inferred @source:cluster-collect#NAMESPACES
  Scenario: With no namespaces named, every namespace is collected
    Given the cluster has namespaces "default", "kube-system" and "checkout"
    And no namespaces are given as arguments or in NAMESPACES
    When the operator runs cluster-collect
    Then the bundle has a namespaces folder for "default", "kube-system" and "checkout"
