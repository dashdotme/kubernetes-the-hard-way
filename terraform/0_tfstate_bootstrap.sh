#!/usr/bin/env bash

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Bootstrapping remote backend${NC}"

SUBSCRIPTION_ID="cfab30b4-6a5f-407d-9346-a633a3620ba5"
RESOURCE_GROUP_NAME="k8s-the-hard-way"
STORAGE_ACCOUNT_NAME="dashdotmek8s"
CONTAINER_NAME="tfstate"
LOCATION="Australia East"

az account set --subscription "$SUBSCRIPTION_ID"

az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" || true

az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS || true

az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --auth-mode login || true

echo -e "${GREEN}Provisioning succeeded${NC}"
