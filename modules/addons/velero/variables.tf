################################################################################
# Velero
################################################################################
variable "install" {
  description = "Enable (if true) or disable (if false) the installation of Velero."
  type        = bool
  default     = false
}

variable "time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "velero_s3_bucket_name" {
  description = "The s3 bucket for velero backups storage."
  type        = string
  default     = ""
}

variable "velero_s3_bucket_prefix" {
  description = "The s3 bucket directory prefix."
  type        = string
  default     = ""
}

variable "velero_s3_bucket_region" {
  description = "The s3 bucket region for velero backup."
  type        = string
  default     = ""
}

variable "velero_deploy_fsbackup" {
  description = "Whether FileSystemBackup should be deployed to migrate volumes at filesystem level."
  type        = bool
  default     = false
}

variable "velero_default_fsbackup" {
  description = "True if all volume migration should use FileSystemBackup. False otherwise."
  type        = bool
  default     = false
}

variable "velero_snapshot_enabled" {
  description = "True if volume migration should use snapshot."
  type        = bool
  default     = false
}

variable "region" {
  description = "AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions."
  type        = string
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
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
