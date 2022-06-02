terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "{{ tfstate_resource_group_name }}"
    storage_account_name = "{{ tfstate_storage_account_name }}"
    container_name       = "{{ tfstate_container_name }}"
    key                  = "{{ dns_zone_name }}.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
