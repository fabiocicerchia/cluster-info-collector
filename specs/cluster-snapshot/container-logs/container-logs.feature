@domain:cluster-snapshot @area:container-logs @from:cluster-info-collector/cluster-collect
Feature: Collecting container logs
  Gives support the recent and crash-time output of every container while keeping the bundle bounded.

  Background:
    Given namespace "checkout" runs the pod "api-7d9f" with containers "app" and "proxy"

  @id:cluster-snapshot.container-logs.001 @rule:snapshot.logs.bounded-by-tail-and-window @inferred @source:cluster-collect#LOG_TAIL_LINES
  Scenario Outline: Each container's log is limited to the configured line count and time window
    Given LOG_TAIL_LINES is "<tail>"
    And SINCE is "<since>"
    When the operator runs cluster-collect for "checkout"
    Then the bundle has api-7d9f_app.log and api-7d9f_proxy.log
    And each holds at most <tail> lines, <window>

    Examples:
      | tail    | since   | window                                      |
      | (unset) | (unset) | defaulting to 2000 lines from the whole log |
      | 500     | 1h      | only from the last hour                     |
      | 100     | 30m     | only from the last 30 minutes               |

  @id:cluster-snapshot.container-logs.002 @rule:snapshot.logs.previous-crash-when-present @inferred @source:cluster-collect#INCLUDE_PREVIOUS
  Scenario Outline: A previous-crash log is included only for containers that restarted
    Given container "app" has restarted and "proxy" has not
    And INCLUDE_PREVIOUS is "<include>"
    When the operator runs cluster-collect for "checkout"
    Then api-7d9f_app.previous.log is <app_previous>
    And there is no api-7d9f_proxy.previous.log

    Examples:
      | include | app_previous                                |
      | true    | present with the crashed container's output |
      | false   | absent                                      |
