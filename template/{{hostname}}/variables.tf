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

variable "dns_zone_name" {
}

variable "arm_client_id" {
}

variable "arm_client_secret" {
}

variable "arm_client_object_id" {
}
