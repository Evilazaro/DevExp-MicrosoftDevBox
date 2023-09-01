#!/bin/bash

# Exit the script if any command returns a non-zero status.
set -e

# Print every command being executed (for debugging purposes, optional)
# set -x

# Declare resource group names
devBoxResourceGroupName='Contoso-DevBox-rg'

# Retrieve the identity 
echo "Fetching the identity..."
identity=$(az identity list --query "[?name=='contosoIdentityIBuilderUserDevBox'].name" --output tsv)

# Get the subscription ID
echo "Retrieving the subscription ID..."
subscriptionID=$(az account show --query id --output tsv)

# Declare the image role definition name
imageRoleDef='Azure Image Builder Image Def'

# Retrieve the role ID
echo "Getting the role ID..."
roleId=$(az role definition list --name "$imageRoleDef" --query [].name --output tsv)

# Function to delete a resource group
delete_resource_group() {
    local resource_group_name="$1"

    output=$(az group exists --name "$resource_group_name")

    # Check if the resource group exists before trying to delete it
    if $output; then
        echo "Deleting resource group: $resource_group_name..."
        az group delete --name "$resource_group_name" --yes --no-wait
        echo "Resource group $resource_group_name deletion initiated."
    else
        echo "Resource group $resource_group_name does not exist. Skipping deletion."
    fi
}

# Function to assign a role to the identity for a specific subscription
remove_role_assignment() {
    local role=$1
    local subscription=$2

    echo "Checking the role assignments for the identity..."

    if [[ -z "$role" ]]; then
        echo "Role not defined. Skipping role assignment deletion."
        return  # Exit early if no role provided
    fi

    # Check if the role assignment exists
    output=$(az role assignment list --role "$role" --scope /subscriptions/"$subscription")
    if [[ -z "$output" || "$output" == "[]" ]]; then
        echo "'$role' role assignment does not exist. Skipping deletion."
    else
        echo "Removing '$role' role assignment from the identity..."   
        az role assignment delete --role "$role" --scope /subscriptions/"$subscription"
        echo "'$role' role assignment successfully removed."
    fi

    # Check if the role definition exists
    output=$(az role definition list --name "$role")
    if [[ -z "$output" || "$output" == "[]" ]]; then
        echo "'$role' role does not exist. Skipping deletion."
    else   
        echo "Deleting the '$role' role..."
        az role definition delete --name "$role"
        echo "'$role' role successfully deleted." 
    fi
}

# Delete the role assignment
remove_role_assignment "$roleId" "$subscriptionID"

# Delete the devBox resource group
delete_resource_group "$devBoxResourceGroupName"

echo "Script execution completed."
