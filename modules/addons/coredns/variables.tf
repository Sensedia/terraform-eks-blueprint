variable "install" {
  description = "Enable (if true) or disable (if false) the installation of coreDNS EKS Addon."
  type        = bool
  default     = true
}
variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`)."
  type        = string
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
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
