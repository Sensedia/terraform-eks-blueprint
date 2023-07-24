################################################################################
# Used in other *.tf files
################################################################################

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = data.aws_eks_cluster.this.name
      cluster = {
        certificate-authority-data = data.aws_eks_cluster.this.certificate_authority[0].data
        server                     = data.aws_eks_cluster.this.endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = data.aws_eks_cluster.this.name
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })

  node_type = coalesce(
    var.type_worker_node_group == "KARPENTER" ? "KARPENTER" : "",
    var.type_worker_node_group == "AWS_MANAGED_NODE" ? "AWS_MANAGED_NODE" : "",
    var.type_worker_node_group == "SELF_MANAGED_NODE" ? "SELF_MANAGED_NODE" : "",
  )

  tags = merge(
    {
      Terraform = "true",
    },
    var.tags,
  )
}

data "aws_partition" "current" {}
data "aws_region" "current" {}

################################################################################
# EKS Cluster
################################################################################
module "eks" {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  create_kms_key                         = var.create_kms_key
  cluster_encryption_config              = var.cluster_encryption_config
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids
  cluster_security_group_additional_rules = merge(
    {
      ingress_vpc_cidr_block_all = {
        description = "CIDR of the VPC to cluster API all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks = var.vpc_cidr_block
      }
    },
    var.cluster_security_group_additional_rules
  )

  iam_role_name = var.iam_role_name

  # Required for Karpenter role below
  enable_irsa = true

  node_security_group_enable_recommended_rules = var.node_security_group_enable_recommended_rules
  node_security_group_additional_rules = merge(
    {
      ingress_vpc_cidr_block_all = {
        description = "CIDR of the VPC to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks = var.vpc_cidr_block
      }
    },
    var.node_security_group_additional_rules
  )

  ## Created aws-auth.tf to substitute this.
  ## Workaround to avoid intermittent and unpredictable errors which are hard to debug and diagnose with kubernetes, helm, kubectl providers.
  ## Known error see more in the WARNING block: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-manage
  manage_aws_auth_configmap = true
  aws_auth_roles            = var.aws_auth_roles
  aws_auth_users            = var.aws_auth_users


  # Trying to implement case conditional statement native of other programing languages
  # See implementation of node_type variable in locals.tf file
  node_security_group_tags = merge(
    local.node_type == "KARPENTER" ? (
      {
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        # (i.e. - at most, only one security group should have this tag in your account)
        "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name
      }
    ) : {},
    var.node_security_group_tags
  )

  eks_managed_node_group_defaults = merge(
    {
      enable_monitoring  = false
      capacity_rebalance = true
      iam_role_additional_policies = {
        "AmazonSSMManagedInstanceCore" = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }
    },
    var.eks_managed_node_group_defaults
  )

  # Trying to implement case conditional statement native of other programing languages
  # See implementation of node_type variable in locals.tf file
  eks_managed_node_groups = merge(
    local.node_type == "KARPENTER" ? (
      {
        initial = {
          capacity_type     = "ON_DEMAND"
          ami_type          = var.mng_ami_type
          instance_types    = var.mng_ami_type == "AL2_ARM_64" || var.mng_ami_type == "BOTTLEROCKET_ARM_64" ? ["t4g.medium", "c7g.large"] : ["m6i.medium", "m6a.medium", "m5.medium", "m5a.medium"]
          enable_monitoring = false

          # Only to create Karpenter nodes resources.
          min_size     = 2
          max_size     = 3
          desired_size = 3

          iam_role_attach_cni_policy = true
          iam_role_additional_policies = {
            # Required by Karpenter
            "AmazonSSMManagedInstanceCore" = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
            "CloudWatchAgentServerPolicy"  = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy",
          }

          tags = {
            # This will tag the launch template created for use by Karpenter
            "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name,
            # NTH to monitoring Spot Instance Termination Notifications (ITN) in Karpenter Spot Nodes
            "aws-node-termination-handler/managed" = "true",
          }
        }
      }
    ) : {},

    local.node_type == "AWS_MANAGED_NODE" ? (
      var.eks_managed_node_groups
    ) : {},
  )


  # Trying to implement case conditional statement native of other programing languages
  # See implementation of node_type variable in locals.tf file
  self_managed_node_groups = local.node_type == "SELF_MANAGED_NODE" ? (
    var.self_managed_node_groups
  ) : {}

  # Trying to implement case conditional statement native of other programing languages
  # See implementation of node_type variable in locals.tf file
  self_managed_node_group_defaults = local.node_type == "SELF_MANAGED_NODE" ? (
    merge(
      var.self_managed_node_group_defaults,
      {
        enable_monitoring  = false
        capacity_rebalance = true
        iam_role_additional_policies = {
          "AmazonSSMManagedInstanceCore" = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
        }
        mixed_instances_policy = {
          instances_distribution = {
            spot_allocation_strategy = "price-capacity-optimized"
          }
        }
      }
    )
  ) : null

  tags = local.tags
}

## Required for kubernetes, helm and kubectl providers where EKS cluster does not exist yet to avoid race condition.
## Known error see more in the WARNING block: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources
data "aws_eks_cluster" "this" {
  name       = var.cluster_name
  depends_on = [module.eks.cluster_id]
}

data "aws_eks_cluster_auth" "this" {
  name       = var.cluster_name
  depends_on = [module.eks.cluster_id]
}

module "aws_ebs_csi_driver" {
  source = "./modules/addons/aws-ebs-csi-driver"

  for_each = { for k, v in var.addons : k => v if k == "aws-ebs-csi-driver" }

  install              = try(each.value.install, true)
  time_wait            = try(each.value.time_wait, "180s")
  resolve_conflicts    = try(each.value.resolve_conflicts, "OVERWRITE")
  configuration_values = try(each.value.configuration_values, "{}")
  preserve             = try(each.value.preserve, true)

  gp3_default = try(each.value.gp3_default, true)
  kubeconfig  = try(each.value.gp3_default, false) ? local.kubeconfig : ""

  cluster_name              = module.eks.cluster_name
  cluster_version           = module.eks.cluster_version
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}

module "aws_efs_csi_driver" {
  source = "./modules/addons/aws-efs-csi-driver"

  for_each = { for k, v in var.addons : k => v if k == "aws-efs-csi-driver" }

  install   = try(each.value.install, true)
  time_wait = try(each.value.time_wait, "30s")

  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}

module "aws_load_balancer_controller" {
  source = "./modules/addons/aws-load-balancer-controller"

  for_each = { for k, v in var.addons : k => v if k == "aws-load-balancer-controller" }

  install   = try(each.value.install, true)
  time_wait = try(each.value.time_wait, "30s")

  region = data.aws_region.current.name
  vpc_id = var.vpc_id

  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}

module "cluster_autoscaler" {
  source = "./modules/addons/cluster-autoscaler"

  for_each = { for k, v in var.addons : k => v if k == "cluster-autoscaler" }

  install   = try(each.value.install, true)
  time_wait = try(each.value.time_wait, "30s")

  region    = data.aws_region.current.name
  image_tag = try(each.value.image_tag, "")

  cluster_name              = module.eks.cluster_name
  cluster_version           = module.eks.cluster_version
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}

module "coredns" {
  source = "./modules/addons/coredns"

  for_each = { for k, v in var.addons : k => v if k == "coredns" }

  install              = try(each.value.install, true)
  time_wait            = try(each.value.time_wait, "30s")
  resolve_conflicts    = try(each.value.resolve_conflicts, "OVERWRITE")
  configuration_values = try(each.value.configuration_values, "{}")
  preserve             = try(each.value.preserve, true)

  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  tags = local.tags
}

module "kube_proxy" {
  source = "./modules/addons/kube-proxy"

  for_each = { for k, v in var.addons : k => v if k == "kube-proxy" }

  install              = try(each.value.install, true)
  time_wait            = try(each.value.time_wait, "30s")
  resolve_conflicts    = try(each.value.resolve_conflicts, "OVERWRITE")
  configuration_values = try(each.value.configuration_values, "{}")
  preserve             = try(each.value.preserve, true)

  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  tags = local.tags
}

module "vpc_cni" {
  source = "./modules/addons/vpc-cni"

  for_each = { for k, v in var.addons : k => v if k == "vpc-cni" }

  install     = try(each.value.install, true)
  time_wait   = try(each.value.time_wait, "30s")
  support_vpn = try(each.value.support_vpn, false)

  aws_vpc_cni_minimum_ip = try(each.value.aws_vpc_cni_minimum_ip, 14)
  aws_vpc_cni_warm_ip    = try(each.value.aws_vpc_cni_warm_ip, 2)

  resolve_conflicts    = try(each.value.resolve_conflicts, "OVERWRITE")
  configuration_values = try(each.value.configuration_values, "{}")
  preserve             = try(each.value.preserve, true)

  cluster_name              = module.eks.cluster_name
  cluster_version           = module.eks.cluster_version
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}

module "custom_namespaces" {
  source = "./modules/addons/custom-namespaces"

  for_each = { for k, v in var.addons : k => v if k == "custom-namespaces" }

  enable     = try(each.value.enable, false)
  time_wait  = try(each.value.time_wait, "30s")
  kubeconfig = local.kubeconfig

  namespace_customizations = try(each.value.namespace_customizations, {})

}

module "metrics_server" {
  source = "./modules/addons/metrics-server"

  for_each = { for k, v in var.addons : k => v if k == "metrics-server" }

  depends_on = [
    module.coredns,
    module.vpc_cni
  ]

  install   = try(each.value.install, false)
  time_wait = try(each.value.time_wait, "30s")

}

module "node_termination_handler" {
  source = "./modules/addons/node-termination-handler"

  for_each = { for k, v in var.addons : k => v if local.node_type == "SELF_MANAGED_NODE" && k == "node-termination-handler" }

  install   = try(each.value.install, false)
  time_wait = try(each.value.time_wait, "30s")

  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}

module "traefik" {
  source = "./modules/addons/traefik"

  for_each = { for k, v in var.addons : k => v if k == "traefik" }

  depends_on = [
    module.coredns,
    module.vpc_cni
  ]

  install        = try(each.value.install, false)
  time_wait      = try(each.value.time_wait, "30s")
  vpc_cidr_block = var.vpc_cidr_block

  create_ingress          = try(var.addons["aws-lb-controller"].install, true) ? try(each.value.create_ingress, true) : false
  ingress_certificate_arn = try(each.value.ingress_certificate_arn, "")
  ingress_inbound_cidrs   = try(each.value.ingress_inbound_cidrs, "")
  scost                   = try(each.value.scost, "")
  environment             = try(each.value.environment, "")

}

module "velero" {
  source = "./modules/addons/velero"

  for_each = { for k, v in var.addons : k => v if k == "velero" }

  install   = try(each.value.install, false)
  time_wait = try(each.value.time_wait, "30s")

  cluster_name              = module.eks.cluster_name
  cluster_version           = module.eks.cluster_version
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  region                    = data.aws_region.current.name

  velero_s3_bucket_name   = try(each.value.velero_s3_bucket_name, "")
  velero_s3_bucket_prefix = try(each.value.velero_s3_bucket_prefix, "")
  velero_s3_bucket_region = try(each.value.velero_s3_bucket_region, "")

  velero_default_fsbackup = try(each.value.velero_default_fsbackup, false)
  velero_snapshot_enabled = try(each.value.velero_snapshot_enabled, false)
  velero_deploy_fsbackup  = try(each.value.velero_deploy_fsbackup, false)

  tags = local.tags
}

module "karpenter" {
  source = "./modules/addons/karpenter"

  count = local.node_type == "KARPENTER" ? 1 : 0

  cluster_name              = module.eks.cluster_name
  cluster_endpoint          = module.eks.cluster_endpoint
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn


  iam_role_arn = module.eks.eks_managed_node_groups["initial"].iam_role_arn

  irsa_name    = "karpenter-irsa-${var.cluster_short_name}"
  irsa_tag_key = "karpenter.sh/discovery/${var.cluster_name}"

  tags = local.tags
}

module "fluentbit" {
  source = "./modules/addons/fluentbit"

  for_each = { for k, v in var.addons : k => v if k == "fluentbit" }

  depends_on = [
    module.coredns,
    module.vpc_cni
  ]

  install   = try(each.value.install, true)
  time_wait = try(each.value.time_wait, "30s")
  image_tag = try(each.value.image_tag, "")

  cloudwatch_retention_in_days = try(each.value.cloudwatch_retention_in_days, "7")

  cluster_name              = module.eks.cluster_name
  cluster_version           = module.eks.cluster_version
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}
