################################################################################
# Cluster Autoscaler
################################################################################
locals {

  image_tag = coalesce(
    var.image_tag,
    var.cluster_version == "1.24" ? "v1.24.2" : "",
    var.cluster_version == "1.25" ? "v1.25.2" : "",
    var.cluster_version == "1.26" ? "v1.26.3" : "",
    var.cluster_version == "1.27" ? "v1.27.2" : "",
  )
}

resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                        = "cluster-autoscaler-${var.cluster_name}"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [var.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-cluster-autoscaler"]
    }
  }

  tags = var.tags
}


# Reference: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler
resource "helm_release" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this[0],
  ]

  namespace        = "kube-system"
  create_namespace = false

  name              = "cluster-autoscaler"
  repository        = "https://kubernetes.github.io/autoscaler"
  chart             = "cluster-autoscaler"
  version           = "9.29.0" # Installed latest version of cluster-autoscaler chart, but 'image.tag' was customized to 1.25.2. See new changes on release notes of application: https://github.com/kubernetes/autoscaler/releases
  dependency_update = true

  values = [
    <<-YAML
    replicaCount: 2

    image:
      tag: ${local.image_tag}

    priorityClassName: "system-cluster-critical"

    autoDiscovery:
      clusterName: ${var.cluster_name}
      tags:
        - "k8s.io/cluster-autoscaler/enabled"
        - "k8s.io/cluster-autoscaler/${var.cluster_name}"

    rbac:
      create: true
      serviceAccount:
        name: "aws-cluster-autoscaler"
        annotations:
          eks.amazonaws.com/role-arn: ${module.irsa_role[0].iam_role_arn}

    cloudProvider: aws

    awsRegion: ${var.region}

    extraArgs:
      expander: least-waste

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: aws-cluster-autoscaler
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}
