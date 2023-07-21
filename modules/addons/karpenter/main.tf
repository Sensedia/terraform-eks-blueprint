#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#OBS: ATUALIZAR PARA EKS 1.25 + Karpenter 0.28
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
################################################################################
# karpenter
# More info: https://sensedia.atlassian.net/wiki/spaces/CLARK/pages/2611249159/Karpenter
################################################################################
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "karpenter_irsa" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 19.15"

  depends_on = [
    time_sleep.this[0]
  ]

  cluster_name = var.cluster_name

  create_iam_role = false
  iam_role_arn    = var.iam_role_arn

  irsa_name              = var.irsa_name
  irsa_tag_key           = var.irsa_tag_key
  irsa_oidc_provider_arn = var.cluster_oidc_provider_arn

  policies = merge(var.irsa_policies, {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  })

  tags = var.tags
}

# Reference: https://gallery.ecr.aws/karpenter/karpenter

# See implementation of node_type variable in locals.tf file
resource "helm_release" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this[0]
  ]

  namespace        = "karpenter"
  create_namespace = true

  name              = "karpenter"
  repository        = "oci://public.ecr.aws/karpenter"
  chart             = "karpenter"
  version           = "v0.19.3" # Install version 0.19.3 of karpenter. See new changes on release notes of application: https://github.com/aws/karpenter/releases
  dependency_update = true

  values = [
    <<-YAML
    settings:
      aws:
        clusterName: ${var.cluster_name}
        clusterEndpoint: ${var.cluster_endpoint}
        defaultInstanceProfile: ${module.karpenter_irsa[0].instance_profile_name}
        interruptionQueueName: ${module.karpenter_irsa[0].queue_name}

    serviceAccount:
      name: karpenter
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter_irsa[0].irsa_arn}
    YAML
  ]
}

resource "kubectl_manifest" "karpenter_provisioner" {
  count = var.install ? 1 : 0

  depends_on = [
    helm_release.this[0]
  ]

  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default  
  spec:
    ttlSecondsAfterEmpty: 30
    labels:
      karpenter: "true"
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values:
          - spot
      - key: kubernetes.io/arch
        operator: In
        values:
          - amd64
    limits:
      resources:
        cpu: ${var.karpenter_cpu_limit}
        memory: ${var.karpenter_memory_limit}
    providerRef:
      name: default
  YAML
}

resource "kubectl_manifest" "karpenter_node_template" {
  count = var.install ? 1 : 0

  depends_on = [
    helm_release.this[0]
  ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        ${var.irsa_tag_key}: ${var.cluster_name}
      securityGroupSelector:
        ${var.irsa_tag_key}: ${var.cluster_name}
      tags:
        ${var.irsa_tag_key}: ${var.cluster_name}
  YAML
}
