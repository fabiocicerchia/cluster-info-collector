@domain:bundle-delivery @area:size-budget @from:cluster-info-collector/lib
Feature: Keeping the bundle within a size budget
  Serves operators who must ship a bundle through size-limited channels: the biggest container logs are cut down first, keeping their most recent lines, until the bundle fits.

  @id:bundle-delivery.size-budget.002 @rule:bundle-delivery.size-budget.largest-logs-truncated-first @verified @source:lib.sh#enforce_size_budget @test:test-unit.sh#dir_size_bytes / enforce_size_budget
  Scenario: Over budget, the largest logs are cut to their most recent lines until the bundle fits
    Given the size budget is 1 MB
    And the collection holds one container log of several MB and one container log of 10 lines
    When the operator collects a bundle
    Then the large log starts with '... [cluster-collect: truncated to fit 1MB size budget]'
    And the large log then holds only its last 200 lines
    And the 10-line log is unchanged

  @id:bundle-delivery.size-budget.003 @rule:bundle-delivery.size-budget.no-truncation-when-within-budget @verified @source:lib.sh#enforce_size_budget @test:test-unit.sh#dir_size_bytes / enforce_size_budget
  Scenario Outline: Logs are left whole when there is no budget or the bundle already fits
    Given the size budget is <budget>
    And the collection holds a container log of several MB
    When the operator collects a bundle
    Then the container log keeps all of its lines
    And no truncation marker appears in any log

    Examples:
      | budget                     | case                        |
      | 0 (unlimited, the default) | no budget                   |
      | 100 MB                     | bundle already under budget |

  @id:bundle-delivery.size-budget.004 @rule:bundle-delivery.size-budget.only-container-logs-truncated @inferred @source:lib.sh#enforce_size_budget @questionable
  Scenario: Only container logs are cut; describes, resource dumps and events are never truncated
    Given the size budget is 1 MB
    And the collection holds pod describes, resource dumps and events that together exceed 1 MB
    When the operator collects a bundle
    Then every describe, resource dump and events file is complete
    And each container log has been truncated at most once
    And the collected files stay above 1 MB and the bundle is still written, with no warning
