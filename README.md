# AiiDAlab on Azure

This repository contains instructions and template files to deploy an [AiiDAlab](https://www.aiidalab.net) JupyterHub instance on Azure using the [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/) and [Terraform](https://www.terraform.io/).

## Create an AiiDAlab deployment on Azure (with AKS)

_Documentation is partially adapted from [here](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#1-configure-your-environment)._

### 1. Learn the Terraform basics

If you are not familiar with the purpose and basic use of Terraform yet, we recommend that you read the [Terraform Introduction](https://www.terraform.io/intro) and the [Terraform Core Workflow](https://www.terraform.io/intro/core-workflow) before proceeding.

### 2. Configure your environment


- **Azure subscription**: If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.

- **Configure Terraform:** If you haven't already done so, configure Terraform using one of the following options:

    - [Configure Terraform in Azure Cloud Shell with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash)
    - [Configure Terraform in Azure Cloud Shell with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell)
    - [Configure Terraform in Windows with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash)
    - [Configure Terraform in Windows with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)

- **Azure service principal:** If you or your unit administrator has not yet created a service principal, follow the instructions [here](https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure#create-a-service-principal) and make note of the `appId`, `display_name`, `password`, and `tenant`.

  Run the following command to get the object ID of the service principal: `az ad sp list --display-name "<display_name>" --query "[].{\"Object ID\":objectId}" --output table`

  **Do not store the service principal credentials within your deployment repository in plain text.**
  We recommend to store them as environment variables in your deployment environment.
  For example, edit your `~/.bashrc` file and add the following lines:
  ```
  export TF_VAR_arm_client_id="<service_principal_appid>"
  export TF_VAR_arm_client_secret="<service_principal_password>"
  export TF_VAR_arm_client_object_id="<service_principal_object_id>"
  ```
  In this way they are automatically picked up by Terraform when needed and you do not have to manually provide them.

- **SSH key pair**: Use the information in one of the following articles to create an SSH key pair:

    - [Portal](https://docs.microsoft.com/en-us/azure/virtual-machines/ssh-keys-portal#generate-new-keys)
    - [Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows#create-an-ssh-key-pair)
    - [Linux/MacOS](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#create-an-ssh-key-pair)

### 3. Configure Azure storage to store Terraform state

Your unit administrator may have already created an Azure storage account to store Terraform state for your unit, in which case please ask them to provide:

- The Azure storage account name.
- The resource group name of the storage account.
- The storage account terraform container name.

Otherwise, please follow the instructions [here](https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/terraform/create-k8s-cluster-with-tf-and-aks.md#2-configure-azure-storage-to-store-terraform-state) to create a storage account to store Terraform state.

Make note of the information listed above, it will be needed later during the setup process.

### 4. Create the AiiDAlab Terraform deployment directory

1. Decide on a **deployments directory**.

   We recommend to keep all Terraform resources created with this template in a dedicated and backed up location.
   For example, assuming that you are deploying from the Azure Cloud shell, you could store them directly in the `~/clouddrive` directory.

   Using this template, all resource directories are automatically named by their associated hostname.
   Following the example above, an AiiDAlab deployment at `aiidalab.contoso.com` would be stored in `~/clouddrive/aiidalab.contoso.com`.

   *Tip:* We recommend to track the deployments directory with git to naturally track changes to all deployments.
   This will also allow you to update and migrate existing deployments (see section *Update deployments*).

2. Decide on a **hostname** for your deployment.

   This will be a domain where you can access your AiiDAlab deployment, e.g., `aiidalab.contoso.com`.
   It is important that you have control over the DNS setting for the associated domain, in this case `contoso.com`.
   Please see the section on DNS-zones for automated DNS configuration.

3. Create a **GitHub OAuth application**

   By default, this template uses GitHub for user authentication, meaning that users must have a GitHub account to register and log in.
   [There are many other ways to authenticate users](https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/authentication.html) which you can manually configure if desired.

   Please follow the [GitHub documentation](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) to create a GitHub OAuth app.
   The app name is o your choice, e.g., `Contoso-AiiDAlab`.
   The _Homepage URL_ should be the full URL to your deployment, e.g., `https://aiidalab.contoso.com`.
   The _Authorization Callback URL_ for our example would then be `https://aiidalab.contoso.com/hub/oauth_callback`.

4. Install **copier**

   We use [copier](https://copier.readthedocs.io/en/stable/) to create an instance from this template.
   If needed, install Python 3.7 or newer and Git 2.72 or newer into your deployment environment.
   Both Python and Git are already installed in the Azure Cloud Shell environment.

   Then install copier with
   ```
   $ pip install pipx && pipx install copier
   ```

5. Create the **deployment** directory

   Finally, run the following command to create the Terraform deployment directory:
   ```
   $ copier gh:aiidalab/aiidalab-on-azure ~/clouddrive
   ```
   Where the last argument is your previously created deployment*s* directory.

### 5. Use Terraform to create the deployment

To create the deployment, switch into your _deployment directory_, e.g., `cd ~/clouddrive/aiidalab.contoso.com`, and run the following command:

```
$ terraform init

```

After succesful initialization, run the following command to apply all necessary changes, i.e., create all required resources for your deployment:

```
$ terraform apply
```

Make sure to _review_ the planned changes before applying them by confirming with `yes`.

### 6. Monitor and maintain the deployment

In order to interact with the Kubernetes cluster and for example check the status of individual nodes or pods, you first need to configure `kubectl` to use the `kubeconfig` of the cluster.

1. Change into your deployment directory (e.g. `cd ~/clouddrive/aiidalab.contoso.com`).
2. Create a kubeconfig file with the following command:
   ```
   $ echo "$(terraform output --raw kube_config)" > ./kubeconfig
   ```
3. Set the `KUBECONFIG` environment variable to point to the kubeconfig file we just created:
   ```
   $ KUBECONFIG=./kubeconfig
   ```
4. Finally, check whether you can access the cluster, e.g., with the `$ kubectl get node` command.

*Tip:* The deployment directory contains a script that performs steps 2 and 3 for you with `$ source setup-kubeconfig`.

### 7. Configure your domain

We recommend to use DNS-zones for automated DNS configuration (see section on *DNS-zones*).
If you are not using DNS zones, you will have to set an A or C record for your domain.

1. Obtain the IP for your deployment from Terraform:
   ```
   $ kubectl -n default get svc proxy-public -o jsonpath='{.status.loadBalancer.ingress[].ip}'
   ```
2. Go to your DNS registrar and add an A record or C record for your domain.

   Use an A record if the address is an actual IP address of the form 123.123.123.123 and a C record
   if the address is a domain name.

Depending on your registrar, it might take a few minutes to many hours for the DNS record to propagate.
### 8. Enable https

After the deployment is created, verify that you can reach it under the specified hostname, (e.g. `aiidalab.contoso.com`) for example on the command line with
```
$ curl -k https://aiidalab.contoso.com
```
or by checking the DNS propagation explicitly with an online tool in your browser, e.g., `https://dnschecker.org/#A/aiidalab.contoso.com`.

After having verified that your deployment is reachable under the specified hostname, enable https by either performing a copier update
```
$ cd clouddrive/
$ copier update
```
and answering with yes to the prompt for enabling https, or by manually editing the `modules/aiidalab/values.yml` file and changing the following section:
```
proxy:
   ...
   https:
      enabled: True   # changed from False
```

Apply the change by running
```
$ terraform apply
```

### 9. Tear down deploymet

To tear down a deployment, simply go to the corresponding resource and run `terraform destroy`.
After that you can delete the GitHub OAuth app in case that you used it for authentication.

Note: The DNS zone entry will not be automatically deleted (see also section on *Known limitations*).

## Update deployments

In order to update an existing deployment to either change the configuration or adapt recent improvements to this template, make sure to track your deployments directory with git and commit all changes.

Then perform a [copier update](https://copier.readthedocs.io/en/stable/updating/) by switching into your deployments directory and running
```
$ copier update
```

The update process will walk you through the questionaire and potentially request all needed information.
Answers that were already provided in the previous deployment will be reused.
Please see the *Known limitations* section for limitations with respect to managing multiple deployements using this approach.

## DNS-zones

You do not need to create a DNS zone to deploy AiiDAlab however doing so will allow you to automatically configure the DNS entry for your deployment.

**IMPORTANT**: Manipulating DNS settings can be a very destructive action with the potential to disrupt all deployments routed on the associated domain.
Please make sure that you have the authority to manage DNS zones and/or ask your unit administrator whether a DNS zone has already been created.

To create a DNS zone, answer the prompt about whether to create a DNS zone with yes.
This will create a corresponding deployment directory of the form `contoso.com.` to your deployments directory (the trailing dot indicates the root zone and helps to distinguish between dns-zone deployment directories and other deployments).
To create the zone, simply switch into the directory and then initialize Terraform with `$ terraform init` followed by `$ terraform apply` to create the zone.

## Security considerations

The GitHub OAuth client credentials as well as the JupyterHub secret token are stored in plain text within the deployment directory and must for that reason not be pushed directly to public repositories.

## Known limitations

- A DNS entry configured automatically within a DNS zone is not automatically removed when the deployment is torn down. This is not necessarily an issue since the record is going to be updated when a deployment with the same hostname is re-created, however you might want to remove the entry manually after destroying a deployment to avoid confusion.
- Managing multiple deployments within the same deployments directory is in principal supported, however updating or migrating deployments can be difficult, because only the last set of answers are stored.


## LICENSE

Code within this repository is licensed under the [MIT license](license).
The documentation is licensed under the [CC-BY-4.0 license](license-docs) and was partially adapted from https://github.com/MicrosoftDocs/azure-dev-docs.
