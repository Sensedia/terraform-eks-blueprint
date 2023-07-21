# discovery-tool

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
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa_policy"></a> [irsa\_policy](#module\_irsa\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | ~> 5.3 |
| <a name="module_irsa_role"></a> [irsa\_role](#module\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.discovery_tool_00](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.discovery_tool_01](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.discovery_tool_02](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [kubectl_path_documents.discovery_tool](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | Backoffice API address. | `string` | `"https://backofficeapi.sensedia.net"` | no |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | API key to allow this implementaion to comunicate with the Backoffice API. | `string` | `""` | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Cloud provider that will be installed the Sensedia Discovery Tool. | `string` | `"aws"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. | `string` | `""` | no |
| <a name="input_cluster_oidc_provider_arn"></a> [cluster\_oidc\_provider\_arn](#input\_cluster\_oidc\_provider\_arn) | Cluster OIDC provider ARN. | `string` | `""` | no |
| <a name="input_cluster_zone"></a> [cluster\_zone](#input\_cluster\_zone) | When on GKE this is required; When in EKS is optional; | `string` | `"none"` | no |
| <a name="input_control_plane_cluster"></a> [control\_plane\_cluster](#input\_control\_plane\_cluster) | Tells if it's a control plane cluster or not. Example: management-dyl0 is a control plane cluster, so you must set this variable to true. | `string` | `"false"` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | When on GKE this is the project\_id; when deploying to EKS this is the account\_id | `string` | `""` | no |
| <a name="input_install"></a> [install](#input\_install) | Enable (if true) or disable (if false) the installation of the Sensedia Discovery Tool. | `bool` | `false` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Namespace to use as node selector in case of vpn cluster. <br> This is necessary to avoid the deployment of the Sensedia Discovery Tool in a cluster that is placed inside a subnet without any more IPs available. | `string` | `"none"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions. | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Container image repository for the Sensedia Discovery Tool. | `string` | `"473412377568.dkr.ecr.sa-east-1.amazonaws.com/discovery-tool"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Schedule for running Sensedia Discovery Tool. | `string` | `"0 * * * *"` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | Container image tag for the Sensedia Discovery Tool. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_time_wait"></a> [time\_wait](#input\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | Time zone using for logs of Sensedia Discovery Tool. | `string` | `"America/Sao_Paulo"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
