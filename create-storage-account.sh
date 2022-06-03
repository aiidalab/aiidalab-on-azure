#!/bin/bash
set -e
set -u

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate


# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME


cat <<EOF

IMPORTANT: Add the following line inside of an .env.sh file within this directory:

export ARM_STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME}"
EOF