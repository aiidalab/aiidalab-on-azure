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

   _Note: In case that you do not intend to configure a domain name, e.g., for testing purposes, simply pick a memorable name for this deployment and leave the field for `dns-zone` empty when you are creating the deployments directory._

3. _(optional)_ Create an **external application for authentication**

   By default, this template uses the native authenticator for user authentication, meaning that the JupyterHub itself will allow users to create an account and maintain the user database.
   However, there are other options, please see our section on [user authentication](#user-authentication) for an overview of alternative methods.
   We generally recommend to use GitHub authentication for publicly accessible production deployments in which case users must have or create a GitHub account to log in.

   Please follow the detailed instructions for setting up an application with either [GitHub](#github-authentication) or [Azure AD](#azure-ad-single-sign-on-sso) if you decide to use any of these two methods.

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

_Important: Step 7 can be skipped if you are either using [DNS-zones](#dns-zones) (recommended) or if you only want to test your deployment without a dedicated domain._
_In the latter case, simply obtain the cluster address as described here and access it directly via http._

If you are not using DNS zones, you will have to set an A or C record for your domain as described here.

1. Obtain the cluster address for your deployment:
   ```
   $ kubectl -n default get svc proxy-public -o jsonpath='{.status.loadBalancer.ingress[].ip}'
   ```
2. Go to your DNS registrar and add an A record or C record for your domain.

   Use an A record if the address is an actual IP address of the form 123.123.123.123 and a C record
   if the address is a domain name.

Depending on your registrar, it might take a few minutes to many hours for the DNS record to propagate.
### 8. Enable https

_Important: Step 8 must be skipped if you only want to test your deployment without a dedicated domain or have otherwise no need for the use of https._
_Authentication methods that require https, such as GitHub authentication will not work in this way._

After the deployment is created, verify that you can reach it under the specified hostname, (e.g. `aiidalab.contoso.com`) for example on the command line with
```
$ curl -kL http://aiidalab.contoso.com
```
or by checking the DNS propagation explicitly with an online tool in your browser, e.g., `https://dnschecker.org/#A/aiidalab.contoso.com`.

After having verified that your deployment is reachable under the specified hostname, enable https by either performing a copier update (The deployments directory (e.g. `~/clouddrive`) should be git-tracked.)
```
$ cd clouddrive/
$ copier update
```
and answering with yes to the prompt for enabling https, or if `~/clouddrive` not git-tracked, manually editing the `modules/aiidalab/values.yml` file and changing the following section:
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
After that you you may have to manually clean up external resources (such as a GitHub OAuth app) that were not created by Terraform.

Note: The DNS zone entry will not be automatically deleted (see also section on *Known limitations*).

## Update deployments

In order to update an existing deployment to either change the configuration or adapt recent improvements to this template, make sure to track your deployments directory with git and commit all changes.

Then perform a [copier update](https://copier.readthedocs.io/en/stable/updating/) by switching into your deployments directory and running
```
$ copier -a aiidalab.contoso.com/.copier-answers.yml update
```
where you should replace `aiidalab.contoso.com` with the hostname of the deployment that you want to update.

The update process will walk you through the questionaire and potentially request newly required information.
Answers that were already provided in the previous deployment will be reused.

## DNS-zones

You do not need to create a DNS zone to deploy AiiDAlab however doing so will allow you to automatically configure the DNS entry for your deployment.

**IMPORTANT**: Manipulating DNS settings can be a very destructive action with the potential to disrupt all deployments routed on the associated domain.
Please make sure that you have the authority to manage DNS zones and/or ask your unit administrator whether a DNS zone has already been created.

To create a DNS zone, answer the prompt about whether to create a DNS zone with yes.
This will create a corresponding deployment directory of the form `contoso.com.` to your deployments directory (the trailing dot indicates the root zone and helps to distinguish between dns-zone deployment directories and other deployments).
To create the zone, simply switch into the directory and then initialize Terraform with `$ terraform init` followed by `$ terraform apply` to create the zone.

## User authentication

JupyterHub on Kubernetes supports a variety of authentication methods, some of which are documented [here](https://zero-to-jupyterhub.readthedocs.io/en/stable/administrator/authentication.html).
Any of these authenticators can in principle be used, however the template currently supports the automated configuration of the following authenticators:
- [Native Authenticator](https://native-authenticator.readthedocs.io/en/latest/)
- [GitHub Authenticator](https://zero-to-jupyterhub.readthedocs.io/en/stable/administrator/authentication.html#github)
- [First-Use Authenticator](https://github.com/jupyterhub/firstuseauthenticator)

The native authenticator is the default authenticator, it allows users to create their own user profile (which by default must be enabled by an admin user) and maintains its own user database.
In general, we recommend to use the GitHub authenticator for public tutorials or workshops.
The first-use authenticator allows any user to sign up with any password and is **not recommended** for public deployments.

### GitHub Authentication

In case you decide to use GitHub for authentication, please follow the [GitHub documentation](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) to create a GitHub OAuth app and make sure to select _GitHub Authenticator_ when asked about authentication methods when creating the deployment directory.

The app name is of your choice, e.g., `Contoso-AiiDAlab`.
The _Homepage URL_ should be the full URL to your deployment, e.g., `https://aiidalab.contoso.com`.
The _Authorization Callback URL_ for our example would then be `https://aiidalab.contoso.com/hub/oauth_callback`.

Provide the *Client ID* and *Client Secret*  when prompted while setting up the deployment directory.

### Azure AD Single-Sign-On (SSO)

Follow these steps to register your deployment with your Azure Active Directory and thus enable users to access your deployment via Azure SSO.

1. Sign into the [Azure portal](https://portal.azure.com).
2. Search for and select *Active Directory*.
3. In the left navigation bar, select *App registrations* and then click on *New registration*.
4. Select an app name related to your deployment (it will be displayed to the user).
5. Select who should have access to the deployment via Azure SSO.
6. Configure the *Redirect URI* by selecting *web* and entering the Authorization Callback URL which would be of the form `https://aiidalab.contoso.com/hub/oauth_callback`.
7. In the app view, click on *Certificates & secrets* under *Manage*.
8. Create a new client secret by clicking on *New client secret* and give it a meaningful description (e.g. JupyterHub) and a reasonable expiration duration.
   Make sure to note down the newly obtained client secret *value*.

Provide the *Application (client) ID*, the *client secret value*, and the *Tenant ID* associated with the Azure AD when prompted while setting up the deployment directory.

_This part of the documentation was adapted from [here](https://learn.microsoft.com/en-us/azure/active-directory/develop/scenario-web-app-sign-user-app-registration?tabs=python#register-an-app-by-using-the-azure-portal)._

## Security considerations

Some secrets, such as the GitHub or Azure AD client credentials as well as the JupyterHub secret token are stored in plain text within the deployment directory and must for that reason not be pushed directly to public repositories.

## Monitoring resources

The Azure AKS cluster that is created by default is configured to also create monitoring resources to provide insights into the cluster health and usage.
These resources are created within the same resource group and can be accessed directly within the Azure portal by navigating to the Kubernetes service resource itself and then selecting "Monitoring" and then "Insights" in the left navigation bar.

Please see [here](https://learn.microsoft.com/en-us/azure/aks/monitor-aks) for information.

## Known limitations

- A DNS entry configured automatically within a DNS zone is not automatically removed when the deployment is torn down. This is not necessarily an issue since the record is going to be updated when a deployment with the same hostname is re-created, however you might want to remove the entry manually after destroying a deployment to avoid confusion.
- The questionaire allows for certains answers to be "empty" although a value is required. This appears to be a [bug in copier](https://github.com/copier-org/copier/issues/355).

## LICENSE

Code within this repository is licensed under the [MIT license](license).
The documentation is licensed under the [CC-BY-4.0 license](license-docs) and was partially adapted from https://github.com/MicrosoftDocs/azure-dev-docs.
