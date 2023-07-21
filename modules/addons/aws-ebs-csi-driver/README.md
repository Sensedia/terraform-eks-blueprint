# aws-ebs-csi-driver

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.47 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa_role"></a> [irsa\_role](#module\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [kubectl_manifest.storage_class_gp3](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [null_resource.storage_class_gp3](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. | `string` | `""` | no |
| <a name="input_cluster_oidc_provider_arn"></a> [cluster\_oidc\_provider\_arn](#input\_cluster\_oidc\_provider\_arn) | Cluster OIDC provider ARN. | `string` | `""` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`). | `string` | `""` | no |
| <a name="input_configuration_values"></a> [configuration\_values](#input\_configuration\_values) | (Optional) custom configuration values for coreDNS EKS addon with single JSON string. This JSON string value must match the JSON schema derived from describe-addon-configuration(https://docs.aws.amazon.com/cli/latest/reference/eks/describe-addon-configuration.html). | `string` | `"{}"` | no |
| <a name="input_gp3_default"></a> [gp3\_default](#input\_gp3\_default) | Change (if true) setup default of default StorageClass from GP2 to GP3. | `bool` | `true` | no |
| <a name="input_install"></a> [install](#input\_install) | Enable (if true) or disable (if false) the installation of the AWS EBS CSI Driver. | `bool` | `true` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Configuration to store cluster authentication information for kubectl | `string` | `""` | no |
| <a name="input_preserve"></a> [preserve](#input\_preserve) | (Optional) Indicates if you want to preserve the created resources when deleting coreDNS EKS addon. | `bool` | `true` | no |
| <a name="input_resolve_conflicts"></a> [resolve\_conflicts](#input\_resolve\_conflicts) | (Optional) Define how to resolve parameter value conflicts when migrating an existing coreDNS EKS addon to an Amazon EKS add-on or when applying version updates to the add-on. Valid values are `NONE`, `OVERWRITE` and `PRESERVE`. For more details check UpdateAddon(https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html) API Docs. | `string` | `"OVERWRITE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_time_wait"></a> [time\_wait](#input\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"180s"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
