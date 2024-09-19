#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

echo "Deploying to Azure"

# Constants Parameters
readonly branch="main"
readonly location="WestUS3"

# Azure Resource Group Names Constants
readonly subscriptionName="$1"
readonly devBoxResourceGroupName="petv2DevBox-rg"
readonly imageGalleryResourceGroupName="petv2ImageGallery-rg"
readonly identityResourceGroupName="petv2IdentityDevBox-rg"
readonly networkResourceGroupName="petv2NetworkConnectivity-rg"
readonly managementResourceGroupName="petv2DevBoxManagement-rg"

# Identity Parameters Constants
readonly identityName="petv2DevBoxImgBldId"
readonly customRoleName="petv2BuilderRole"

# Image and DevCenter Parameters Constants
readonly imageGalleryName="petv2ImageGallery"
readonly frontEndImageName="frontEndVm"
readonly backEndImageName="backEndVm"
readonly devCenterName="petv2DevCenter"

# Network Parameters Constants
readonly vnetName="petv2Vnet"
readonly subNetName="petv2SubNet"
readonly networkConnectionName="devBoxNetworkConnection"

# Build Image local to inform if the image should be built
buildImage=${2:-false}

# Function to log in to Azure
azureLogin() {
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

# Function to create an identity
createIdentity() {
    local subscriptionId="$1"

    if [[ -z "$identityName" || -z "$identityResourceGroupName" || -z "$subscriptionId" || -z "$customRoleName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createIdentity <identityName> <resourceGroupName> <subscriptionId> <customRoleName> <location>"
        return 1
    fi

    echo "Creating identity..."
    if ! ./identity/createIdentity.sh "$identityResourceGroupName" "$location" "$identityName"; then
        echo "Error: Failed to create identity."
        return 1
    fi

    echo "Registering features..."
    if ! ./identity/registerFeatures.sh; then
        echo "Error: Failed to register features."
        return 1
    fi

    echo "Creating user-assigned managed identity..."
    subscriptionId=$(az account show --query id --output tsv)

    echo "Subscription ID: $subscriptionId"
    
    if ! ./identity/createUserAssignedManagedIdentity.sh "$identityResourceGroupName" "$subscriptionId" "$identityName" "$customRoleName" "$location"; then
        echo "Error: Failed to create user-assigned managed identity."
        return 1
    fi

    echo "Identity and features successfully created and registered."
}

# Function to deploy a virtual network
deployNetwork() {
    if [[ ! -f "./network/deployVnet.sh" ]]; then
        echo "Error: deployVnet.sh script not found."
        return 1
    fi

    if [[ ! -f "./network/createNetworkConnection.sh" ]]; then
        echo "Error: createNetworkConnection.sh script not found."
        return 1
    fi

    echo "Deploying virtual network..."
    if ! ./network/deployVnet.sh "$networkResourceGroupName" "$location" "$vnetName" "$subNetName"; then
        echo "Error: Failed to deploy virtual network."
        return 1
    fi

    echo "Creating network connection..."
    if ! ./network/createNetworkConnection.sh "$location" "$networkResourceGroupName" "$vnetName" "$subNetName" "$networkConnectionName"; then
        echo "Error: Failed to create network connection."
        return 1
    fi

    echo "Virtual network and network connection deployed successfully."
}

# Function to deploy a compute gallery
deployComputeGallery() {
    if [[ -z "$imageGalleryName" || -z "$imageGalleryResourceGroupName" ]]; then
        echo "Error: Missing required arguments."
        echo "Usage: deployComputeGallery <imageGalleryName> <imageGalleryResourceGroupName>"
        exit 1
    fi

    local deployScript="./devBox/computeGallery/deployComputeGallery.sh"
    if [[ ! -f "$deployScript" ]]; then
        echo "Error: Deployment script not found at $deployScript"
        exit 1
    fi

    echo "Deploying Compute Gallery: $imageGalleryName in Resource Group: $imageGalleryResourceGroupName"
    "$deployScript" "$imageGalleryName" "$location" "$imageGalleryResourceGroupName"
}

# Function to deploy a Dev Center
deployDevCenter() {
    local devCenterName="$1"
    local networkConnectionName="$2"
    local imageGalleryName="$3"
    local identityName="$4"
    local devBoxResourceGroupName="$5"
    local networkResourceGroupName="$6"
    local identityResourceGroupName="$7"
    local imageGalleryResourceGroupName="$8"

    if [[ -z "$devCenterName" || -z "$networkConnectionName" || -z "$imageGalleryName" || -z "$location" || -z "$identityName" || -z "$devBoxResourceGroupName" || -z "$networkResourceGroupName" || -z "$identityResourceGroupName" || -z "$imageGalleryResourceGroupName" ]]; then
        echo "Error: Missing required parameters."
        return 1
    fi

    echo "Deploying Dev Center: $devCenterName"
    ./devBox/devCenter/deployDevCenter.sh "$devCenterName" "$networkConnectionName" "$imageGalleryName" "$location" "$identityName" "$devBoxResourceGroupName" "$networkResourceGroupName" "$identityResourceGroupName" "$imageGalleryResourceGroupName"
}

# Function to create a Dev Center project
createDevCenterProject() {
    local subscriptionId="$1"
    local resourceGroupName="$2"
    local devCenterName="$3"

    if [[ -z "$location" || -z "$subscriptionId" || -z "$resourceGroupName" || -z "$devCenterName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createDevCenterProject <location> <subscriptionId> <resourceGroupName> <devCenterName>"
        return 1
    fi

    if [[ ! -f "./devBox/devCenter/createDevCenterProject.sh" ]]; then
        echo "Error: createDevCenterProject.sh script not found!"
        return 1
    fi

    echo "Creating Dev Center project: $devCenterName"
    ./devBox/devCenter/createDevCenterProject.sh "$location" "$subscriptionId" "$resourceGroupName" "$devCenterName"
}

# Function to build images
buildImages() {
    local subscriptionId="$1"
    local imageGalleryResourceGroupName="$2"
    local identityName="$3"
    local galleryName="$4"
    local identityResourceGroupName="$5"
    local devBoxResourceGroupName="$6"
    local networkConnectionName="$7"

    declare -A imageParams
    imageParams["BackEnd-Docker-Img"]="VS22-BackEnd-Docker petv2-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"

    for imageName in "${!imageParams[@]}"; do
        IFS=' ' read -r imgSku offer outputFile imageTemplateFile publisher <<< "${imageParams[$imageName]}"
        ./devBox/computeGallery/createVMImageTemplate.sh "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSku" "$publisher" "$identityResourceGroupName"
        ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$location" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" "$buildImage"
    done
}

# Main function to deploy Microsoft DevBox
deployMicrosoftDevBox() {
    clear
    
    echo "Starting Deployment..."
    azureLogin

    local subscriptionId
    subscriptionId=$(az account show --query id --output tsv)
    
    echo "The Subscription ID is: $subscriptionId"

    createResourceGroup "$devBoxResourceGroupName"
    createResourceGroup "$imageGalleryResourceGroupName"
    createResourceGroup "$identityResourceGroupName"
    createResourceGroup "$networkResourceGroupName"
    createResourceGroup "$managementResourceGroupName"

    createIdentity "$subscriptionId"
    
    deployNetwork
    
    deployComputeGallery

    # deployDevCenter "$devCenterName" "$networkConnectionName" "$imageGalleryName" "$identityName" "$devBoxResourceGroupName" "$networkResourceGroupName" "$identityResourceGroupName" "$imageGalleryResourceGroupName"
    # createDevCenterProject "$subscriptionId" "$devBoxResourceGroupName" "$devCenterName"

    # if [[ "$buildImage" == "true" ]]; then
    #     echo "Building images..."
    #     buildImages "$subscriptionId" "$imageGalleryResourceGroupName" "$identityName" "$imageGalleryName" "$identityResourceGroupName" "$devBoxResourceGroupName" "$networkConnectionName"
    # fi

    echo "Deployment Completed Successfully!"
}

# Start the deployment process
deployMicrosoftDevBox "$@"