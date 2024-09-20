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

    if [[ -z "$devCenterName" || -z "$networkConnectionName" || -z "$imageGalleryName" || -z "$location" || -z "$identityName" || -z "$devBoxResourceGroupName" || -z "$networkResourceGroupName" || -z "$identityResourceGroupName" || -z "$imageGalleryResourceGroupName" ]]; then
        echo "Error: Missing required parameters."
        return 1
    fi

    echo "Deploying Dev Center: $devCenterName"
    ./devBox/devCenter/deployDevCenter.sh "$devCenterName" "$networkConnectionName" "$imageGalleryName" "$location" "$identityName" "$devBoxResourceGroupName" "$networkResourceGroupName" "$identityResourceGroupName" "$imageGalleryResourceGroupName"

    createDevCenterProject
}

# Function to create a Dev Center project
createDevCenterProject() {

    if [[ -z "$location" || -z "$subscriptionId" || -z "$devBoxResourceGroupName" || -z "$devCenterName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createDevCenterProject <location> <subscriptionId> <devBoxResourceGroupName> <devCenterName>"
        return 1
    fi

    if [[ ! -f "./devBox/devCenter/createDevCenterProject.sh" ]]; then
        echo "Error: createDevCenterProject.sh script not found!"
        return 1
    fi

    echo "Creating Dev Center project: $devCenterName"
    ./devBox/devCenter/createDevCenterProject.sh "$location" "$subscriptionId" "$devBoxResourceGroupName" "$devCenterName"
}

# Function to set up the Dev Center
setUpDevBoxDefinition() {
    # Create Dev Box Definition
    echo "Creating Dev Box Definition..."
    ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$location" "$devBoxResourceGroupName" "$devCenterName" "$imageGalleryName" "$imageName" "$networkConnectionName" "$buildImage"
    if [ $? -eq 0 ]; then
        echo "Dev Box Definition created successfully."
    else
        echo "Error: Failed to create Dev Box Definition." >&2
        exit 1
    fi
}

setupImageTemplate(){
    local outputFilePath="$1"
    local subscriptionId="$2"
    local imageGalleryResourceGroupName="$3"
    local location="$4"
    local imageName="$5"
    local identityName="$6"
    local imageTemplateFile="$7"
    local imageGalleryName="$8"
    local offer="$9"
    local imgSku="${10}"
    local publisher="${11}"
    local identityResourceGroupName="${12}"

    if [[ -z "$outputFilePath" || -z "$subscriptionId" || -z "$imageGalleryResourceGroupName" || -z "$location" || -z "$imageName" || -z "$identityName" || -z "$imageTemplateFile" || -z "$imageGalleryName" || -z "$offer" || -z "$imgSku" || -z "$publisher" || -z "$identityResourceGroupName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: setupImageTemplate <outputFilePath> <subscriptionId> <imageGalleryResourceGroupName> <location> <imageName> <identityName> <imageTemplateFile> <imageGalleryName> <offer> <imgSku> <publisher> <identityResourceGroupName>"
        return 1
    fi

    echo "Setting up image template..."
    if ! ./devBox/computeGallery/createVMImageTemplate.sh "$outputFilePath" "$subscriptionId" "$imageGalleryResourceGroupName" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$imageGalleryName" "$offer" "$imgSku" "$publisher" "$identityResourceGroupName"; then
        echo "Error: Failed to set up image template."
        return 1
    fi
}

# Function to build images
buildImages() {
    declare -A imageParams
    imageParams["BackEnd-Docker-Img"]="VS22-BackEnd-Docker petv2-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"

    for imageName in "${!imageParams[@]}"; do
        IFS=' ' read -r imgSku offer outputFile imageTemplateFile publisher <<< "${imageParams[$imageName]}"
        setupImageTemplate "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$imageGalleryName" "$offer" "$imgSku" "$publisher" "$identityResourceGroupName"
        setUpDevBoxDefinition
    done
}

demoScript() {
    read -p "Do you want to continue? (y/n) " answer
    if [[ "$answer" == "y" ]]; then
        echo "Continuing..."
    else
        echo "Stopping the script."
        exit 1
    fi
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

    demoScript

    createIdentity "$subscriptionId"

    demoScript
    
    deployNetwork

    demoScript
    
    deployComputeGallery

    demoScript

    deployDevCenter

    demoScript

    if [[ "$buildImage" == "true" ]]; then
        echo "Building images..."
        buildImages
    else
        echo "Skipping image build..."
        setUpDevBoxDefinition
    fi

    echo "Deployment Completed Successfully!"
}

# Start the deployment process
deployMicrosoftDevBox "$@"