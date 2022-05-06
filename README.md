1. Follow instructions on https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks to create a service account principal and storage account for terraform and create `terraform.tfvars` file for variables `aks_service_principal_app_id`, `aks_service_principal_client_secret`, `aks_service_principal_object_id`.
2. Create cluster with `terraform apply`.
