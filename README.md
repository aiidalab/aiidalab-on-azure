# AiiDAlab on Azure

This repository contains instructions and template files to deploy an [AiiDAlab](https://www.aiidalab.net) JupyterHub instance on Azure using the [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/) and [Terraform](https://www.terraform.io/).

## Table of contents

* [Create an AiiDAlab deployment on Azure (with AKS)](#create-an-aiidalab-deployment-on-azure-with-aks)
   * [Learn the Terraform basics](#learn-the-terraform-basics)
   * [Configure your environment](#configure-your-environment)
   * [Configure Azure storage to store Terraform state](#configure-azure-storage-to-store-terraform-state)
   * [Create the AiiDAlab Terraform deployment directory](#create-the-AiiDAlab-terraform-deployment-directory)
   * [Use Terraform to create the deployment](#use-terraform-to-create-the-deployment)
   * [Access and maintain the deployment](#access-and-maintain-the-deployment)
   * [Configure your domain](#configure-your-domain)
   * [Enable https](#enable-https)
   * [Tear down deployment](#tear-down-deployment)
* [Update deployments](#update-deployments)
* [DNS-zones](#dns-zones)
* [User authentication](#user-authentication)
* [Security considerations](#security-considerations)
* [Monitoring resources](#monitoring-resources)
* [Known limitations](#known-limitations)
* [LICENSE](#LICENSE)

## Create an AiiDAlab deployment on Azure (with AKS)

_Documentation is partially adapted from [here](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#1-configure-your-environment)._

### 1. Learn the Terraform basics

If you are not familiar with the purpose and basic use of Terraform yet, we recommend that you read the [Terraform Introduction](https://www.terraform.io/intro) and the [Terraform Core Workflow](https://www.terraform.io/intro/core-workflow) before proceeding.

### 2. Configure your environment


- **Azure subscription**: If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.

  Required permissions: you will create a service principal that is `Contributor` rights on the subscription

- **Configure Terraform:** If you haven't already done so, configure Terraform using one of the following options:

    - [Configure Terraform in Azure Cloud Shell with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash)
    - [Configure Terraform in Azure Cloud Shell with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell)
    - [Configure Terraform in Windows with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash)
    - [Configure Terraform in Windows with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)

- **Azure service principal:** If you or your unit administrator has not yet created a service principal, follow the instructions [here](https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure#create-a-service-principal) and make note of the `appId`, `display_name`, `password`, and `tenant`.

  In order to get the object ID of your service principal `<display_name>`, run:
  ```
  $ az ad sp list --display-name <display_name> --output table
  DisplayName     Id                                    AppId                                 CreatedDateTime
  --------------  ------------------------------------  ------------------------------------  --------------------
  <display_name>  a1054340-4625-4826-a37a-257313cecc57  0dbd96ff-a1ef-4bef-aa47-92bb0dabb6cb  2022-06-23T12:14:09Z
  ```

  The value in the `Id` column is the `<service_principal_object_id>` that is needed in the step below.

  **Do not store the service principal credentials within your deployment repository in plain text.**
  We recommend to store them as environment variables in your deployment environment.
  For example, edit your `~/.bashrc` file and add the following lines:
  ```
  export TF_VAR_arm_client_id="<service_principal_appid>"
  export TF_VAR_arm_client_secret="<service_principal_password>"
  export TF_VAR_arm_client_object_id="<service_principal_object_id>"
  ```
  In this way they are automatically picked up by Terraform when needed and you do not have to manually provide them.

  To ensure the variables are available in the _current_ shell, source the `.bashrc` file by running `source ~/.bashrc`

- **SSH key pair**: Use the information in one of the following articles to create an SSH key pair:

    - [Portal](https://docs.microsoft.com/en-us/azure/virtual-machines/ssh-keys-portal#generate-new-keys)
    - [Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows#create-an-ssh-key-pair)
    - [Linux/MacOS](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#create-an-ssh-key-pair)

   The private and public key should be copied to the `~/.ssh` directory with the names `id_rsa` and `id_rsa.pub`, respectively.
   The private key will eventually provide ssh access to the cluster as the `ubuntu` user.

### 3. Configure Azure storage to store Terraform state

Your unit administrator may have already created an Azure storage account to store Terraform state for your unit, in which case please ask them to provide:

- The Azure storage account name.
- The resource group name of the storage account.
- The name of the container in the storage account to be used by terraform.

Otherwise, please follow the instructions [here](https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/terraform/create-k8s-cluster-with-tf-and-aks.md#2-configure-azure-storage-to-store-terraform-state) to create a storage account and a container to store Terraform state.

The information listed above will be needed later during the setup process.

### 4. Create the AiiDAlab Terraform deployment directory

1. Install **copier**

   We use [copier](https://copier.readthedocs.io/en/stable/) to create an instance from this template.
   If needed, install Python 3.7 or newer and Git 2.72 or newer into your deployment environment.
   Both Python and Git are already installed in the Azure Cloud Shell environment.

   Then install copier with
   ```
   $ pip install pipx && pipx install copier
   ```

2. Decide on a **hostname** for your deployment.

   _Note: If you do not intend to configure a domain name, simply pick a memorable name for this deployment and leave the field for `dns-zone` empty when creating the deployment directory below._

   This will be a domain where you can access your AiiDAlab deployment, e.g., `aiidalab.contoso.com`.
   You need to you have control over the DNS setting for the associated domain, in this case `contoso.com`.
   Please see the section on DNS-zones for automated DNS configuration.

3. _(optional)_ Create an **external application for authentication**

   _Note: For a testing deployment, you can use the default native authentication option. Unlike external authentication providers, such as Github, native authentication does not require a public domain name._

   By default, this template uses the native authenticator for user authentication, meaning that the JupyterHub itself will allow users to create an account and maintain the user database.
   Alternative authentication options are listed in the section on [user authentication](#user-authentication) - for example, GitHub authentication allows users to log in with their GitHub account, but requires the AiiDAlab to have a public domain name and to be registered as an OAuth application (see instructions).

4. Create the **deployment** directory

   We recommend to keep all Terraform resources created with this template in a dedicated and backed up location.
   For example, assuming that you are deploying from the Azure Cloud shell, you could store them directly in the `~/clouddrive` directory.

   Run the following command to create the Terraform deployment directory inside the `~/clouddrive` directory:
   ```
   $ copier gh:aiidalab/aiidalab-on-azure ~/clouddrive
   ```

   The deployment directory is automatically named by its associated hostname - for example, an AiiDAlab deployment at `aiidalab.contoso.com` would be stored in `~/clouddrive/aiidalab.contoso.com`.

   *Tip:* We recommend tracking the top-level directory with git to naturally track changes to all deployments.
   This will also allow you to update and migrate existing deployments (see section *Update deployments*).

### 5. Use Terraform to create the deployment

To create the deployment, switch into your _deployment directory_, e.g., `cd ~/clouddrive/aiidalab.contoso.com`, and run:
```
$ terraform init
```

After succesful initialization, run the following command to see the changes terraform would apply:
```
$ terraform plan
```

If the changes look correct, execute the following command to create all required resources for your deployment:
```
$ terraform apply
```
Make sure to _review_ the planned changes before applying them by confirming with `yes`.

Should the `apply` fail, refer to the [Teardown section](#tear-down-deployment) on how to reset your environment.

### 6. Access and maintain the deployment

In order to interact with the Kubernetes cluster, for example to check the status of individual nodes or pods, you need to configure `kubectl` to use the `kubeconfig` of the cluster:

1. Change into your deployment directory (e.g. `cd ~/clouddrive/aiidalab.contoso.com`).
2. Get/update the required credentials from Azure:
   ```
   $ az aks get-credentials --resource-group <resource_group_name> --name <cluster_name>
   ```
   Here `<resource_group_name>` is the name of the resource group that was provided in the `copier` setup (see Step 4.5).
   The `<cluster_name>` is the name of the cluster that was created, which is `k8s-cluster` by default.

3. Create a kubeconfig file with the following command:
   ```
   $ echo "$(terraform output --raw kube_config)" > ./kubeconfig
   ```
4. Set the `KUBECONFIG` environment variable to point to the kubeconfig file we just created:
   ```
   $ KUBECONFIG=./kubeconfig
   ```
5. Finally, check whether you can access the cluster. For example,listing the kubernetes services:
   ```
   $ kubectl get service
   NAME           TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
   hub            ClusterIP      10.0.81.241   <none>           8081/TCP       21h
   kubernetes     ClusterIP      10.0.0.1      <none>           443/TCP        21h
   proxy-api      ClusterIP      10.0.61.104   <none>           8001/TCP       21h
   proxy-public   LoadBalancer   10.0.233.95   20.200.300.400   80:30821/TCP   21h
   ```

   The AiiDAlab can be accessed using the public IP address of the `proxy-public` load balancer (`20.200.300.400` in the example above).

*Tip:* The deployment directory contains a script that performs steps 2 and 3 for you with `$ source setup-kubeconfig`.


### 7. Configure your domain

_Note: Skip this step if you are not using a domain name or if you are using [DNS-zones](#dns-zones)._
_In the first case, simply obtain the cluster address as described here and access it directly via http._

If you are using a domain (but not using DNS zones), you will have to set an A or C record with your registrar.

1. Note down the cluster's public IP address. You can query for it programmatically via:
   ```
   $ kubectl -n default get svc proxy-public -o jsonpath='{.status.loadBalancer.ingress[].ip}'
   ```
2. Go to your DNS registrar and add an A record or C record for your domain.

   Use an A record if the address is an actual IP address of the form 123.123.123.123 and a C record
   if the address is a domain name.

Depending on your registrar, it might take a few minutes to many hours for the DNS record to propagate.

### 8. Enable https

_Note: Skip this step if you are not using a domain or have otherwise no need for the use of https._
_Some authentication methods, such as GitHub authentication, require https._

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

### 9. Tear down deployment

To tear down a deployment, simply go to the corresponding resource and run `terraform destroy`.
After that you you may have to manually clean up external resources (such as a GitHub OAuth app) that were not created by Terraform.

If you recreate a deployment after a tear down, make sure to delete any old Terraform states that are stored in the container of the storage account.
This can be done through the Azure web interface.

Note: The DNS zone entry will not be automatically deleted (see also section on *Known limitations*).

## Update deployments

In order to update an existing deployment to either change the configuration or adapt recent improvements to this template, make sure to track your deployments directory with git and commit all changes.

Then perform a [copier update](https://copier.readthedocs.io/en/stable/updating/) by switching into your deployments directory and running
```
$ copier -a aiidalab.contoso.com/.copier-answers.yml update
```
replacing `aiidalab.contoso.com` with the hostname of the deployment that you want to update.

The update process will walk you through the questionaire and potentially request newly required information.
Answers that were already provided in the previous deployment will be reused.

## DNS-zones

You do not need to create a DNS zone to deploy AiiDAlab but doing so will allow you to automatically configure the DNS entry for your deployment.

**IMPORTANT**: Manipulating DNS settings can be a destructive action with the potential to disrupt all deployments routed on the associated domain.
Please make sure that you have the authority to manage DNS zones and/or ask your unit administrator whether a DNS zone has already been created.

To create a DNS zone, answer the prompt about whether to create a DNS zone with yes.
This will create a corresponding deployment directory of the form `contoso.com.` (the trailing dot indicates the root zone and helps to distinguish between dns-zone deployment directories and other deployments).
To create the zone, simply switch into the directory and then initialize Terraform with `$ terraform init` followed by `$ terraform apply` to create the zone.

## User authentication

JupyterHub on Kubernetes supports a variety of authentication methods, some of which are documented [here](https://zero-to-jupyterhub.readthedocs.io/en/stable/administrator/authentication.html).
Any of these authenticators can in principle be used, however the template currently supports the automated configuration of the following authenticators:
- [Native Authentication](https://native-authenticator.readthedocs.io/en/latest/)
- [GitHub Authentication](#github-authentication)
- [Azure AD Authentication](#azure-ad-single-sign-on-sso)
- [First-Use Authentication](https://github.com/jupyterhub/firstuseauthenticator)

The native authenticator is the default authenticator, it allows users to create their own user profile (which by default must be enabled by an admin user) and maintains its own user database.
For public tutorials and workshops, the GitHub authenticator is often a good choice.
The first-use authenticator allows any user to sign up with any password and is **not recommended** for public deployments.

### GitHub Authentication

In case you decide to use GitHub for authentication, please follow the [GitHub documentation](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) to create a GitHub OAuth app and select _GitHub Authenticator_ when asked about authentication methods when creating the deployment directory.

The app name is of your choice, e.g., `Contoso-AiiDAlab`.
The _Homepage URL_ should be the full URL to your deployment, e.g., `https://aiidalab.contoso.com`.
The _Authorization Callback URL_ for our example would then be `https://aiidalab.contoso.com/hub/oauth_callback`.

Provide the *Client ID* and *Client Secret*  when prompted in step 5 of [setting up the deployment directory](#4-create-the-aiidalab-terraform-deployment-directory).

_See the [zero-to-jupyterhub documentation](https://zero-to-jupyterhub.readthedocs.io/en/stable/administrator/authentication.html#github) for more information on how to configure authentication via GitHub._

### Azure AD Single-Sign-On (SSO)

_This part of the documentation was partially adapted from [here](https://learn.microsoft.com/en-us/azure/active-directory/develop/scenario-web-app-sign-user-app-registration?tabs=python#register-an-app-by-using-the-azure-portal)._

Follow these steps to register your deployment with your Azure Active Directory (AD) and thus enable users to access your deployment through Azure SSO.

1. Sign into the [Azure portal](https://portal.azure.com).
2. Search for and select *Active Directory*.
3. In the left navigation bar, select *App registrations* and then click on *New registration*.
4. Select an app name related to your deployment (it will be displayed to the user).
5. Select who should have access to the deployment via Azure SSO.
6. Configure the *Redirect URI* by selecting *web* and entering the Authorization Callback URL which would be of the form `https://aiidalab.contoso.com/hub/oauth_callback`.
7. In the app view, click on *Certificates & secrets* under *Manage*.
8. Create a new client secret by clicking on *New client secret* and give it a meaningful description (e.g. `JupyterHub`) and a reasonable expiration duration.
   Make sure to note down the newly obtained client secret *value*.

Provide the *Application (client) ID*, the *client secret value*, and the *Tenant ID* associated with the Azure AD when prompted in step 5 of [setting up the deployment directory](#4-create-the-aiidalab-terraform-deployment-directory).

_See the [zero-to-jupyterhub documentation](https://zero-to-jupyterhub.readthedocs.io/en/stable/administrator/authentication.html#azure-active-directory) for more information on how to configure authentication via Azure AD._

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
