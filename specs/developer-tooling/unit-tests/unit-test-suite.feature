@domain:developer-tooling @area:unit-tests @from:cluster-info-collector/test-unit
Feature: Running the unit test suite
  Lets a contributor check redaction, size budgeting and the laptop wrapper's dry run and exit codes in seconds, on a machine with no cluster and no docker daemon.

  Background:
    Given a checkout of cluster-info-collector

  @id:developer-tooling.unit-tests.001 @rule:devtooling.unit-tests.run-without-cluster-or-docker @inferred @source:Makefile#test-unit
  Scenario: The unit suite runs with no cluster and no docker daemon
    Given no Kubernetes cluster is reachable
    And no docker daemon is running
    When the contributor runs make test-unit
    Then the laptop wrapper checks run against stand-in kubectl and docker commands
    And the run prints PASS
    And the run exits with status 0

  @id:developer-tooling.unit-tests.002 @rule:devtooling.unit-tests.first-failure-stops-run @inferred @source:test-unit.sh#fail
  Scenario: The first failing check stops the run with a FAIL message
    Given a change that breaks one checked behaviour, such as redacting DB_PASSWORD
    When the contributor runs make test-unit
    Then a line starting with "FAIL:" naming the broken check and the output it saw is printed to standard error
    And no later checks run
    And PASS is not printed
    And the run exits with a non-zero status

  @id:developer-tooling.unit-tests.003 @rule:devtooling.unit-tests.scratch-files-cleanup @inferred @source:test-unit.sh @questionable
  Scenario: A run leaves its size-budget scratch directory behind in the temp folder
    Given the temp folder holds no leftover files from earlier runs
    When the contributor runs make test-unit
    Then the stand-in tools directory is removed when the run ends
    And the scratch directory with the multi-megabyte sample log stays in the temp folder
