################################################################################
# EBS CSI Driver
################################################################################

resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name             = "aws-ebs-csi-${var.cluster_name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

data "aws_eks_addon_version" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this
  ]

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    data.aws_eks_addon_version.this
  ]

  cluster_name             = var.cluster_name
  addon_name               = data.aws_eks_addon_version.this[0].id
  addon_version            = data.aws_eks_addon_version.this[0].version
  service_account_role_arn = module.irsa_role[0].iam_role_arn
  resolve_conflicts        = var.resolve_conflicts
  configuration_values     = var.configuration_values
  preserve                 = var.preserve

  tags = var.tags
}

################################################################################
# Storage class GP3
################################################################################
resource "null_resource" "storage_class_gp3" {
  count = var.gp3_default && var.install ? 1 : 0

  depends_on = [
    aws_eks_addon.this
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(var.kubeconfig)
    }

    command = <<-EOT
      #!/usr/bin/env bash
      echo "[INFO] Annotate default storageclass to false"
      kubectl annotate sc gp2 storageclass.kubernetes.io/is-default-class="false" --overwrite --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }
}

resource "kubectl_manifest" "storage_class_gp3" {
  count = var.install && var.gp3_default ? 1 : 0

  depends_on = [
    null_resource.storage_class_gp3
  ]

  yaml_body = <<-YAML
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
    name: gp3
  parameters:
    type: gp3
  provisioner: kubernetes.io/aws-ebs
  reclaimPolicy: Delete
  volumeBindingMode: WaitForFirstConsumer
  allowVolumeExpansion: true
  YAML
}
