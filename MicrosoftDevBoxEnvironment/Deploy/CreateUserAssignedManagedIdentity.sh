#!/bin/bash

# This script creates a user-assigned managed identity and grants the "Owner" role to it at the subscription scope.

# Echoing a header for better visibility.
echo "-------------------------------------------------------------"
echo "Creating a User-Assigned Managed Identity & Granting Permissions"
echo "-------------------------------------------------------------"

# Extracting the Azure resource group name from the first argument and displaying it.
imageResourceGroup=$1
echo "Resource Group: $imageResourceGroup"

# Extracting the Azure subscription ID from the second argument and displaying it.
subscriptionID=$2
echo "Subscription ID: $subscriptionID"

# Extracting the identity ID from the third argument and displaying it.
identityId=$3
echo "Identity ID: $identityId"
echo "-------------------------------------------------------------"

# Using the Azure CLI to assign the "Owner" role to the specified identity ID.
# This gives the identity full access to all resources within the provided subscription.
echo "Assigning 'Owner' role to the identity..."
az role assignment create \
    --assignee $identityId \
    --role "Owner" \
    --scope /subscriptions/$subscriptionID

# Confirming role assignment.
echo "'Owner' role successfully assigned to the identity in the subscription."
