#!/bin/bash

# Declaring Variables

# Resources Organization
subscriptionId=$(az account show --query id --output tsv)
devBoxResourceGroupName='eShop-DevBox-rg'
imageGalleryResourceGroupName='eShop-DevBox-ImgGallery-rg'
identityResourceGroupName='eShop-DevBox-Identity-rg'
networkResourceGroupName='eShop-DevBox-network-rg'
managementResourceGroupName='eShop-DevBox-Management-rg'
networkWatcherResourceGroupName='NetworkWatcherRG'
location='WestUS3'

# Identity
identityName='eShopDevBoxImgBldId'
customRoleName='eShopImgBuilderRole'

# Function to delete a resource group
function deleteResourceGroup() {
    local resourceGroupName="$1"

    output=$(az group exists --name "$resourceGroupName")

    if $output; then
        echo "Deleting resource group: $resourceGroupName..."
        az group delete --name "$resourceGroupName" --yes --no-wait
        echo "Resource group $resourceGroupName deletion initiated."
    else
        echo "Resource group $resourceGroupName does not exist. Skipping deletion."
    fi
}

# Function to remove a role
function removeRole() {
    local customRoleName=$1

    output=$(az role definition list --name "$customRoleName")

    if [[ -z "$output" || "$output" == "[]" ]]; then
        echo "'$customRoleName' role does not exist. Skipping deletion."
    else   
        echo "Deleting the '$customRoleName' role..."
        az role definition delete --name "$customRoleName"
        echo "'$customRoleName' role successfully deleted." 
    fi
}

# Function to remove a role assignment
function removeRoleAssignment() {
    local roleId=$1
    local subscriptionId=$2

    echo "Checking the role assignments for the identity..."

    if [[ -z "$roleId" ]]; then
        echo "Role not defined. Skipping role assignment deletion."
        return
    fi

    output=$(az role assignment list --role "$roleId" --scope /subscriptions/"$subscriptionId")

    if [[ -z "$output" || "$output" == "[]" ]]; then
        echo "'$roleId' role assignment does not exist. Skipping deletion."
    else
        echo "Removing '$roleId' role assignment from the identity..."   
        az role assignment delete --role "$roleId" --scope /subscriptions/"$subscriptionId"
        echo "'$roleId' role assignment successfully removed."
    fi
}

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