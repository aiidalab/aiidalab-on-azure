1. Follow instructions on https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks to create a service account principal and storage account for terraform.
2. Create a Python environment (Python 3.10) and install cookiecutter, e.g., with `pip install cookiecutter`.
3. Create a new deployment with `cookiecutter .`
4. Switch into the directory created for the deployment and create it with `terraform apply`.
