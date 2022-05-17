resource "azurerm_resource_group" "dns_zone_rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_dns_zone" "root" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
}
