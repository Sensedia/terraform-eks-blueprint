variable "install" {
  description = "Enable (if true) or disable (if false) the installation of Fluentbit."
  type        = bool
  default     = true
}
variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "cloudwatch_retention_in_days" {
  description = "Number of days to retain log events collected by fluentbit. Default retention - 7 days."
  type        = string
  default     = "7"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`)."
  type        = string
}

variable "image_tag" {
  description = "Image tag used on Fluentbit helm deploy."
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "Cluster OIDC provider ARN."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
