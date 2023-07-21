################################################################################
# EFS CSI Driver
################################################################################
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name             = "aws-efs-csi-${var.cluster_name}"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

resource "helm_release" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this[0],
  ]

  namespace        = "kube-system"
  create_namespace = false

  name              = "aws-efs-csi-driver"
  repository        = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart             = "aws-efs-csi-driver"
  version           = "2.4.3" # Install version 1.5.5 of aws efs-csi-driver. See new changes on release notes of application: https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases
  dependency_update = true

  values = [
    <<-YAML
    controller:
      serviceAccount:
        create: true
        name: efs-csi-controller-sa
        annotations:
          eks.amazonaws.com/role-arn: ${module.irsa_role[0].iam_role_arn}

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: aws-efs-csi-driver
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}
