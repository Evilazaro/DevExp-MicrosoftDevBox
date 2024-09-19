#!/bin/bash

clear

echo "Cleaning up the deployment environment..."

# Declaring Variables

# Resources Organization
subscriptionId=$(az account show --query id --output tsv)
# Azure Resource Group Names
devBoxResourceGroupName="petv2DevBox-rg"
imageGalleryResourceGroupName="petv2ImageGallery-rg"
identityResourceGroupName="petv2IdentityDevBox-rg"
networkResourceGroupName="petv2NetworkConnectivity-rg"
managementResourceGroupName="petv2DevBoxManagement-rg"
location='WestUS3'

# Identity Variables
identityName="petv2DevBoxImgBldId"
customRoleName="petv2BuilderRole"

# Delete Resource Group
deleteResourceGroup() {
    local resourceGroupName="$1"
    local groupExists=$(az group exists --name "$resourceGroupName")

    if $groupExists; then
        echo "Deleting resource group: $resourceGroupName..."
        az group delete --name "$resourceGroupName" --yes --no-wait
        echo "Resource group $resourceGroupName deletion initiated."
    else
        echo "Resource group $resourceGroupName does not exist. Skipping deletion."
    fi
}
# Remove Role Assignment
removeRoleAssignment() {
    local roleId="$1"
    local subscription="$2"

    echo "Checking the role assignments for the identity..."

    if [[ -z "$roleId" ]]; then
        echo "Role not defined. Skipping role assignment deletion."
        return
    fi

    local assignmentExists=$(az role assignment list --role "$roleId" --scope /subscriptions/"$subscription")

    if [[ -z "$assignmentExists" || "$assignmentExists" == "[]" ]]; then
        echo "'$roleId' role assignment does not exist. Skipping deletion."
    else
        echo "Removing '$roleId' role assignment from the identity..."   
        az role assignment delete --role "$roleId" --scope /subscriptions/"$subscription"
        echo "'$roleId' role assignment successfully removed."
    fi
}

deleteCustomRole() {
    local roleName="$1"
    echo "Deleting the '$roleName' role..."
    roleExists=$(az role definition list --name "$roleName")

    if [[ -z "$roleExists" || "$roleExists" == "[]" ]]; then
        echo "'$roleName' role does not exist. Skipping deletion."
        return
    fi
    
    az role definition delete --name "$roleName"

    while [ "$(az role definition list --name "$roleName" --query [].roleName -o tsv)" == "$roleName" ]; do
        echo "Waiting for the role to be deleted..."
        sleep 10
    done	
    echo "'$roleName' role successfully deleted."
}

# Main Execution

# Deleting role assignments and role definitions
for roleName in 'Owner' 'Managed Identity Operator' 'DevCenter Dev Box User' "$customRoleName"; do
    echo "Getting the role ID for '$customRoleName'..."
    roleId=$(az role definition list --name "$customRoleName" --query [].name --output tsv)
    removeRoleAssignment "$roleId" "$subscriptionId"
done

deleteCustomRole "$customRoleName" 

# Deleting resource groups
deleteResourceGroup "$devBoxResourceGroupName"
deleteResourceGroup "$imageGalleryResourceGroupName"
deleteResourceGroup "$identityResourceGroupName"
deleteResourceGroup "$networkResourceGroupName"
deleteResourceGroup "$managementResourceGroupName"
deleteResourceGroup "NetworkWatcherRG"
deleteResourceGroup "Default-ActivityLogAlerts"
deleteResourceGroup "DefaultResourceGroup-WUS2"