################################################################################
# Node Termination Handler
################################################################################

resource "time_sleep" "this" {
  # See implementation of node_type variable in locals.tf file
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  # See implementation of node_type variable in locals.tf file
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                              = "node-termination-handler-${var.cluster_name}"
  attach_node_termination_handler_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node-termination-handler"]
    }
  }

  tags = var.tags
}


# Reference: https://artifacthub.io/packages/helm/aws/aws-node-termination-handler
resource "helm_release" "this" {
  # See implementation of node_type variable in locals.tf file
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this[0]
  ]

  namespace        = "kube-system"
  create_namespace = false

  name       = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.21.0" # Install version 1.19.0 of node-termination-handler. See new changes on release notes of application: https://github.com/aws/aws-node-termination-handler/releases

  values = [
    <<-YAML
    enableSpotInterruptionDraining: true
    enableScheduledEventDraining: true
    enableRebalanceMonitoring: true
    enableRebalanceDraining: true
    enableProbesServer: true

    # AWS Node Termination HAndler in IMDS mode runs as a DaemonSet with useHostNetwork: true by default.
    # If the Prometheus server is enabled with enablePrometheusServer: true nothing else will be able to bind
    # to the configured port (by default prometheusServerPort: 9092) in the root network namespace.
    # Therefore, it will need to have a firewall/security group configured on the nodes to block access to
    # the /metrics endpoint.
    # You can switch NTH in IMDS mode to run w/ useHostNetwork: false, but you will need to make sure that
    # IMDSv1 is enabled --> OR <-- IMDSv2 IP hop count will need to be incremented to 2.

    enablePrometheusServer: true
    useHostNetwork: false

    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 50m
        memory: 64Mi

    serviceAccount:
      name: aws-node-termination-handler
      annotations:
        eks.amazonaws.com/role-arn: ${module.irsa_role[0].iam_role_arn}
    YAML
  ]
}
