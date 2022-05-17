data "azurerm_dns_zone" "root" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

data "azurerm_resource_group" "dns_zone_rg" {
  name = var.dns_zone_resource_group_name
}
