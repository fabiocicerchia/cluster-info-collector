@domain:bundle-delivery @area:size-budget @from:cluster-info-collector/cluster-collect
Feature: Capping bundle size
  Keeps bundles small enough to upload or attach while preserving the most recent log lines.

  @id:bundle-delivery.size-budget.001 @rule:bundle.size-budget.truncate-largest-logs @inferred @source:cluster-collect#MAX_BUNDLE_MB @questionable
  Scenario: Past the size budget, the largest logs are cut to their most recent lines
    Given MAX_BUNDLE_MB is 5
    And the collected files total 12 MB, mostly one 9 MB container log
    When the operator runs cluster-collect
    Then the operator sees "enforcing 5MB size budget (biggest logs truncated first)"
    And the 9 MB log starts with "... [cluster-collect: truncated to fit 5MB size budget]" followed by its last 200 lines
    And describe, resource and event files are unchanged
