terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "{{ cookiecutter.tfstate_resource_group_name }}"
    storage_account_name = "{{ cookiecutter.tfstate_storage_account_name }}"
    container_name       = "{{ cookiecutter.tfstate_container_name }}"
    key                  = "{{ cookiecutter.dns_zone_name }}.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
