################################################################################
# RBAC - Role-based access control
################################################################################
resource "time_sleep" "rbac" {
  count = var.enable_developers_permissions_core_resources || var.enable_developers_permissions_istio_resources || var.enable_developers_permissions_knative_resources ? 1 : 0

  create_duration = var.time_wait
}

#-----------------------------
# RBAC for view resources
#-----------------------------
data "kubectl_path_documents" "view_rbac" {
  pattern = "${path.module}/templates/view_rbac.yaml"
}

resource "kubectl_manifest" "view_rbac" {
  for_each = data.kubectl_path_documents.view_rbac.manifests

  depends_on = [
    time_sleep.rbac[0]
  ]

  yaml_body = each.value
}

#-----------------------------
# RBAC for core resources
#-----------------------------
data "kubectl_path_documents" "developers_core_rbac" {
  count = var.enable_developers_permissions_core_resources ? 1 : 0

  pattern = "${path.module}/templates/developers_core_rbac.yaml"
}

resource "kubectl_manifest" "developers_core_rbac" {
  for_each = var.enable_developers_permissions_core_resources == true ? data.kubectl_path_documents.developers_core_rbac[0].manifests : {}

  depends_on = [
    time_sleep.rbac[0]
  ]

  yaml_body = each.value
}

#-----------------------------
# RBAC for istio resources
#-----------------------------
data "kubectl_path_documents" "developers_istio_rbac" {
  count = var.enable_developers_permissions_istio_resources ? 1 : 0

  pattern = "${path.module}/templates/developers_istio_rbac.yaml"
}

resource "kubectl_manifest" "developers_istio_rbac" {
  for_each = var.enable_developers_permissions_istio_resources == true ? data.kubectl_path_documents.developers_istio_rbac[0].manifests : {}

  depends_on = [
    time_sleep.rbac[0]
  ]

  yaml_body = each.value
}

#-----------------------------
# RBAC for Knative resources
#-----------------------------
data "kubectl_path_documents" "developers_knative_rbac" {
  count = var.enable_developers_permissions_knative_resources ? 1 : 0

  pattern = "${path.module}/templates/developers_knative_rbac.yaml"
}

resource "kubectl_manifest" "developers_knative_rbac" {
  for_each = var.enable_developers_permissions_knative_resources == true ? data.kubectl_path_documents.developers_knative_rbac[0].manifests : {}

  depends_on = [
    time_sleep.rbac[0]
  ]

  yaml_body = each.value
}
