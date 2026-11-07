@domain:bundle-delivery @area:bundle-archive @from:cluster-info-collector/cluster-collect
Feature: Packaging the bundle
  Gives the operator one timestamped file to hand to support, placed where they choose.

  @id:bundle-delivery.bundle-archive.001 @rule:bundle.archive.utc-timestamped-tarball @inferred @source:cluster-collect#BUNDLE
  Scenario Outline: The bundle is one UTC-timestamped tarball in the output directory
    Given OUTPUT_DIR is "<dir>"
    And the current UTC time is 2026-11-07 10:44:10
    When the operator runs cluster-collect
    Then "<dir>/cluster-bundle-20261107T104410Z.tar.gz" exists
    And it unpacks into a single folder "bundle-20261107T104410Z"
    And the operator sees "cluster-collect: bundle written: <dir>/cluster-bundle-20261107T104410Z.tar.gz" with its size

    Examples:
      | dir          |
      | /tmp         |
      | /var/bundles |
