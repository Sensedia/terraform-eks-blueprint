################################################################################
# Discovery Tool - Sensedia Discovery Tool for get information of customers
################################################################################
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name = "discovery-tool-${var.cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["discovery-tool:discovery-tool-svcacc"]
    }
  }

  role_policy_arns = { discovery-tool = module.irsa_policy[0].arn }

  tags = var.tags
}

module "irsa_policy" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.3"

  name        = "discovery-tool-${var.cluster_name}"
  path        = "/"
  description = "Sensedia Collector policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeNatGateways",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpnGateways",
          "directconnect:DescribeVirtualInterfaces",
          "eks:DescribeCluster",
        ],
        Resource = "*"
      },
    ]
  })

  tags = var.tags
}

resource "kubectl_manifest" "discovery_tool_00" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this[0]
  ]

  yaml_body = file("${path.module}/templates/discovery_tool_00.yaml")
}

resource "kubectl_manifest" "discovery_tool_01" {
  count = var.install ? 1 : 0

  depends_on = [
    kubectl_manifest.discovery_tool_00[0]
  ]

  yaml_body = templatefile(
    "${path.module}/templates/discovery_tool_01.yaml",
    {
      discovery_tool_irsa = module.irsa_role[0].iam_role_arn
    }
  )
}

data "kubectl_path_documents" "discovery_tool" {
  count = var.install ? 1 : 0

  pattern = "${path.module}/templates/discovery_tool_02.yaml"

  vars = {
    cluster_name                         = var.cluster_name
    region                               = var.region
    provider                             = var.cloud_provider
    discovery_tool_api_key               = var.api_key
    discovery_tool_address               = var.address
    discovery_tool_time_zone             = var.time_zone
    discovery_tool_repository            = var.repository
    discovery_tool_tag                   = var.tag
    discovery_tool_node_selector         = var.node_selector
    discovery_tool_schedule              = var.schedule
    discovery_tool_identity              = var.identity
    discovery_tool_cluster_zone          = var.cluster_zone
    discovery_tool_control_plane_cluster = var.control_plane_cluster
  }
}

resource "kubectl_manifest" "discovery_tool_02" {
  for_each = var.install ? data.kubectl_path_documents.discovery_tool[0].manifests : {}

  depends_on = [
    kubectl_manifest.discovery_tool_01[0]
  ]

  yaml_body = each.value
}
