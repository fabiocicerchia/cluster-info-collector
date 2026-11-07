@domain:running-the-collector @area:laptop-wrapper @from:cluster-info-collector/docker-collect
Feature: Running a collection from a laptop
  Lets an operator collect a support bundle from their current kubectl context with one command, without putting together a docker run line by hand.

  Background:
    Given the operator has docker and kubectl installed
    And the operator has a kubeconfig for the cluster under investigation

  @id:running-the-collector.laptop-wrapper.001 @rule:collector.laptop-wrapper.dry-run-prints-without-running @inferred @source:docker-collect.sh#DRY_RUN
  Scenario: A dry run shows the container command and runs nothing
    When the operator runs the laptop wrapper with --dry-run
    Then the full docker command is printed on standard error, prefixed with "docker-cluster-collect:"
    And no collector container is started
    And the wrapper exits with status 0

  @id:running-the-collector.laptop-wrapper.002 @rule:collector.laptop-wrapper.bundle-written-to-host-dir-as-operator @inferred @source:docker-collect.sh#OUTPUT_DIR
  Scenario Outline: The bundle lands in a host directory and belongs to the operator
    Given the operator's user id is 1000 and group id is 1000
    When the operator runs the laptop wrapper with output directory <output>
    Then the directory <output> exists on the host, created if it was missing
    And the collector writes its bundle into that directory
    And the collector runs as user 1000:1000, so the operator owns the bundle files

    Examples:
      | output                |
      | (not given, so ./out) |
      | /tmp/incident-4711    |

  @id:running-the-collector.laptop-wrapper.003 @rule:collector.laptop-wrapper.uses-current-kubeconfig-read-only @inferred @source:docker-collect.sh#KUBECONFIG_PATH
  Scenario Outline: The collector uses the operator's kubeconfig and cannot change it
    Given the operator's KUBECONFIG is <env>
    When the operator runs the laptop wrapper <flag>
    Then the kubeconfig at <used> is given to the collector read-only
    And the collector is told to use that kubeconfig

    Examples:
      | env                           | flag                                         | used                                                    |
      | unset                         | without --kubeconfig                         | the default kubeconfig in the operator's home directory |
      | /home/ops/kubeconfigs/staging | without --kubeconfig                         | /home/ops/kubeconfigs/staging                           |
      | /home/ops/kubeconfigs/staging | with --kubeconfig /home/ops/kubeconfigs/prod | /home/ops/kubeconfigs/prod                              |

  @id:running-the-collector.laptop-wrapper.004 @rule:collector.laptop-wrapper.s3-upload-with-local-aws-credentials @inferred @source:docker-collect.sh#S3_URI
  Scenario Outline: Requesting an S3 upload passes the location and the operator's AWS credentials read-only
    Given the operator has an AWS credentials directory in their home directory
    When the operator runs the laptop wrapper <s3>
    Then the collector is given upload location <location>
    And the operator's AWS credentials directory is given to the collector read-only: <aws_mounted>

    Examples:
      | s3                                    | location                    | aws_mounted |
      | with --s3 s3://acme-support/incidents | s3://acme-support/incidents | yes         |
      | without --s3                          | none                        | no          |

  @id:running-the-collector.laptop-wrapper.005 @rule:collector.laptop-wrapper.image-and-tag-selection @inferred @source:docker-collect.sh#IMAGE
  Scenario Outline: The operator can choose which collector image and tag to run
    When the operator runs the laptop wrapper <options>
    Then the collector container started is <image>

    Examples:
      | options                                               | image                                                |
      | with no image options                                 | ghcr.io/fabiocicerchia/cluster-info-collector:latest |
      | with --tag 1.4.0                                      | ghcr.io/fabiocicerchia/cluster-info-collector:1.4.0  |
      | with --image registry.example.com/collector --tag dev | registry.example.com/collector:dev                   |

  @id:running-the-collector.laptop-wrapper.006 @rule:collector.laptop-wrapper.passes-settings-and-namespaces @inferred @source:docker-collect.sh#ENV_VARS
  Scenario: Extra settings and namespaces are passed through to the collector
    When the operator runs the laptop wrapper with --env LOG_TAIL_LINES=500 --env SINCE=1h payments checkout
    Then the collector receives LOG_TAIL_LINES=500 and SINCE=1h as settings
    And the collector is asked to collect namespaces payments and checkout
