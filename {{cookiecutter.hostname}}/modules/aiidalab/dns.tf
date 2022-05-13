data "azurerm_resource_group" "dns_zone_rg" {
  name = var.dns_zone_resource_group_name
}

data "azurerm_dns_zone" "root" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

data "azurerm_subscription" "current" {
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.3.0"

  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.tenantId"
    value = data.azurerm_subscription.current.tenant_id
  }

  set {
    name  = "azure.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name  = "azure.resourceGroup"
    value = data.azurerm_resource_group.dns_zone_rg.name
  }

  set_sensitive {
    name  = "azure.aadClientId"
    value = var.aks_service_principal_app_id
  }

  set_sensitive {
    name  = "azure.aadClientSecret"
    value = var.aks_service_principal_client_secret
  }
}
