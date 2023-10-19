#!/bin/bash

clear

# Declaring Variables

# Resources Organization
subscriptionId=$(az account show --query id --output tsv)
devBoxResourceGroupName='ContosoFabric-DevBox-RG'
imageGalleryResourceGroupName='ContosoFabric-ImageGallery-RG'
identityResourceGroupName='ContosoFabric-Identity-DevBox-RG'
networkResourceGroupName='ContosoFabric-Network-Connectivity-RG'
managementResourceGroupName='ContosoFabric-DevBox-Management-RG'
networkWatcherResourceGroupName='NetworkWatcherRG'
location='WestUS3'

# Identity
identityName='ContosoFabricDevBoxImgBldId'
customRoleName='ContosoFabricBuilderRole'

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

# Remove Role
removeRole() {
    local roleName="$1"
    local roleDefinition=$(az role definition list --name "$roleName")

    if [[ -z "$roleDefinition" || "$roleDefinition" == "[]" ]]; then
        echo "'$roleName' role does not exist. Skipping deletion."
    else   
        echo "Deleting the '$roleName' role..."
        az role definition delete --name "$roleName"
        echo "'$roleName' role successfully deleted." 
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

# Main Execution

# Deleting role assignments and role definitions
for roleName in 'Owner' 'Managed Identity Operator' 'Reader' 'DevCenter Dev Box User' "$customRoleName"; do
    echo "Getting the role ID for '$roleName'..."
    roleId=$(az role definition list --name "$roleName" --query [].name --output tsv)
    removeRoleAssignment "$roleId" "$subscriptionId"
done

removeRole "$customRoleName"

# Deleting resource groups
deleteResourceGroup "$devBoxResourceGroupName"
deleteResourceGroup "$imageGalleryResourceGroupName"
deleteResourceGroup "$identityResourceGroupName"
deleteResourceGroup "$networkResourceGroupName"
deleteResourceGroup "$managementResourceGroupName"
deleteResourceGroup "$networkWatcherResourceGroupName"
deleteResourceGroup "Default-ActivityLogAlerts"
deleteResourceGroup "DefaultResourceGroup-WUS2"
