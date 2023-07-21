################################################################################
# traefik
################################################################################
variable "install" {
  description = "Enable (if true) or disable (if false) the installation of the trafik."
  type        = bool
  default     = true
}

variable "time_wait" {
  type        = string
  description = "Time wait after cluster creation for access API Server for resource deploy."
  default     = "30s"
}

variable "vpc_cidr_block" {
  description = "CIDR of the VPC where the cluster and its nodes will be provisioned."
  type        = list(string)
  default     = []
}

variable "create_ingress" {
  description = "Enable (if true) or disable (if false) the creation of the traefik ingress. The parameters 'install_aws_loadbalancer_controller' and 'install_traefik' must have 'true' value."
  type        = bool
  default     = true
}

variable "ingress_certificate_arn" {
  description = "ARN of a certificate to attach an AWS ALB linked to traefik-ingress."
  type        = string
  default     = ""
}

variable "ingress_inbound_cidrs" {
  type        = string
  description = "Allow list of a string with CIDR of inbound Addresses, separeted by comma."
  default     = "0.0.0.0/0"
}

variable "scost" {
  description = "A value to associate all internal components to a specific cost ID."
  type        = string
  default     = ""
}
variable "environment" {
  description = "Name of environment."
  type        = string
}
