
## How to deploy AiiDAlab on an Azure Kubernetes Service (AKS)
### Prerequisites

#### Setup Azure CLI

Either us the [Azure cloud shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) on the Azure portal or follow the instructions here to install the Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

#### Azure Resource Manager Storage Account

Using the template here, terraform maintains the state of your infrastructure both locally and in a dedicated storage account on Azure.
Using a storage account serves as backup for your terraform state and allows multiple users to work on the same infrastructure.
You should therefore store the terraform state in a subscription-wide accessible storage account so that it is backed up and can be shared among users.

Typically, the administrator for your unit will already have created a storage account for you.
Please ask your unit administrator to provide you with the following credentials:

- The Azure storage account name.
- The resource group name of the storage account.
- The storage account terraform container name.

You will have to provide the information during the setup of the first deployment after which they are stored locally such that you do not need enter them manually each time.

If you are the administrator of the storage account, you can create a new storage account by following the instructions here: https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create

#### Service Account Principal

You also need a service account principal for terraform to setup the Kubernetes cluster and use the Helm provider.

Your administrator might have already created a service account principal for you in which case, ask them to provide:

- the service account principal app id
- the service account principal password
- the service account object id

**IMPORTANT: DO NOT STORE THESE CREDENTIALS IN PLAIN TEXT IN YOUR REPOSITORY.**

Instead, we recommend to store them as environment variables in your local development environment.
For example, edit your `~/.bashrc` file and add the following lines:
```
export TF_VAR_arm_client_id="<service_principal_appid>"
export TF_VAR_arm_client_secret="<service_principal_password>"
export TF_VAR_arm_client_object_id="<service_principal_object_id>"
```

In this way they will be automatically picked up by terraform and you do not need to enter them on every operation.

##### How to create a service account principal

In case that you have to obtain service principal credentials yourself, please follow the instructions here: https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#create-a-service-principal
The service credential object id can be obtained via the portal or by executing the following command:
```
az ad sp list --display-name "<display_name>" --query "[].{\"Object ID\":objectId}" --output table
```
See also: https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#1-configure-your-environment

#### DNS-zone

You do not need to create a DNS zone to deploy AiiDAlab however doing so will allow you to automatically configure the DNS entry for your deployment.

**IMPORTANT**: Manipulating DNS settings has the potential to be very destructive to disrupt all deployments routed on the associated domain.
Please make sure that you have the authority to manage DNS zones.
In doubt, ask your unit administrator whether a DNS zone has already been created.

The template wizard will ask whether you want to create a DNS zone during setup.
You should not do this unless you are the administrator of the affected domain and are positive that you no one else has already created a DNS zone for the affected domain.

## Deploy AiiDAlab

We recommend to keep all terraform resources created with this template in a dedicated and backed up location on your local machine, for example in a directory called `~/terraform-deployments`.
The individual resource directories are then automatically named by the associated hostname.
For example, an AiiDAlab deployment with hostname `aiidalab.contoso.com` will be stored in `~/terraform-deployments/aiidalab.contoso.com`.
The associated DNS zone would be stored in `~/terraform-deployments/contoso.com.`.

1. Decide which hostname you will use for your deployment, e.g. `aiidalab.contoso.com` with a top-level domain under your control. See the DNS-zone section on how to create and automatically use a DNS zone.
1. By default, we use GitHub for authentication. For this we need to create a GitHub OAuth app that you can create by following the instructions on https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app. The hostname should be the one you choose beforehand, the callback url is `${HOSTNAME}/hub/oauth_callback`.
1. Create a Python environment with Python 3.8 or newer.
1. Install Git 2.27 or newer.
1. Install pipx with `pip install pipx`.
1. Install copier with `pipx install copier`.
1. Create a new deployment with `copier https://github.com/aiidalab/aiidalab-on-azure ~/terraform-deployments` and follow the instructions.
1. Switch into the directory created for the deployment (e.g. `~/terraform-deployments/aiidalab.contoso.com`) and initialize the terraform setup by running `terraform init`.
1. Create the deployment by running `terraform apply`.

## Monitor and maintain the cluster

1. First, obtain the KUBECONFIG file with the command `echo "$(terraform output kube_config)" > ./azurek8s`. You might have to remove EOT characters from the file.
1. Then set the KUBECONFIG environment variable to the file you just created with `KUBECONFIG=./azurek8s`.
1. Check that you are able to access the cluster with the command `kubectl get nodes`.

## Tear down deployment

To tear down a deployment, simply go to the corresponding resource and run `terraform destroy`.
After that you can delete the GitHub OAuth app in case that you used it for authentication.

**Due to a bug, the DNS entry must be deleted manually.**

## Known issues

1. The DNS entry is not properly removed after destroying the deployment.
1. The GitHub OAuth client secret is stored in plain text in the JupyterHub helm release configuration.
1. Sometimes the SSL certificate of the JupyterHub service is not properly configured. It can help to restart the autohttps pod.
