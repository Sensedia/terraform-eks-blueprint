################################################################################
# AWS VPC CNI
################################################################################
locals {

  default_without_vpn = {
    MINIMUM_IP_TARGET            = var.aws_vpc_cni_minimum_ip
    WARM_IP_TARGET               = var.aws_vpc_cni_warm_ip
    AWS_VPC_K8S_CNI_EXTERNALSNAT = "false"
    AWS_VPC_ENI_MTU              = "9001"
  }
  default_with_vpn = {
    MINIMUM_IP_TARGET            = "10"
    WARM_IP_TARGET               = "2"
    AWS_VPC_K8S_CNI_EXTERNALSNAT = "true"
    AWS_VPC_ENI_MTU              = "1498"
  }

  environments_variables = var.support_vpn ? local.default_with_vpn : local.default_without_vpn

}
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name             = "vpc-cni-ipv4-${var.cluster_name}"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

data "aws_eks_addon_version" "this" {
  count = var.install ? 1 : 0
  depends_on = [
    time_sleep.this
  ]

  addon_name         = "vpc-cni"
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
  resolve_conflicts        = var.resolve_conflicts
  preserve                 = var.preserve
  service_account_role_arn = module.irsa_role[0].iam_role_arn

  configuration_values = var.configuration_values == "{}" ? jsonencode({
    env = local.environments_variables
  }) : var.configuration_values

  tags = var.tags
}
