#!/bin/bash
# This script performs several operations on Azure resources including:
# - Deleting specific role assignments
# - Deleting specific role definitions
# - Deleting specific resource groups

set -e

# Declare constants
DEVBOX_RESOURCE_GROUP_NAME='Contoso-DevBox-rg'
NETWORK_WATCHER_RESOURCE_GROUP_NAME='NetworkWatcherRG'
IMAGE_ROLE_DEF='Azure Image Builder Image Def'

# Function to retrieve identity and subscription ID
setup_environment() {
    echo "Setting up environment..."

    echo "Fetching the identity..."
    IDENTITY=$(az identity list --query "[?name=='contosoIdentityIBuilderUserDevBox'].name" --output tsv)

    echo "Retrieving the subscription ID..."
    SUBSCRIPTION_ID=$(az account show --query id --output tsv)
}

# Function to delete a resource group
delete_resource_group() {
    local resource_group_name="$1"

    output=$(az group exists --name "$resource_group_name")

    if $output; then
        echo "Deleting resource group: $resource_group_name..."
        az group delete --name "$resource_group_name" --yes --no-wait
        echo "Resource group $resource_group_name deletion initiated."
    else
        echo "Resource group $resource_group_name does not exist. Skipping deletion."
    fi
}

# Function to remove a role
remove_role() {
    local role=$1

    output=$(az role definition list --name "$role")

    if [[ -z "$output" || "$output" == "[]" ]]; then
        echo "'$role' role does not exist. Skipping deletion."
    else   
        echo "Deleting the '$role' role..."
        az role definition delete --name "$role"
        echo "'$role' role successfully deleted." 
    fi
}

# Function to remove a role assignment
remove_role_assignment() {
    local role_id=$1

    echo "Checking the role assignments for the identity..."

    if [[ -z "$role_id" ]]; then
        echo "Role not defined. Skipping role assignment deletion."
        return
    fi

    output=$(az role assignment list --role "$role_id" --scope /subscriptions/"$SUBSCRIPTION_ID")

    if [[ -z "$output" || "$output" == "[]" ]]; then
        echo "'$role_id' role assignment does not exist. Skipping deletion."
    else
        echo "Removing '$role_id' role assignment from the identity..."   
        az role assignment delete --role "$role_id" --scope /subscriptions/"$SUBSCRIPTION_ID"
        echo "'$role_id' role assignment successfully removed."
    fi
}

# Main function to orchestrate the script execution
main() {
    setup_environment

    # Deleting role assignments and role definitions
    for role_name in 'Owner' 'Managed Identity Operator' "$IMAGE_ROLE_DEF"; do
        echo "Getting the role ID for '$role_name'..."
        ROLE_ID=$(az role definition list --name "$role_name" --query [].name --output tsv)

        remove_role_assignment "$ROLE_ID"
        remove_role "$role_name"
    done

    # Deleting resource groups
    delete_resource_group "$DEVBOX_RESOURCE_GROUP_NAME"
    delete_resource_group "$NETWORK_WATCHER_RESOURCE_GROUP_NAME"

    echo "Script execution completed."
}

# Execute the script
main
