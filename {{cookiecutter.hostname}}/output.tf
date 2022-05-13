output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "client_key" {
  value = module.cluster.kube_config.0.client_key
}

output "client_certificate" {
  value = module.cluster.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = module.cluster.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = module.cluster.kube_config.0.username
}

output "cluster_password" {
  value = module.cluster.kube_config.0.password
}

output "kube_config" {
  value     = module.cluster.kube_config_raw
  sensitive = true
}

output "host" {
  value = module.cluster.kube_config.0.host
}
