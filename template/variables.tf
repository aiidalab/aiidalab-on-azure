variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
variable "cluster_name" {
  default = "k8s-cluster"
}

variable "dns_zone_resource_group_name" {
  default = "dns-zones"
}

variable "dns_zone_resource_group_location" {
  default = "eastus"
}

variable "dns_zone_name" {
  default = "{{ cookiecutter.dns_zone_name }}"
}

variable "aks_service_principal_app_id" {
  default = "{{ cookiecutter.aks_service_principal_app_id }}"
}

variable "aks_service_principal_client_secret" {
  default = "{{ cookiecutter.aks_service_principal_client_secret }}"
}

variable "aks_service_principal_object_id" {
  default = "{{ cookiecutter.aks_service_principal_object_id }}"
}
