#!/bin/bash
# Best practice: Using `set -e` to exit the script if any command returns a non-zero status.
set -e

# Declare resource group names
galleryResourceGroup='Contoso-Base-Images-Engineers-rg'
devBoxResourceGroupName='Contoso-DevBox-rg'

# Function to delete a resource group
delete_resource_group() {
    local resource_group_name="$1"

    # Check if the resource group exists before trying to delete it
    if az group exists --name "$resource_group_name"; then
        echo "Deleting resource group: $resource_group_name..."
        
        # Using `az group delete` to delete the specified resource group
        az group delete --name "$resource_group_name" --yes --no-wait
        echo "Resource group $resource_group_name deletion initiated."
    else
        echo "Resource group $resource_group_name does not exist. Skipping deletion."
    fi
}

# Delete the gallery resource group
delete_resource_group "$galleryResourceGroup"

# Delete the devBox resource group
delete_resource_group "$devBoxResourceGroupName"

echo "Script execution completed."
