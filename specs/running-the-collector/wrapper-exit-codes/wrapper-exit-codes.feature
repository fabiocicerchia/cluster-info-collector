@domain:running-the-collector @area:wrapper-exit-codes @from:cluster-info-collector/docker-collect
Feature: Telling wrapper failures apart
  Gives scripts that call the laptop wrapper a distinct exit status and message for each kind of refusal, so a typo can be told apart from a missing kubeconfig or tool.

  @id:running-the-collector.wrapper-exit-codes.001 @rule:collector.wrapper-exit-codes.distinct-refusal-codes @inferred @source:docker-collect.sh#die
  Scenario Outline: Each kind of refusal exits with its own status
    Given <situation>
    When the operator runs the laptop wrapper <invocation>
    Then the wrapper prints "docker-cluster-collect: <message>" on standard error
    And no collector container is started
    And the wrapper exits with status <code>

    Examples:
      | situation                        | invocation                     | message                                   | code |
      | docker and kubectl are installed | with --bogus-flag              | unknown option: --bogus-flag (see --help) | 64   |
      | no file exists at /nonexistent   | with --kubeconfig /nonexistent | kubeconfig not found: /nonexistent        | 66   |
      | docker is not installed          | with no options                | docker not found on PATH                  | 127  |
      | kubectl is not installed         | with no options                | kubectl not found on PATH                 | 127  |

  @id:running-the-collector.wrapper-exit-codes.002 @rule:collector.wrapper-exit-codes.missing-option-value @inferred @source:docker-collect.sh#OUTPUT_DIR @questionable
  Scenario: An option given without its value is not reported as bad usage
    Given docker and kubectl are installed
    When the operator runs the laptop wrapper with --output as the last argument
    Then the wrapper stops with a shell "unbound variable" error rather than a usage message
    And the wrapper exits with status 1, not 64
