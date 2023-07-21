################################################################################
# Kube-proxy EKS Addon
################################################################################
variable "install" {
  description = "Enable (if true) or disable (if false) the installation of Kube-proxy EKS Addon."
  type        = bool
  default     = true
}
variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}
variable "support_vpn" {
  description = "Enable (if true) or disable (if false) support to VPN (Virtual Private Network)."
  type        = bool
  default     = true
}
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`)."
  type        = string
}
variable "cluster_oidc_provider_arn" {
  description = "Cluster OIDC provider ARN."
  type        = string
  default     = ""
}
variable "resolve_conflicts" {
  description = "(Optional) Define how to resolve parameter value conflicts when migrating an existing coreDNS EKS addon to an Amazon EKS add-on or when applying version updates to the add-on. Valid values are `NONE`, `OVERWRITE` and `PRESERVE`. For more details check UpdateAddon(https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html) API Docs."
  type        = string
  default     = "OVERWRITE"
}
variable "configuration_values" {
  description = "(Optional) custom configuration values for coreDNS EKS addon with single JSON string. This JSON string value must match the JSON schema derived from describe-addon-configuration(https://docs.aws.amazon.com/cli/latest/reference/eks/describe-addon-configuration.html)."
  type        = string
  default     = "{}"
}
variable "preserve" {
  description = "(Optional) Indicates if you want to preserve the created resources when deleting coreDNS EKS addon."
  type        = bool
  default     = true
}
variable "aws_vpc_cni_minimum_ip" {
  description = "Minimum amount of IPs each worker node will reserve for yourself from subnet."
  type        = number
  default     = 14
}
variable "aws_vpc_cni_warm_ip" {
  description = "How many IPs worker node will reserve each call to EC2 API."
  type        = number
  default     = 2
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
