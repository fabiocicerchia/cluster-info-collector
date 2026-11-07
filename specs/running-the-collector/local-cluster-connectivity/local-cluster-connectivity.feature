@domain:running-the-collector @area:local-cluster-connectivity @from:cluster-info-collector/docker-collect
Feature: Reaching local development clusters
  Lets an operator collect from minikube, kind or k3d clusters, whose certificates live outside the usual kubeconfig directory and whose API server is only reachable on a docker network.

  Background:
    Given the operator runs the laptop wrapper against their current kubectl context

  @id:running-the-collector.local-cluster-connectivity.001 @rule:collector.local-connectivity.mount-referenced-cert-dirs @inferred @source:docker-collect.sh#add_mount_dir @questionable
  Scenario Outline: Certificate files the kubeconfig refers to are made available read-only
    Given the current context's CA, client certificate and client key are <cert_refs>
    When the operator runs the laptop wrapper
    Then the collector gets read-only access to <mounted>

    Examples:
      | cert_refs                                                                                         | mounted                                                                                     |
      | files /home/ops/.minikube/ca.crt, /home/ops/.minikube/profiles/minikube/client.crt and client.key | /home/ops/.minikube and /home/ops/.minikube/profiles/minikube, each once, at the same paths |
      | all embedded in the kubeconfig                                                                    | no extra directories                                                                        |
      | the relative file certs/ca.crt                                                                    | no extra directories                                                                        |

  @id:running-the-collector.local-cluster-connectivity.002 @rule:collector.local-connectivity.join-api-server-docker-network @inferred @source:docker-collect.sh#NETWORK @questionable
  Scenario Outline: The collector joins the docker network the API server lives on
    Given a local docker network "kind" has a container at 172.18.0.2
    And the current context's API server is <server>
    When the operator runs the laptop wrapper
    Then the collector container is attached to network <network>

    Examples:
      | server                          | network                   |
      | https://172.18.0.2:6443         | kind                      |
      | https://203.0.113.5:6443        | none (default networking) |
      | https://kind-control-plane:6443 | none (default networking) |
