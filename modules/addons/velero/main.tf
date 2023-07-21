################################################################################
# Velero
################################################################################
locals {
  helm_release_version = coalesce(
    var.cluster_version == "1.24" ? "v4.0.2" : "",
    var.cluster_version == "1.25" ? "v4.0.2" : "",
    var.cluster_version == "1.26" ? "v4.0.2" : "",
    var.cluster_version == "1.27" ? "v4.0.2" : "",
  )
}
resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name = "velero-${var.cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["velero:velero"]
    }
  }

  role_policy_arns = { velero = module.irsa_policy[0].arn }

  tags = var.tags
}

module "irsa_policy" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.3"

  name        = "velero-${var.cluster_name}"
  path        = "/"
  description = "Velero policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.velero_s3_bucket_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.velero_s3_bucket_name}"
        ]
      }
    ]
  })

  tags = var.tags
}

# References: https://github.com/vmware-tanzu/velero
#             https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero
#             https://sensedia.atlassian.net/wiki/spaces/CLARK/pages/3040182344/Backup+e+restore+K8S+usando+Velero
resource "helm_release" "thias" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this,
  ]

  namespace        = "velero"
  create_namespace = true

  name              = "velero"
  repository        = "https://vmware-tanzu.github.io/helm-charts"
  chart             = "velero"
  version           = local.helm_release_version
  dependency_update = true

  values = [yamlencode({
    configuration = {
      backupStorageLocation = [{
        provider = "aws"
        bucket   = var.velero_s3_bucket_name
        prefix   = var.velero_s3_bucket_prefix
        config = {
          region = var.velero_s3_bucket_region
        }
      }]
      volumeSnapshotLocation = [{
        provider = "aws"
        config = {
          region = var.region
        }
      }]
      features                 = "EnableAPIGroupVersions" # enables backup of all versions of a resource
      defaultVolumesToFsBackup = var.velero_default_fsbackup
    }
    snapshotsEnabled = var.velero_snapshot_enabled
    deployNodeAgent  = var.velero_deploy_fsbackup
    nodeAgent = {
      podVolumePath = "/var/lib/kubelet/pods"
      privileged    = false
      resources = {
        requests = {
          cpu    = "500m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
      }
    }
    credentials = {
      useSecret = false
    }
    initContainers = [
      {
        image = "velero/velero-plugin-for-aws:v1.7.0"
        name  = "velero-plugin-for-aws"
        volumeMounts = [
          {
            mountPath = "/target"
            name      = "plugins"
          }
        ]
      }
    ]
    serviceAccount = { # creates cluster service account and maps it to AWS IAM role (IRSA)
      server = {
        create = true
        name   = "velero"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.irsa_role[0].iam_role_arn
        }
      }
    }
  })]
}
