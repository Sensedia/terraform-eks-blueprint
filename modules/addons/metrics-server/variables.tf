variable "install" {
  description = "Enable (if true) or disable (if false) the installation of the metrics-server."
  type        = bool
  default     = true
}
variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}
