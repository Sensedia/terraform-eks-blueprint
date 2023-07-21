variable "install" {
  description = "Enable (if true) or disable (if false) the installation of the Sensedia Discovery Tool."
  type        = bool
  default     = false
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

variable "region" {
  description = "AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions."
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider that will be installed the Sensedia Discovery Tool."
  type        = string
  default     = "aws"
}

variable "api_key" {
  description = "API key to allow this implementaion to comunicate with the Backoffice API."
  type        = string
  default     = ""
}

variable "address" {
  description = "Backoffice API address."
  type        = string
  default     = "https://backofficeapi.sensedia.net"
}

variable "time_zone" {
  description = "Time zone using for logs of Sensedia Discovery Tool."
  type        = string
  default     = "America/Sao_Paulo"
}

variable "repository" {
  description = "Container image repository for the Sensedia Discovery Tool."
  type        = string
  default     = "473412377568.dkr.ecr.sa-east-1.amazonaws.com/discovery-tool"
}

variable "tag" {
  type        = string
  description = "Container image tag for the Sensedia Discovery Tool."
  default     = ""
}

variable "node_selector" {
  description = "Namespace to use as node selector in case of vpn cluster. \n This is necessary to avoid the deployment of the Sensedia Discovery Tool in a cluster that is placed inside a subnet without any more IPs available."
  type        = string
  default     = "none"
}

variable "schedule" {
  description = "Schedule for running Sensedia Discovery Tool."
  type        = string
  default     = "0 * * * *"
}

variable "identity" {
  description = "When on GKE this is the project_id; when deploying to EKS this is the account_id"
  type        = string
  default     = ""
}

variable "cluster_zone" {
  description = "When on GKE this is required; When in EKS is optional;"
  type        = string
  default     = "none"
}

variable "control_plane_cluster" {
  description = "Tells if it's a control plane cluster or not. Example: management-dyl0 is a control plane cluster, so you must set this variable to true."
  type        = string
  default     = "false"
}
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
