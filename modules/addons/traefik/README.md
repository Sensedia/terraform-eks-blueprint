# traefik

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
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.alb_traefik_ingress](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_ingress"></a> [create\_ingress](#input\_create\_ingress) | Enable (if true) or disable (if false) the creation of the traefik ingress. The parameters 'install\_aws\_loadbalancer\_controller' and 'install\_traefik' must have 'true' value. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of environment. | `string` | n/a | yes |
| <a name="input_ingress_certificate_arn"></a> [ingress\_certificate\_arn](#input\_ingress\_certificate\_arn) | ARN of a certificate to attach an AWS ALB linked to traefik-ingress. | `string` | `""` | no |
| <a name="input_ingress_inbound_cidrs"></a> [ingress\_inbound\_cidrs](#input\_ingress\_inbound\_cidrs) | Allow list of a string with CIDR of inbound Addresses, separeted by comma. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_install"></a> [install](#input\_install) | Enable (if true) or disable (if false) the installation of the trafik. | `bool` | `true` | no |
| <a name="input_scost"></a> [scost](#input\_scost) | A value to associate all internal components to a specific cost ID. | `string` | `""` | no |
| <a name="input_time_wait"></a> [time\_wait](#input\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR of the VPC where the cluster and its nodes will be provisioned. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
