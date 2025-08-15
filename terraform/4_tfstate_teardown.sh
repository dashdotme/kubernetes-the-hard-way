#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
NC='\033[0m'

SUBSCRIPTION_ID="cfab30b4-6a5f-407d-9346-a633a3620ba5"
RESOURCE_GROUP_NAME="k8s-the-hard-way"

echo -e "${RED}Deleting resource group: $RESOURCE_GROUP_NAME${NC}"
echo "This will delete the storage account and containers nested inside."

az account set --subscription "$SUBSCRIPTION_ID"

az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait || true

echo -e "${RED}Teardown completed${NC}"
