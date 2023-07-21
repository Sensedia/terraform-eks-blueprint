# CoreDNS 
moved {
  from = time_sleep.aws_eks_addon_coredns[0]
  to   = module.coredns["coredns"].time_sleep.this[0]
}
moved {
  from = aws_eks_addon.aws_eks_addon_coredns[0]
  to   = module.coredns["coredns"].aws_eks_addon.this[0]
}

# Metrics Server
moved {
  from = time_sleep.metrics
  to   = time_sleep.metrics_server[0]
}
moved {
  from = time_sleep.metrics_server[0]
  to   = module.metrics_server["metrics-server"].time_sleep.this[0]
}
moved {
  from = helm_release.metrics-server
  to   = helm_release.metrics_server[0]
}
moved {
  from = helm_release.metrics_server[0]
  to   = module.metrics_server["metrics-server"].helm_release.this[0]
}

# Kube Proxy
moved {
  from = time_sleep.aws_eks_addon_kube_proxy[0]
  to   = module.kube_proxy["kube-proxy"].time_sleep.this[0]
}
moved {
  from = aws_eks_addon.aws_eks_addon_kube_proxy[0]
  to   = module.kube_proxy["kube-proxy"].aws_eks_addon.this[0]
}

# AWS Load Balancer Controller
moved {
  from = helm_release.aws-load-balancer-controller
  to   = helm_release.aws_load_balancer_controller[0]
}
moved {
  from = time_sleep.aws-load-balancer-controller
  to   = time_sleep.aws_load_balancer_controller[0]
}
moved {
  from = module.load_balancer_controller_irsa_role
  to   = module.load_balancer_controller_irsa_role[0]
}
moved {
  from = time_sleep.aws_load_balancer_controller[0]
  to   = module.aws_load_balancer_controller["aws-load-balancer-controller"].time_sleep.this[0]
}
moved {
  from = helm_release.aws_load_balancer_controller[0]
  to   = module.aws_load_balancer_controller["aws-load-balancer-controller"].helm_release.this[0]
}
moved {
  from = module.load_balancer_controller_irsa_role[0].aws_iam_role.this[0]
  to   = module.aws_load_balancer_controller["aws-load-balancer-controller"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.load_balancer_controller_irsa_role[0].aws_iam_policy.load_balancer_controller[0]
  to   = module.aws_load_balancer_controller["aws-load-balancer-controller"].module.irsa_role[0].aws_iam_policy.load_balancer_controller[0]
}
moved {
  from = module.load_balancer_controller_irsa_role[0].aws_iam_role_policy_attachment.load_balancer_controller[0]
  to   = module.aws_load_balancer_controller["aws-load-balancer-controller"].module.irsa_role[0].aws_iam_role_policy_attachment.load_balancer_controller[0]
}


# Cluster Autoscaler
moved {
  from = time_sleep.cluster_autoscaler[0]
  to   = module.cluster_autoscaler["cluster-autoscaler"].time_sleep.this[0]
}
moved {
  from = helm_release.cluster_autoscaler[0]
  to   = module.cluster_autoscaler["cluster-autoscaler"].helm_release.this[0]
}
moved {
  from = module.cluster_autoscaler_irsa_role[0].aws_iam_policy.cluster_autoscaler[0]
  to   = module.cluster_autoscaler["cluster-autoscaler"].module.irsa_role[0].aws_iam_policy.cluster_autoscaler[0]
}
moved {
  from = module.cluster_autoscaler_irsa_role[0].aws_iam_role.this[0]
  to   = module.cluster_autoscaler["cluster-autoscaler"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.cluster_autoscaler_irsa_role[0].aws_iam_role_policy_attachment.cluster_autoscaler[0]
  to   = module.cluster_autoscaler["cluster-autoscaler"].module.irsa_role[0].aws_iam_role_policy_attachment.cluster_autoscaler[0]
}

#####################
# Custom namespaces #
#####################
moved {
  from = time_sleep.namespace_customization[0]
  to   = module.custom_namespaces["custom-namespaces"].time_sleep.this[0]
}


############################
# Node Termination Handler #
############################
moved {
  from = time_sleep.node_termination_handler[0]
  to   = module.node_termination_handler["node-termination-handler"].time_sleep.this[0]
}
moved {
  from = helm_release.node_termination_handler[0]
  to   = module.node_termination_handler["node-termination-handler"].helm_release.this[0]
}
moved {
  from = module.node_termination_handler[0].aws_iam_policy.node_termination_handler[0]
  to   = module.node_termination_handler["node-termination-handler"].module.irsa_role[0].aws_iam_policy.node_termination_handler[0]
}
moved {
  from = module.node_termination_handler[0].aws_iam_role.this[0]
  to   = module.node_termination_handler["node-termination-handler"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.node_termination_handler[0].aws_iam_role_policy_attachment.node_termination_handler[0]
  to   = module.node_termination_handler["node-termination-handler"].module.irsa_role[0].aws_iam_role_policy_attachment.node_termination_handler[0]
}

###########
# Traefik #
###########

moved {
  from = time_sleep.traefik
  to   = time_sleep.traefik[0]
}
moved {
  from = time_sleep.traefik[0]
  to   = module.traefik["traefik"].time_sleep.this[0]
}
moved {
  from = helm_release.traefik-ingress
  to   = helm_release.traefik[0]
}
moved {
  from = helm_release.traefik[0]
  to   = module.traefik["traefik"].helm_release.this[0]
}
moved {
  from = kubectl_manifest.alb_traefik_ingress[0]
  to   = module.traefik["traefik"].kubectl_manifest.alb_traefik_ingress[0]
}

##########
# Velero #
##########
moved {
  from = time_sleep.velero[0]
  to   = module.velero["velero"].time_sleep.this[0]
}
moved {
  from = helm_release.velero[0]
  to   = module.velero["velero"].helm_release.thias[0]
}
moved {
  from = module.velero_irsa_policy[0].aws_iam_policy.policy[0]
  to   = module.velero["velero"].module.irsa_policy[0].aws_iam_policy.policy[0]
}
moved {
  from = module.velero_irsa_role[0].aws_iam_role.this[0]
  to   = module.velero["velero"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.velero_irsa_role[0].aws_iam_role_policy_attachment.this["velero"]
  to   = module.velero["velero"].module.irsa_role[0].aws_iam_role_policy_attachment.this["velero"]
}


###########
# VPC CNI #
###########
moved {
  from = time_sleep.aws_vpc_cni[0]
  to   = module.vpc_cni["vpc-cni"].time_sleep.this[0]
}
# helm_release.aws_vpc_cni_without_vpn[0]
# moved { 
#   from = 
#   to   = module.vpc_cni["vpc-cni"].aws_eks_addon.this[0]
# }
moved {
  from = module.vpc_cni_ipv4_irsa_role
  to   = module.vpc_cni_ipv4_irsa_role[0]
}
moved {
  from = module.vpc_cni_ipv4_irsa_role[0].aws_iam_policy.vpc_cni[0]
  to   = module.vpc_cni["vpc-cni"].module.irsa_role[0].aws_iam_policy.vpc_cni[0]
}
moved {
  from = module.vpc_cni_ipv4_irsa_role[0].aws_iam_role.this[0]
  to   = module.vpc_cni["vpc-cni"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.vpc_cni_ipv4_irsa_role[0].aws_iam_role_policy_attachment.vpc_cni[0]
  to   = module.vpc_cni["vpc-cni"].module.irsa_role[0].aws_iam_role_policy_attachment.vpc_cni[0]
}

######################
# AWS EBS CSI Driver #
######################
moved {
  from = time_sleep.aws_ebs_csi_driver
  to   = time_sleep.aws_ebs_csi_driver[0]
}
moved {
  from = aws_eks_addon.aws_ebs_csi_driver
  to   = aws_eks_addon.aws_ebs_csi_driver[0]
}
moved {
  from = module.aws_ebs_csi_driver_irsa.aws_iam_policy.ebs_csi[0]
  to   = module.aws_ebs_csi_driver_irsa[0].aws_iam_policy.ebs_csi[0]
}
moved {
  from = module.aws_ebs_csi_driver_irsa.aws_iam_role.this[0]
  to   = module.aws_ebs_csi_driver_irsa[0].aws_iam_role.this[0]
}
moved {
  from = module.aws_ebs_csi_driver_irsa.aws_iam_role_policy_attachment.ebs_csi[0]
  to   = module.aws_ebs_csi_driver_irsa[0].aws_iam_role_policy_attachment.ebs_csi[0]
}
moved {
  from = time_sleep.aws_ebs_csi_driver[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].time_sleep.this[0]
}
moved {
  from = aws_eks_addon.aws_ebs_csi_driver[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].aws_eks_addon.this[0]
}
moved {
  from = kubectl_manifest.storage_class_gp3[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].kubectl_manifest.storage_class_gp3[0]
}
moved {
  from = null_resource.storage_class_gp3[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].null_resource.storage_class_gp3[0]
}
moved {
  from = module.aws_ebs_csi_driver_irsa[0].aws_iam_policy.ebs_csi[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].module.irsa_role[0].aws_iam_policy.ebs_csi[0]
}
moved {
  from = module.aws_ebs_csi_driver_irsa[0].aws_iam_role.this[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.aws_ebs_csi_driver_irsa[0].aws_iam_role_policy_attachment.ebs_csi[0]
  to   = module.aws_ebs_csi_driver["aws-ebs-csi-driver"].module.irsa_role[0].aws_iam_role_policy_attachment.ebs_csi[0]
}


# AWS EFS CSI Driver
moved {
  from = time_sleep.aws_efs_csi_driver[0]
  to   = module.aws_efs_csi_driver["aws-efs-csi-driver"].time_sleep.this[0]
}
moved {
  from = helm_release.aws_efs_csi_driver[0]
  to   = module.aws_efs_csi_driver["aws-efs-csi-driver"].helm_release.this[0]
}
moved {
  from = module.aws_efs_csi_driver_irsa[0].aws_iam_policy.efs_csi[0]
  to   = module.aws_efs_csi_driver["aws-efs-csi-driver"].module.irsa_role[0].aws_iam_policy.efs_csi[0]
}
moved {
  from = module.aws_efs_csi_driver_irsa[0].aws_iam_role.this[0]
  to   = module.aws_efs_csi_driver["aws-efs-csi-driver"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.aws_efs_csi_driver_irsa[0].aws_iam_role_policy_attachment.efs_csi[0]
  to   = module.aws_efs_csi_driver["aws-efs-csi-driver"].module.irsa_role[0].aws_iam_role_policy_attachment.efs_csi[0]
}


# Sensedia Discovery tool
moved {
  from = time_sleep.discovery_tool[0]
  to   = module.discovery_tool["discovery-tool"].time_sleep.this[0]
}
moved {
  from = kubectl_manifest.discovery_tool_00[0]
  to   = module.discovery_tool["discovery-tool"].kubectl_manifest.discovery_tool_00[0]
}
moved {
  from = kubectl_manifest.discovery_tool_01[0]
  to   = module.discovery_tool["discovery-tool"].kubectl_manifest.discovery_tool_01[0]
}
moved {
  from = kubectl_manifest.discovery_tool_02["/apis/batch/v1/namespaces/discovery-tool/cronjobs/discovery-tool"]
  to   = module.discovery_tool["discovery-tool"].kubectl_manifest.discovery_tool_02["/apis/batch/v1/namespaces/discovery-tool/cronjobs/discovery-tool"]
}
moved {
  from = kubectl_manifest.discovery_tool_02["/apis/rbac.authorization.k8s.io/v1/namespaces/discovery-tool/clusterrolebindings/discovery-tool-rolebinding"]
  to   = module.discovery_tool["discovery-tool"].kubectl_manifest.discovery_tool_02["/apis/rbac.authorization.k8s.io/v1/namespaces/discovery-tool/clusterrolebindings/discovery-tool-rolebinding"]
}
moved {
  from = kubectl_manifest.discovery_tool_02["/apis/rbac.authorization.k8s.io/v1/namespaces/discovery-tool/clusterroles/discovery-tool-role"]
  to   = module.discovery_tool["discovery-tool"].kubectl_manifest.discovery_tool_02["/apis/rbac.authorization.k8s.io/v1/namespaces/discovery-tool/clusterroles/discovery-tool-role"]
}
moved {
  from = module.discovery_tool_irsa_policy[0].aws_iam_policy.policy[0]
  to   = module.discovery_tool["discovery-tool"].module.irsa_policy[0].aws_iam_policy.policy[0]
}
moved {
  from = module.discovery_tool_irsa_role[0].aws_iam_role.this[0]
  to   = module.discovery_tool["discovery-tool"].module.irsa_role[0].aws_iam_role.this[0]
}
moved {
  from = module.discovery_tool_irsa_role[0].aws_iam_role_policy_attachment.this["discovery-tool"]
  to   = module.discovery_tool["discovery-tool"].module.irsa_role[0].aws_iam_role_policy_attachment.this["discovery-tool"]
}

# FluentBit
# kubectl_manifest.fluentbit_00["/api/v1/namespaces/amazon-cloudwatch"]
# kubectl_manifest.fluentbit_00["/api/v1/namespaces/amazon-cloudwatch/configmaps/fluent-bit-cluster-info"]
# kubectl_manifest.fluentbit_01
# kubectl_manifest.fluentbit_02["/api/v1/namespaces/amazon-cloudwatch/configmaps/fluent-bit-config"]
# kubectl_manifest.fluentbit_02["/apis/apps/v1/namespaces/amazon-cloudwatch/daemonsets/fluent-bit-compatible"]
# kubectl_manifest.fluentbit_02["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/fluent-bit-role-binding"]
# kubectl_manifest.fluentbit_02["/apis/rbac.authorization.k8s.io/v1/clusterroles/fluent-bit-role"]
# moved { 
#   from = 
#   to   = module.fluentbit["fluentbit"].helm_release.this[0]
# }
moved {
  from = aws_iam_policy.aws_for_fluentbit
  to   = module.fluentbit["fluentbit"].module.irsa_policy[0].aws_iam_policy.policy[0]
}
moved {
  from = module.fluentbit_irsa.aws_iam_role.this[0]
  to   = module.fluentbit["fluentbit"].module.role_irsa[0].aws_iam_role.this[0]
}
moved {
  from = module.fluentbit_irsa.aws_iam_role_policy_attachment.this["fluentbit_eks_policy"]
  to   = module.fluentbit["fluentbit"].module.role_irsa[0].aws_iam_role_policy_attachment.this["fluentbit_eks_policy"]
}

# AWS Auth
moved {
  from = kubernetes_config_map_v1_data.aws_auth[0]
  to   = module.eks.kubernetes_config_map_v1_data.aws_auth[0]
}

# Sensedia RBAC
moved {
  from = time_sleep.rbac[0]
  to   = module.sensedia_rbac.time_sleep.rbac[0]
}
moved {
  from = kubectl_manifest.developers_core_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/developers-clusterRoleBinding-core"]
  to   = module.sensedia_rbac.kubectl_manifest.developers_core_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/developers-clusterRoleBinding-core"]
}
moved {
  from = kubectl_manifest.developers_core_rbac["/apis/rbac.authorization.k8s.io/v1/clusterroles/developers-clusterRole-core"]
  to   = module.sensedia_rbac.kubectl_manifest.developers_core_rbac["/apis/rbac.authorization.k8s.io/v1/clusterroles/developers-clusterRole-core"]
}
moved {
  from = kubectl_manifest.developers_istio_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/developers-clusterRoleBinding-istio"]
  to   = module.sensedia_rbac.kubectl_manifest.developers_istio_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/developers-clusterRoleBinding-istio"]
}
moved {
  from = kubectl_manifest.developers_istio_rbac["/apis/rbac.authorization.k8s.io/v1/clusterroles/developers-clusterRole-istio"]
  to   = module.sensedia_rbac.kubectl_manifest.developers_istio_rbac["/apis/rbac.authorization.k8s.io/v1/clusterroles/developers-clusterRole-istio"]
}
moved {
  from = kubectl_manifest.developers_knative_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/developers-clusterRoleBinding-knative"]
  to   = module.sensedia_rbac.kubectl_manifest.developers_knative_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/developers-clusterRoleBinding-knative"]
}
moved {
  from = kubectl_manifest.developers_knative_rbac["/apis/rbac.authorization.k8s.io/v1/clusterroles/developers-clusterRole-knative"]
  to   = module.sensedia_rbac.kubectl_manifest.developers_knative_rbac["/apis/rbac.authorization.k8s.io/v1/clusterroles/developers-clusterRole-knative"]
}
moved {
  from = kubectl_manifest.view_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/view"]
  to   = module.sensedia_rbac.kubectl_manifest.view_rbac["/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/view"]
}


#############
# Karpenter #
#############
moved {
  from = module.karpenter_irsa
  to   = module.karpenter_irsa[0]
}
