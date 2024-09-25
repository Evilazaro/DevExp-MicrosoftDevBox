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

# Management Parameters constants
logAnalyticsWorkspaceName="eShopPetDevBoxLogAnalytics"

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

# Function to deploy Log Analytics Workspace
deployLogAnalytics() {
    local managementResourceGroupName="$1"
    local logAnalyticsWorkspaceName="$2"

    # Check if required parameters are provided
    if [[ -z "$managementResourceGroupName" || -z "$logAnalyticsWorkspaceName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: deployLogAnalytics <managementResourceGroupName> <logAnalyticsWorkspaceName>"
        return 1
    fi

    echo "Deploying Log Analytics Workspace to resource group: $managementResourceGroupName"

    # Execute the Azure deployment command
    az deployment group create \
        --name "MicrosoftDevBox-LogAnalytics-Deployment" \
        --resource-group "$managementResourceGroupName" \
        --template-file ./management/deploy.bicep \
        --parameters \
            logAnalyticsWorkspaceName="$logAnalyticsWorkspaceName" \
        --verbose

    # Check if the deployment was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to deploy Log Analytics Workspace."
        return 1
    fi

    echo "Log Analytics Workspace deployed successfully."
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
        --name "MicrosoftDevBox-Networ-kDeployment" \
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

    demoScript
}

# Function to deploy Dev Center resources
deployDevCenter() {
    local devCenterName="$1"
    local networkConnectionName="$2" 
    local identityName="$3" 
    local customRoleName="$4" 
    local computeGalleryName="$5"
    local networkResourceGroupName="$6"

    # Check if required parameters are provided
    if [[ -z "$devCenterName" || -z "$networkConnectionName" || -z "$identityName" || -z "$customRoleName" || -z "$computeGalleryName" || -z "$networkResourceGroupName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: deployDevCenter <devCenterName> <networkConnectionName> <identityName> <customRoleName> <computeGalleryName> <networkResourceGroupName>"
        return 1
    fi

    echo "Deploying Dev Center resources to resource group: $devBoxResourceGroupName"

    currentUser=$(az ad signed-in-user show --query id -o tsv)

    # Execute the Azure deployment command
    az deployment group create \
        --name "MicrosoftDevBox-DevCenter-Deployment" \
        --resource-group "$devBoxResourceGroupName" \
        --template-file ./devBox/deploy.bicep \
        --parameters \
            devCenterName="$devCenterName" \
            networkConnectionName="$networkConnectionName" \
            identityName="$identityName" \
            customRoleName="$customRoleName" \
            computeGalleryName="$computeGalleryName" \
            networkResourceGroupName="$networkResourceGroupName" \
            currentUser="$currentUser" 

    # Check if the deployment was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to deploy Dev Center resources."
        return 1
    fi

    echo "Dev Center resources deployed successfully."
}

buildImages()
{
    echo "Building the image..."
}


deploy(){
    
    clear
    
    azureLogin
    
    deployResourcesOrganization

    deployLogAnalytics \
        "$managementResourceGroupName" \
        "$logAnalyticsWorkspaceName"
    
    deployNetworkResources \
        "$networkResourceGroupName" \
        "$vnetName" \
        "$subNetName" \
        "$networkConnectionName"
    
    deployDevCenter "$devCenterName"  \
        "$networkConnectionName" \
        "$identityName" \
        "$customRoleName" \
        "$computeGalleryName" \
        "$networkResourceGroupName"
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