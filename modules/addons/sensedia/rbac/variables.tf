variable "enable_developers_permissions_core_resources" {
  description = "Enable (if true) or disable (if false) the creation of the developers permissions to access core resources in the cluster."
  type        = bool
  default     = true
}

variable "enable_developers_permissions_istio_resources" {
  description = "Enable (if true) or disable (if false) the creation of the developers permissions to access Istio resources in the cluster."
  type        = bool
  default     = false
}

variable "enable_developers_permissions_knative_resources" {
  description = "Enable (if true) or disable (if false) the creation of the developers permissions to access Knative resources in the cluster."
  type        = bool
  default     = false
}

variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}
