#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

echo "Deploying to Azure"

# Constants Parameters
branch="main"
location="WestUS3"

# Azure Resource Group Names Constants
subscriptionName="$1"
devBoxResourceGroupName="petv2DevBox-rg"
imageGalleryResourceGroupName="petv2ImageGallery-rg"
identityResourceGroupName="petv2IdentityDevBox-rg"
networkResourceGroupName="petv2NetworkConnectivity-rg"
managementResourceGroupName="petv2DevBoxManagement-rg"

# Identity Parameters Constants
identityName="petv2DevBoxImgBldId"
customRoleName="petv2BuilderRole"

# Image and DevCenter Parameters Constants
imageGalleryName="petv2ImageGallery"
devCenterName="petv2DevCenter"

# Network Parameters Constants
vnetName="petv2Vnet"
subNetName="petv2SubNet"
networkConnectionName="devBoxNetworkConnection"

# Build Image local to inform if the image should be built
buildImage=${2:-false}
scriptDemo=${3:-false}

# Function to log in to Azure
azureLogin() {


    az login --use-device-code
    
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

    if az group create --name "$resourceGroupName" --location "$location" --tags "division=petv2-Platform" "Environment=Prod" "offer=petv2-DevWorkstation-Service" "Team=Engineering" "solution=ContosoFabricDevWorkstation"; then
        echo "Resource group '$resourceGroupName' created successfully."
    else
        echo "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    fi
}

# Function to deploy resources for the organization
deployResourcesOrganization() {

    createResourceGroup "$devBoxResourceGroupName"
    createResourceGroup "$imageGalleryResourceGroupName"
    createResourceGroup "$identityResourceGroupName"
    createResourceGroup "$networkResourceGroupName"
    createResourceGroup "$managementResourceGroupName"

    demoScript
}

#!/bin/bash

# Function to deploy identity resources
deployIdentity() {
    local identityResourceGroupName="$1"
    local identityName="$2"
    local customRoleName="$3"

    if [[ -z "$identityResourceGroupName" || -z "$identityName" || -z "$customRoleName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: deployIdentity <identityResourceGroupName> <identityName> <customRoleName>"
        return 1
    fi

    echo "Deploying identity resources to resource group: $identityResourceGroupName"

    az deployment group create \
        --name "DeployDevBox-Identity" \
        --resource-group "$identityResourceGroupName" \
        --template-file ./identity/deploy.bicep \
        --parameters \
            identityName="$identityName" \
            customRoleName="$customRoleName"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to deploy identity resources."
        return 1
    fi

    echo "Identity resources deployed successfully."
}

#!/bin/bash

# Function to deploy network resources
deployNetwork() {
    local identityResourceGroupName="$1"
    local vnetName="$2"
    local subNetName="$3"
    local networkConnectionName="$4"

    if [[ -z "$identityResourceGroupName" || -z "$vnetName" || -z "$subNetName" || -z "$networkConnectionName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: deployNetwork <identityResourceGroupName> <vnetName> <subNetName> <networkConnectionName>"
        return 1
    fi

    echo "Deploying network resources to resource group: $identityResourceGroupName"

    az deployment group create \
        --name "DeployDevBox-Network" \
        --resource-group "$identityResourceGroupName" \
        --template-file ./network/deploy.bicep \
        --parameters \
            vnetName="$vnetName" \
            subnetName="$subNetName" \
            networkConnectionName="$networkConnectionName"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to deploy network resources."
        return 1
    fi

    echo "Network resources deployed successfully."
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


# Main function to deploy Microsoft DevBox
deployMicrosoftDevBox() {
    clear

    echo "Starting Deployment..."
    azureLogin

    local subscriptionId
    subscriptionId=$(az account show --query id --output tsv)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve subscription ID."
        exit 1
    fi

    echo "The Subscription ID is: $subscriptionId"

    deployResourcesOrganization

    deployIdentity "$identityResourceGroupName" "$identityName" "$customRoleName"

    deployNetwork "$networkResourceGroupName" "$vnetName" "$subNetName" "$networkConnectionName"
}

deployMicrosoftDevBox

clear
