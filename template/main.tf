resource "random_pet" "rg-name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg-name.id
  location = var.resource_group_location
}

module "cluster" {
  source = "./modules/cluster"

  resource_group_name                 = azurerm_resource_group.rg.name
  cluster_name                        = var.cluster_name
  ssh_public_key                      = var.ssh_public_key
  aks_service_principal_app_id        = var.aks_service_principal_app_id
  aks_service_principal_client_secret = var.aks_service_principal_client_secret
  aks_service_principal_object_id     = var.aks_service_principal_object_id
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.kube_config.0.host
    username               = module.cluster.kube_config.0.username
    password               = module.cluster.kube_config.0.password
    client_certificate     = base64decode(module.cluster.kube_config.0.client_certificate)
    client_key             = base64decode(module.cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(module.cluster.kube_config.0.cluster_ca_certificate)
  }
}
module "aiidalab" {
  source                              = "./modules/aiidalab"
  aks_service_principal_app_id        = var.aks_service_principal_app_id
  aks_service_principal_client_secret = var.aks_service_principal_client_secret
  aks_service_principal_object_id     = var.aks_service_principal_object_id

  dns_zone_name                = var.dns_zone_name
  dns_zone_resource_group_name = var.dns_zone_resource_group_name
}
