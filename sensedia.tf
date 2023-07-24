module "discovery_tool" {
  source = "./modules/addons/sensedia/discovery-tool"

  for_each = { for k, v in var.addons : k => v if k == "discovery-tool" }

  depends_on = [
    module.coredns,
    module.vpc_cni
  ]

  install   = try(each.value.install, false)
  time_wait = try(each.value.time_wait, "30s")

  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  region                    = data.aws_region.current.name

  cloud_provider        = try(each.value.cloud_provider, "aws")
  api_key               = try(each.value.api_key, "")
  address               = try(each.value.address, "https://backofficeapi.sensedia.net")
  time_zone             = try(each.value.time_zone, "America/Sao_Paulo")
  repository            = try(each.value.repository, "473412377568.dkr.ecr.sa-east-1.amazonaws.com/discovery-tool")
  tag                   = try(each.value.tag, "")
  node_selector         = try(each.value.node_selector, "none")
  schedule              = try(each.value.schedule, "0 * * * *")
  identity              = try(each.value.identity, "")
  cluster_zone          = try(each.value.cluster_zone, "none")
  control_plane_cluster = try(each.value.control_plane_cluster, "false")

  tags = local.tags
}

module "sensedia_rbac" {
  source = "./modules/addons/sensedia/rbac"

  time_wait = "30s"

  enable_developers_permissions_core_resources    = try(var.sensedia_rbac["developers_permissions"]["core_resources"], true)
  enable_developers_permissions_istio_resources   = try(var.sensedia_rbac["developers_permissions"]["istio_resources"], false)
  enable_developers_permissions_knative_resources = try(var.sensedia_rbac["developers_permissions"]["knative_resources"], false)

}
