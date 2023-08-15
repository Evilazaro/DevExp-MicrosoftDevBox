#!/bin/bash

# This script is designed to delete specific resources from two Azure Resource Groups.

# Set the resource group names.
imageResourceGroup='Contoso-Base-Images-Engineers-rg'
microsoftDevBoxResourceGroupName="Contoso-AzureDevBox-rg"

# Display the start of the resource deletion process for clarity.
echo "-----------------------------------------"
echo "Starting Resource Deletion Process"
echo "-----------------------------------------"

# Delete the "Delete" resource from the imageResourceGroup.
echo "Deleting 'Delete' resource from '$imageResourceGroup'..."
az resource delete -n "Delete" -g $imageResourceGroup --resource-type "Microsoft.Resources/deployments"

# Delete the "Delete" resource from the microsoftDevBoxResourceGroupName.
echo "Deleting 'Delete' resource from '$microsoftDevBoxResourceGroupName'..."
az resource delete -n "Delete" -g $microsoftDevBoxResourceGroupName --resource-type "Microsoft.Resources/deployments"

# Display the completion of the resource deletion process.
echo "-----------------------------------------"
echo "Resource Deletion Process Completed"
echo "-----------------------------------------"
