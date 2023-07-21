################################################################################
# karpenter
################################################################################
variable "install" {
  description = "Enable (if true) or disable (if false) the installation of Karpenter."
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

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = ""
}
variable "cluster_oidc_provider_arn" {
  description = "Cluster OIDC provider ARN."
  type        = string
  default     = ""
}

variable "iam_role_arn" {
  description = "IAM role ARN of the Karpenter Assumes"
  type        = string
  default     = ""
}

variable "irsa_name" {
  description = "Name of IAM role for service accounts"
  type        = string
  default     = null
}

variable "irsa_tag_key" {
  description = "Tag key (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner"
  type        = string
  default     = "karpenter.sh/discovery"
}

variable "irsa_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "karpenter_cpu_limit" {
  description = "CPU Limits to launch total nodes."
  type        = string
  default     = "100"
}

variable "karpenter_memory_limit" {
  description = "Memory Limits to launch total nodes."
  type        = string
  default     = "400Gi"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
