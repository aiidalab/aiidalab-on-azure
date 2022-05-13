variable "cluster_name" {

}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the cluster."
}

variable "dns_prefix" {
  default = "k8s"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "agent_count" {
  default = 3
}

variable "aks_service_principal_app_id" {
}

variable "aks_service_principal_client_secret" {
}

variable "aks_service_principal_object_id" {
}

variable "user_nodes_vm_size" {
  default = "Standard_D4s_v3"
}

variable "user_nodes_autoscaling" {
  default = true
}

variable "user_nodes_min_count" {
  default = 1
}

variable "user_nodes_max_count" {
  default = 10
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}
