terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "{{ azurerm_storage_account_rg }}"
    storage_account_name = "{{ azurerm_storage_account_name }}"
    container_name       = "{{ azurerm_container_name }}"
    key                  = "{{ hostname }}.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
