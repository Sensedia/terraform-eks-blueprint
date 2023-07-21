variable "enable" {
  description = "Enable (if true) or disable (if false) the customization of namespaces. Requires 'namespace_customization' parameter to be set."
  type        = bool
  default     = false
}
variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}
variable "kubeconfig" {
  description = "Configuration to store cluster authentication information for kubectl"
  type        = string
  default     = ""
}
variable "namespace_customizations" {
  description = "Map with customizations of namespaces."
  type        = any
  default     = {}
}
