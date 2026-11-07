@domain:bundle-delivery @area:s3-upload @from:cluster-info-collector/cluster-collect
Feature: Shipping the bundle to S3
  Lets operators deliver bundles straight to a support bucket without copying files off the cluster.

  Background:
    Given OUTPUT_DIR is "/tmp" and the run's bundle is named cluster-bundle-20261107T104410Z.tar.gz

  @id:bundle-delivery.s3-upload.001 @rule:bundle.s3.upload-to-prefix @inferred @source:cluster-collect#BUNDLE_S3_URI
  Scenario Outline: The bundle is uploaded under the configured S3 prefix
    Given BUNDLE_S3_URI is "<uri>"
    When the operator runs cluster-collect
    Then the bundle is stored at "s3://support-bundles-example/acme/cluster-bundle-20261107T104410Z.tar.gz"
    And the operator sees "uploaded to s3://support-bundles-example/acme/cluster-bundle-20261107T104410Z.tar.gz"

    Examples:
      | uri                                |
      | s3://support-bundles-example/acme  |
      | s3://support-bundles-example/acme/ |

  @id:bundle-delivery.s3-upload.002 @rule:bundle.s3.failed-upload-fails-run @inferred @source:cluster-collect#BUNDLE_S3_URI
  Scenario: A failed upload fails the run but keeps the local bundle
    Given BUNDLE_S3_URI is "s3://support-bundles-example/acme"
    And the collector has no permission to write to that bucket
    When the operator runs cluster-collect
    Then the run exits with a non-zero status
    And no "uploaded to" message is shown
    And /tmp/cluster-bundle-20261107T104410Z.tar.gz still exists
