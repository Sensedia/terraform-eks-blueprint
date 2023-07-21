variable "install" {
  description = "Enable (if true) or disable (if false) the installation of the Cluster Autoscaler."
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
variable "cluster_oidc_provider_arn" {
  description = "Cluster OIDC provider ARN."
  type        = string
  default     = ""
}
variable "region" {
  description = "AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions."
  type        = string
}
variable "image_tag" {
  description = "Image tag used on Cluster Autoscaler helm deploy."
  type        = string
}
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
