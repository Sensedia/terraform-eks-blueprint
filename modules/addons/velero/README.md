# velero

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.47 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.5 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.10 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.10.1 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa_policy"></a> [irsa\_policy](#module\_irsa\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | ~> 5.3 |
| <a name="module_irsa_role"></a> [irsa\_role](#module\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |

## Resources

| Name | Type |
|------|------|
| [helm_release.thias](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. | `string` | n/a | yes |
| <a name="input_cluster_oidc_provider_arn"></a> [cluster\_oidc\_provider\_arn](#input\_cluster\_oidc\_provider\_arn) | Cluster OIDC provider ARN. | `string` | `""` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`). | `string` | n/a | yes |
| <a name="input_install"></a> [install](#input\_install) | Enable (if true) or disable (if false) the installation of Velero. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_time_wait"></a> [time\_wait](#input\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_velero_default_fsbackup"></a> [velero\_default\_fsbackup](#input\_velero\_default\_fsbackup) | True if all volume migration should use FileSystemBackup. False otherwise. | `bool` | `false` | no |
| <a name="input_velero_deploy_fsbackup"></a> [velero\_deploy\_fsbackup](#input\_velero\_deploy\_fsbackup) | Whether FileSystemBackup should be deployed to migrate volumes at filesystem level. | `bool` | `false` | no |
| <a name="input_velero_s3_bucket_name"></a> [velero\_s3\_bucket\_name](#input\_velero\_s3\_bucket\_name) | The s3 bucket for velero backups storage. | `string` | `""` | no |
| <a name="input_velero_s3_bucket_prefix"></a> [velero\_s3\_bucket\_prefix](#input\_velero\_s3\_bucket\_prefix) | The s3 bucket directory prefix. | `string` | `""` | no |
| <a name="input_velero_s3_bucket_region"></a> [velero\_s3\_bucket\_region](#input\_velero\_s3\_bucket\_region) | The s3 bucket region for velero backup. | `string` | `""` | no |
| <a name="input_velero_snapshot_enabled"></a> [velero\_snapshot\_enabled](#input\_velero\_snapshot\_enabled) | True if volume migration should use snapshot. | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
