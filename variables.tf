################################################################################
# general
################################################################################

variable "region" {
  description = "AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}


################################################################################
# cluster
################################################################################
variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane."
  type        = list(string)
  default     = []
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)."
  type        = list(string)
  default     = ["authenticator"]
}

variable "create_kms_key" {
  description = "In the 18.x version of public module terraform-aws-eks, 'create_kms_key' was 'false', but in the 19.x version it is 'true'. Clusters created with this module now default to enabling secret encryption by default with a customer-managed KMS key created by this module. But we do not want this. We will use the KMS created by another module in the AWS account."
  type        = bool
  default     = false
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = ""
}

variable "cluster_short_name" {
  description = "Short name of the EKS cluster."
  type        = string
  default     = ""
  validation {
    condition     = length(var.cluster_short_name) <= 38
    error_message = "The 'cluster_short_name' value must be lower or equal than 38 characters."
  }
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.25`)."
  type        = string
  default     = "1.25"
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets."
  type        = list(string)
  default     = []
}

variable "type_worker_node_group" {
  description = "Enter type of worker node group. Types supported: KARPENTER, AWS_MANAGED_NODE (requires 'eks_managed_node_groups' parameter to be set) and SELF_MANAGED_NODE (requires 'self_managed_node_groups' parameter to be set)."
  type        = string
  default     = "AWS_MANAGED_NODE"
  validation {
    condition     = contains(["KARPENTER", "AWS_MANAGED_NODE", "SELF_MANAGED_NODE"], var.type_worker_node_group)
    error_message = "Use a valid option. Types supported: KARPENTER, AWS_MANAGED_NODE and SELF_MANAGED_NODE."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and its nodes will be provisioned."
  type        = string
  default     = null
}

variable "vpc_cidr_block" {
  description = "CIDR of the VPC where the cluster and its nodes will be provisioned."
  type        = list(string)
  default     = []
}


################################################################################
# CloudWatch Log Group
################################################################################

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 7 days."
  type        = number
  default     = 7
}


################################################################################
# Cluster Security Group
################################################################################

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source."
  type        = any
  default     = {}
}


################################################################################
# Node Security Group
################################################################################
variable "node_security_group_enable_recommended_rules" {
  description = "Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic."
  type        = bool
  default     = true
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source."
  type        = any
  default     = {}
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created."
  type        = map(string)
  default     = {}
}


################################################################################
# Cluster IAM Role
################################################################################
variable "iam_role_name" {
  description = "Name to use on IAM role created."
  type        = string
  default     = null
}

variable "aws_auth_roles" {
  description = "List of additional IAM roles maps to add to the aws-auth configmap.  \n See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.24.1/examples/complete/main.tf#L206 for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of additional IAM users maps to add to the aws-auth configmap.  \n See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.24.1/examples/complete/main.tf#L214 for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}


################################################################################
# AWS EKS Managed Node Group
################################################################################
variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default     = {}
}

variable "mng_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values are `AL2_x86_64`, `AL2_x86_64_GPU`, `AL2_ARM_64`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64`"
  type        = string
  default     = "AL2_ARM_64"
}


################################################################################
# Self Managed Node Group
################################################################################
variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions to create"
  type        = any
  default     = {}
}

variable "self_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}


######################
# Addons
######################
variable "addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

################################################################################
# RBAC - Role-based access control
################################################################################
variable "sensedia_rbac" {
  description = "Sensedia RBAC to give access to developers."
  type        = any
  default     = {}
}
