################################################################################
# Node Termination Handler
################################################################################
variable "install" {
  description = "Enable (if true) or disable (if false) the installation of the node-termination-handler."
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
  default     = ""
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
