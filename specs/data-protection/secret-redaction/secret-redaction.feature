@domain:data-protection @area:secret-redaction @from:cluster-info-collector/cluster-collect
Feature: Redacting secret-like values in dumps
  Protects customers from leaking credentials set directly in pod specs, while letting them turn masking off when support needs raw values.

  Background:
    Given namespace "checkout" runs a pod whose container sets DB_PASSWORD to "hunter2-example" and LOG_LEVEL to "debug"

  @id:data-protection.secret-redaction.001 @rule:data-protection.redaction.on-by-default @inferred @source:cluster-collect#dump
  Scenario Outline: Secret-like environment values are masked in describes and resource dumps unless redaction is switched off
    Given REDACT_ENV is "<redact>"
    When the operator runs cluster-collect for "checkout"
    Then the pod's describe file and resources.yaml show DB_PASSWORD as "<shown>"
    And LOG_LEVEL still shows "debug"

    Examples:
      | redact  | shown           |
      | (unset) | REDACTED        |
      | true    | REDACTED        |
      | false   | hunter2-example |
