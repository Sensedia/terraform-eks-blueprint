################################################################################
# AWS Load Balancer Controller
################################################################################
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                              = "load-balancer-controller-${var.cluster_name}"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

# Reference: https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this[0]
  ]

  namespace        = "kube-system"
  create_namespace = true

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.3" # Install version v2.5.2 of aws-load-balancer-controller. See new changes on release notes of application: https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases

  values = [
    <<-YAML
    clusterName: ${var.cluster_name}
    region: ${var.region}
    vpcId: ${var.vpc_id}
    
    serviceAccount:
      name: aws-load-balancer-controller
      annotations:
        eks.amazonaws.com/role-arn: ${module.irsa_role[0].iam_role_arn}

    ingressClass: alb
    ingressClassParams:
      name: alb

    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 100m
        memory: 128Mi

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: aws-load-balancer-controller
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    enableServiceMutatorWebhook: false
    YAML
  ]
}
