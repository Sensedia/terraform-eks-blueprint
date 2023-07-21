################################################################################
# Namespace customizations
################################################################################
locals {
  default_annotations = []
  default_labels      = ["namespace_created_with_eks=true"]
  default_namespace_config = {
    annotations = local.default_annotations,
    labels      = local.default_labels
  }

  custom_namespaces = merge(var.namespace_customizations,
    {
      kube-system       = local.default_namespace_config
      default           = local.default_namespace_config
      kube-node-lease   = local.default_namespace_config
      kube-public       = local.default_namespace_config
      amazon-cloudwatch = local.default_namespace_config
    }
  )
}


resource "time_sleep" "this" {
  count = var.enable ? 1 : 0

  create_duration = var.time_wait
}

# Add customization in namespaces
# References:
#             https://yellowdesert.consulting/2021/05/31/terraform-map-and-object-patterns/
#             https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace
#             https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-crd-faas
#             https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
#             https://www.middlewareinventory.com/blog/terraform-for-each-examples/
#             https://stackoverflow.com/questions/71319940/terraform-local-exec-command-with-complex-variables
resource "null_resource" "this" {
  for_each = var.enable ? local.custom_namespaces : {}

  depends_on = [
    time_sleep.this[0],
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ANNOTATIONS = join(" ", try(each.value.annotations, []))
      KUBECONFIG  = base64encode(var.kubeconfig)
      LABELS      = join(" ", try(each.value.labels, []))
      NAMESPACE   = each.key
    }

    command = <<-EOT
      #!/usr/bin/env bash
      echo "[INFO] Creating namespace: $NAMESPACE"
      kubectl create ns $NAMESPACE --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      echo "[INFO] Setting annotations and labels on namespace: $NAMESPACE"
      for annotation in $ANNOTATIONS; do
        kubectl annotate ns $NAMESPACE --overwrite $annotation --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      done
      for label in $LABELS; do
        kubectl label ns $NAMESPACE --overwrite $label --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      done
    EOT
  }
}
