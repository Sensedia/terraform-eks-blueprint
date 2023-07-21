################################################################################
# CoreDNS EKS Addon
################################################################################
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

data "aws_eks_addon_version" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this
  ]

  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "this" {
  count = var.install ? 1 : 0
  depends_on = [
    data.aws_eks_addon_version.this
  ]

  cluster_name         = var.cluster_name
  addon_name           = data.aws_eks_addon_version.this[0].id
  addon_version        = data.aws_eks_addon_version.this[0].version
  resolve_conflicts    = var.resolve_conflicts
  configuration_values = var.configuration_values
  preserve             = var.preserve

  tags = var.tags
}
