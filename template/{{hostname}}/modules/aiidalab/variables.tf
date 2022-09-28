# tflint-ignore: terraform_unused_declarations
variable "dns_zone_resource_group_name" {
  description = "The resource group name of the DNS zone"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "dns_zone_name" {
  description = "The name of the DNS zone"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "aks_service_principal_app_id" {
  description = "The application ID of the service principal"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "aks_service_principal_client_secret" {
  description = "The client secret of the service principal"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "aks_service_principal_object_id" {
  description = "The object ID of the service principal"
  type        = string
}
