################################################################################
# fluentbit
################################################################################
locals {
  image_tag = coalesce(
    var.image_tag,
    var.cluster_version == "1.24" ? "2.31.10" : "",
    var.cluster_version == "1.25" ? "2.31.10" : "",
    var.cluster_version == "1.26" ? "2.31.11" : "",
    var.cluster_version == "1.27" ? "2.31.11" : "",
  )

  default_arn_log_group = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group"

}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "role_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  count = var.install ? 1 : 0

  role_name = "fluentbit-${var.cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:fluentbit-aws-for-fluent-bit"]
    }
  }

  role_policy_arns = {
    fluentbit_eks_policy = module.irsa_policy[0].arn
  }

  tags = var.tags
}

module "irsa_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.3"

  count = var.install ? 1 : 0

  name        = "${var.cluster_name}-fluentbit"
  path        = "/"
  description = "IAM Policy for AWS for FluentBit"

  policy = data.aws_iam_policy_document.this[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "this" {

  count = var.install ? 1 : 0

  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["${local.default_arn_log_group}:*:log-stream:*"]
    actions = [
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
  }

  statement {
    sid       = "CreateCWLogs"
    effect    = "Allow"
    resources = ["${local.default_arn_log_group}:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:TagResource",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "helm_release" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this,
  ]

  namespace        = "amazon-cloudwatch"
  create_namespace = true

  name              = "fluentbit"
  repository        = "https://aws.github.io/eks-charts"
  chart             = "aws-for-fluent-bit"
  version           = "0.1.27"
  dependency_update = true

  values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      image_tag            = local.image_tag
      cluster_name         = var.cluster_name
      region               = data.aws_region.current.name
      irsa_iam_role_arn    = module.role_irsa[0].iam_role_arn
      cw_retention_in_days = var.cloudwatch_retention_in_days
      tags                 = join(",", ([for k, v in var.tags : "${k}=${v}"]))
    })
  ]
}
