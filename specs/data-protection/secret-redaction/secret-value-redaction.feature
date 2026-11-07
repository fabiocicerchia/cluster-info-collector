@domain:data-protection @area:secret-redaction @from:cluster-info-collector/lib
Feature: Redacting secret-like values from describe and resource dumps
  Serves operators who hand a bundle to a vendor or support team: environment values whose names look secret are replaced with REDACTED so credentials do not leave the cluster inside the bundle.

  Background:
    Given secret value redaction is on (the default)

  @id:data-protection.secret-redaction.002 @rule:data-protection.redaction.secret-named-values-masked @verified @source:lib.sh#redact_stream @test:test-unit.sh#redact_stream: inline "KEY: value" form @test:test-unit.sh#redact_stream: YAML "- name: KEY" / "value: VAL" form
  Scenario Outline: Values of secret-named environment variables are replaced with REDACTED
    Given a pod has the environment variable <name> set to <value>
    When the operator collects a bundle
    Then the pod's describe and resource dumps show <name> with the value <shown>

    Examples:
      | name                  | value        | shown    |
      | DB_PASSWORD           | hunter2      | REDACTED |
      | API_TOKEN             | abc123       | REDACTED |
      | AWS_SECRET_ACCESS_KEY | wJalrFAKEKEY | REDACTED |
      | STRIPE_APIKEY         | sk_test_fake | REDACTED |
      | gcp_credential_json   | {fake}       | REDACTED |
      | TLS_PRIVATE_KEY       | fake-pem     | REDACTED |
      | USERNAME              | admin        | admin    |
      | PORT                  | 8080         | 8080     |

  @id:data-protection.secret-redaction.003 @rule:data-protection.redaction.unlisted-secret-names-kept @inferred @source:lib.sh#redact_stream @questionable
  Scenario Outline: Secret-looking names outside the keyword list keep their values in clear
    Given a pod has the environment variable <name> set to <value>
    When the operator collects a bundle
    Then the pod's describe and resource dumps show <name> with the value <value>

    Examples:
      | name         | value                                    |
      | DB_PASS      | hunter2                                  |
      | AUTH_HEADER  | Bearer fake123                           |
      | SIGNING_KEY  | fake-hmac                                |
      | DATABASE_URL | postgres://app:fakepw@db.example.com/app |

  @id:data-protection.secret-redaction.004 @rule:data-protection.redaction.multiline-values-masked-first-line-only @inferred @source:lib.sh#redact_stream @questionable
  Scenario: Only the first line of a multi-line secret value is masked
    Given a pod has the environment variable TLS_PRIVATE_KEY set to a multi-line PEM value
    When the operator collects a bundle
    Then the line where the TLS_PRIVATE_KEY value starts shows REDACTED
    And the PEM lines that follow it appear in clear in the describe and resource dumps

  @id:data-protection.secret-redaction.005 @rule:data-protection.redaction.secret-named-fields-masked @inferred @source:lib.sh#redact_stream @questionable
  Scenario: Any field whose name contains a secret word is masked, even when it holds no secret
    Given a pod mounts the secret app-tls as a volume, sets automountServiceAccountToken to false and takes an environment variable from a secretKeyRef
    When the operator collects a bundle
    Then the describe shows 'SecretName: REDACTED' instead of app-tls
    And the resource dump shows 'automountServiceAccountToken: REDACTED' instead of false
    And a 'secretKeyRef:' heading in the resource dump reads 'secretKeyRef: REDACTED'
