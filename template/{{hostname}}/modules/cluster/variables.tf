variable "cluster_name" {
  description = "The name of the cluster"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the cluster."
}

variable "dns_prefix" {
  default     = "k8s"
  description = "The DNS prefix to use for the cluster."
}

variable "ssh_public_key" {
  default     = "~/.ssh/id_rsa.pub"
  description = "The path to the SSH public key to use for SSH access to the cluster."
}

variable "agent_count" {
  default     = 3
  description = "The number of agents to use for the cluster."
}

variable "aks_service_principal_app_id" {
  description = "The application ID of the service principal"
}

variable "aks_service_principal_client_secret" {
  description = "The client secret of the service principal"
}

variable "aks_service_principal_object_id" {
  description = "The object ID of the service principal"
}

variable "user_nodes_vm_size" {
  default     = "Standard_D4s_v3"
  description = "The VM size to use for user nodes."
}

variable "user_nodes_autoscaling" {
  default     = true
  description = "Whether to enable autoscaling for user nodes."
}

variable "user_nodes_min_count" {
  default     = 0
  description = <<-EOF
      The minimum number of user nodes to use. Instead of increasing this
      value, it is recommended to increase the number of placeholder pods in the
      user nodes pool.
      EOF
}

variable "user_nodes_max_count" {
  default     = 10
  description = "The maximum number of user nodes to use."
}

variable "log_analytics_workspace_name" {
  default     = "testLogAnalyticsWorkspaceName"
  description = "The name of the Log Analytics workspace."
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default     = "eastus"
  description = "The location of the Log Analytics workspace."
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  default     = "PerGB2018"
  description = "The SKU of the Log Analytics workspace."
}
