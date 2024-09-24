#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail


location="WestUS3"

# Azure Resource Group Names Constants
devBoxResourceGroupName="eShopPetDevBox-rg"
networkResourceGroupName="eShopPetNetworkConnectivity-rg"
managementResourceGroupName="eShopPetDevBoxManagement-rg"

# Identity Parameters Constants
identityName="eShopPetDevBoxImgBldId"
customRoleName="eShopPetBuilderRole"

# Image and DevCenter Parameters Constants
computeGalleryName="eShopPetImageGallery"
devCenterName="eShopPetDevCenter"

# Network Parameters Constants
vnetName="eShopPetVnet"
subNetName="eShopPetSubNet"
networkConnectionName="eShopPetNetworkConnection"

# Build Image local to inform if the image should be built
buildImage=${1:-false}
scriptDemo=${2:-false}

# Function to log in to Azure
azureLogin() {
    echo "Logging in to Azure using device code..."

    # Attempt to log in to Azure
    az login --use-device-code
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to log in to Azure."
        return 1
    fi

    echo "Successfully logged in to Azure."
}

# Function to create an Azure resource group
createResourceGroup() {
    local resourceGroupName="$1"

    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        return 1
    fi

    echo "Creating Azure Resource Group: $resourceGroupName in $location"

    if az group create --name "$resourceGroupName" --location "$location" --tags "division=eShopPet-Platform" "Environment=Prod" "offer=eShopPet-DevWorkstation-Service" "Team=Engineering" "solution=ContosoFabricDevWorkstation"; then
        echo "Resource group '$resourceGroupName' created successfully."
    else
        echo "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    fi
}

# Function to deploy resources for the organization
deployResourcesOrganization() {

    createResourceGroup "$devBoxResourceGroupName"
    createResourceGroup "$networkResourceGroupName"
    createResourceGroup "$managementResourceGroupName"

    demoScript
}

# Function to deploy network resources
deployNetworkResources() {
    local networkResourceGroupName="$1"
    local vnetName="$2"
    local subNetName="$3"
    local networkConnectionName="$4"

    # Check if required parameters are provided
    if [[ -z "$networkResourceGroupName" || -z "$vnetName" || -z "$subNetName" || -z "$networkConnectionName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: deployNetworkResources <networkResourceGroupName> <vnetName> <subNetName> <networkConnectionName>"
        return 1
    fi

    echo "Deploying network resources to resource group: $networkResourceGroupName"

    # Execute the Azure deployment command
    az deployment group create \
        --name "MicrosoftDevBox-NetworkDeployment" \
        --resource-group "$networkResourceGroupName" \
        --template-file ./network/deploy.bicep \
        --parameters \
            vnetName="$vnetName" \
            subnetName="$subNetName" \
            networkConnectionName="$networkConnectionName" \
        --verbose

    # Check if the deployment was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to deploy network resources."
        return 1
    fi

    echo "Network resources deployed successfully."
}

# Function to deploy Dev Center resources
deployDevCenter() {
    local devCenterName="$1"
    local devboxDefinitionName="$2"
    local networkConnectionName="$3" 
    local identityName="$4" 
    local customRoleName="$5" 
    local computeGalleryName="$6"
    local computeGalleryImageName="$7"

    # Check if required parameters are provided
    if [[ -z "$devCenterName" || -z "$devboxDefinitionName" || -z "$networkConnectionName" || -z "$identityName" || -z "$customRoleName" || -z "$computeGalleryName" || -z "$computeGalleryImageName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: deployDevCenter <devCenterName> <devboxDefinitionName> <networkConnectionName> <identityName> <customRoleName> <computeGalleryName> <computeGalleryImageName>"
        return 1
    fi

    echo "Deploying Dev Center resources to resource group: $devBoxResourceGroupName"

    # Execute the Azure deployment command
    az deployment group create \
        --name "MicrosoftDevBox-DevCenterDeployment" \
        --resource-group "$devBoxResourceGroupName" \
        --template-file ./devBox/deploy.bicep \
        --parameters \
            devCenterName="$devCenterName" \
            devboxDefinitionName="$devboxDefinitionName" \
            networkConnectionName="$networkConnectionName" \
            identityName="$identityName" \
            customRoleName="$customRoleName" \
            computeGalleryName="$computeGalleryName" \
            computeGalleryImageName="$computeGalleryImageName" \

    # Check if the deployment was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to deploy Dev Center resources."
        return 1
    fi

    echo "Dev Center resources deployed successfully."
}


deploy(){
    
    clear
    
    azureLogin
    
    deployResourcesOrganization
    
    deployNetworkResources \
        "$networkResourceGroupName" \
        "$vnetName" \
        "$subNetName" \
        "$networkConnectionName"
    
    deployDevCenter "$devCenterName" \
        "eShopPetDevBox" \
        "$networkConnectionName" \
        "$identityName" \
        "$customRoleName" \
        "$computeGalleryName" \
        "eShopPetDevBoxImage"
}

demoScript() {
    if [[ "$scriptDemo" == "true" ]]; then
        read -p "Do you want to continue? (y/n) " answer
        if [[ "$answer" == "y" ]]; then
            clear
            echo "Continuing..."            
        else
            echo "Stopping the script."
            exit 1
        fi
    fi
}

deploy