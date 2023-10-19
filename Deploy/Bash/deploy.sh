#!/bin/bash

# Variables
branch="main"
location="WestUS3"

# Azure Resource Group Names
devBoxResourceGroupName="contosoFabricDevBoxRG"
imageGalleryResourceGroupName="contosoFabricImageGalleryRG"
identityResourceGroupName="contosoFabricIdentityDevBoxRG"
networkResourceGroupName="contosoFabricNetworkConnectivityRG"
managementResourceGroupName="contosoFabricDevBoxManagementRG"

# Identity Variables
identityName="contosoFabricDevBoxImgBldId"
customRoleName="contosoFabricBuilderRole"

# Image and DevCenter Names
imageGalleryName="contosoFabricImageGallery"
frontEndImageName="frontEndVm"
backEndImageName="backEndVm"
devCenterName="devBoxDevCenter"

# Network Variables
vnetName="contosoFabricVnet"
subNetName="contosoFabricSubNet"
networkConnectionName="devBoxNetworkConnection"

# Functions
azureLogin() {
    local subscriptionName="$1"

    # Check if the subscriptionName is empty
    if [[ -z "$subscriptionName" ]]; then
        echo "Error: Subscription name is missing!"
        echo "Usage: azureLogin <subscriptionName>"
        return 1
    fi
    
    echo "Attempting to login to Azure subscription: $subscriptionName"

    local scriptPath="./identity/login.sh"
    
    if [[ ! -x "$scriptPath" ]]; then
        echo "Error: The login script $scriptPath does not exist or is not executable."
        return 1
    fi
    
    "$scriptPath" "$subscriptionName"
    
    if [[ $? -eq 0 ]]; then
        echo "Successfully logged in to $subscriptionName."
    else
        echo "Failed to log in to $subscriptionName."
        return 1
    fi
}

createResourceGroup() {
    local resourceGroupName="$1"
    local location="$2"

    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        exit 1
    fi

    echo "Creating Azure Resource Group..."
    echo "Resource Group Name: $resourceGroupName"
    echo "Location: $location"

    az group create --name "$resourceGroupName" --location "$location" --tags "division=Contoso-Platform" "Environment=Prod" "offer=Contoso-DevWorkstation-Service" "Team=Engineering" "division=Contoso-Platform" "solution=ContosoFabricDevWorkstation"
    echo "Resource group '$resourceGroupName' created successfully."
}

# ... Other functions remain mostly the same ...

main() {
    clear
    set -e

    if [[ -z "$1" ]]; then
        echo "Usage: $0 <subscriptionName>"
        exit 1
    fi

    local subscriptionName="$1"
    local subscriptionId
    subscriptionId=$(az account show --query id --output tsv)

    echo "Starting Deployment..."

    azureLogin "$subscriptionName"
    createResourceGroup "$devBoxResourceGroupName" "$location"
    createResourceGroup "$imageGalleryResourceGroupName" "$location"
    createResourceGroup "$identityResourceGroupName" "$location"
    createResourceGroup "$networkResourceGroupName" "$location"
    createResourceGroup "$managementResourceGroupName" "$location"

    # ... Other function calls ...

    echo "Deployment Completed Successfully!"
}

main "$@"
