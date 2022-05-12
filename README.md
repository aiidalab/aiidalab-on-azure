
## How to deploy AiiDAlab on an Azure Kubernetes Service (AKS)
### Prerequisite steps

1. Decide which hostname you will use for your deployment, e.g. `my-aiidalab.example.com` with a top-level domain under your control.
1. Follow instructions on https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks to create a service account principal and storage account for terraform.
1. (optional) If you want the DNS records be created automaticaly, create a DNS zone via the dns-zone module and configure it following the instructions on https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns.

## Deploy AiiDAlab

1. By default, we use GitHub for authentication. For this we need to create a GitHub OAuth app that you can create by following the instructions on https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app. The hostname should be the one you choose beforehand, the callback url is `${HOSTNAME}/hub/oauth_callback`.
1. Create a Python environment (Python 3.10) and install cookiecutter, e.g., with `pip install cookiecutter`.
1. Create a new deployment with `./generate ${HOSTNAME}.` and provide the requested information.
1. Switch into the directory created for the deployment and initialize the terraform setup by running `terraform init`.
1. Create the deployment by running `terraform apply`.
