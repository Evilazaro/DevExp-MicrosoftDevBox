#!/bin/bash

# Functions

function login {
    local subscriptionName=$1

    ./identity/login.sh $subscriptionName
}

function createResourceGroup {
    local resourceGroupName=$1
    local location=$2

    # Exit on error
    set -e

    # Validate inputs
    if [ -z "$resourceGroupName" ] || [ -z "$location" ]; then
        echo "Usage: $0 <ResourceGroupName> <Location>"
        exit 1
    fi

    # Echo steps
    echo "Creating Azure Resource Group..."
    echo "Resource Group Name: $resourceGroupName"
    echo "Location: $location"

    # Creating Azure Resource Group
    az group create \
        --name "$resourceGroupName" \
        --location "$location" \
        --tags  "division=Contoso-Platform" \
                "Environment=Prod" \
                "offer=Contoso-DevWorkstation-Service" \
                "Team=Engineering" \
                "division=Contoso-Platform" \
                "solution=eShop"

    # Echo successful creation
    echo "Resource group '$resourceGroupName' created successfully."
}

function createIdentity {
    local identityName=$1
    local resourceGroupName=$2
    local subscriptionId=$3
    local customRoleName=$4
    local location=$5

    # Validate the presence of all parameters
    if [[ -z $identityName || -z $resourceGroupName || -z $subscriptionId || -z $customRoleName || -z $location ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createIdentity <identityName> <resourceGroupName> <subscriptionId> <customRoleName> <location>"
        return 1
    fi
    
    ./identity/createIdentity.sh "$resourceGroupName" "$location" "$identityName"
    ./identity/registerFeatures.sh
    ./identity/createUserAssignedManagedIdentity.sh "$resourceGroupName" "$subscriptionId" "$identityName" "$customRoleName"
    
} 

function deploynetwork() {
    # Local variables to store function arguments
    local vnetName="$1"
    local subNetName="$2"
    local networkConnectionName="$3"
    local resourceGroupName="$4"
    local subscriptionId="$5"
    local location="$6"

    # Check if the deployVnet.sh script exists before attempting to execute it
    if [ ! -f "./network/deployVnet.sh" ]; then
        echo "Error: deployVnet.sh script not found."
        return 1
    fi

    # Execute the deployVnet.sh script with the passed parameters and capture its exit code
    ./network/deployVnet.sh "$resourceGroupName" "$location" "$vnetName" "$subNetName"
    ./network/createNetWorkConnection.sh "$location" "$resourceGroupName" "$vnetName" "$subNetName" "$networkConnectionName"
    local exitCode="$?"

    # Check the exit code of the deployVnet.sh script and echo appropriate message
    if [ "$exitCode" -ne 0 ]; then
        echo "Error: Deployment of Vnet failed with exit code $exitCode."
        return 1
    fi
}

# This function deploys a Compute Gallery to a specified location and resource group.
# It receives three parameters: 
# 1. imageGalleryName: The name of the Compute Gallery
# 2. location: The Azure region where the Compute Gallery will be deployed
# 3. galleryResourceGroupName: The name of the resource group where the Compute Gallery will be placed

function deployComputeGallery {
    local imageGalleryName="$1"  # The name of the Compute Gallery to deploy
    local location="$2"            # The Azure location (region) where the Compute Gallery will be deployed
    local galleryResourceGroupName="$3"  # The resource group where the Compute Gallery will reside

    # The actual deployment command. Using a relative path to the deployment script
    ./devBox/computeGallery/deployComputeGallery.sh "$imageGalleryName" "$location" "$galleryResourceGroupName"
}

# Function to deploy Dev Center
function deployDevCenter() {
    local devCenterName="$1"
    local networkConnectionName="$2"
    local imageGalleryName="$3"
    local location="$4"
    local identityName="$5"
    local devBoxResourceGroupName="$6"
    local networkResourceGroupName="$7"
    local identityResourceGroupName="$8"
    local imageGalleryResourceGroupName="$9"

    # Validate that all required parameters are provided
    if [ -z "$devCenterName" ] || [ -z "$networkConnectionName" ] || [ -z "$imageGalleryName" ] || [ -z "$location" ] || [ -z "$identityName" ] || [ -z "$devBoxResourceGroupName" ] || [ -z "$networkResourceGroupName" ] || [ -z "$identityResourceGroupName" ] || [ -z "$imageGalleryResourceGroupName" ]; then
        echo "Error: Missing required parameters."
        return 1 # Return with error code
    fi
    
    # Execute the deployDevCenter.sh script with the provided parameters and capture its exit code
    ./devBox/devCenter/deployDevCenter.sh "$devCenterName" "$networkConnectionName" "$imageGalleryName" "$location" "$identityName" "$devBoxResourceGroupName" "$networkResourceGroupName" "$identityResourceGroupName" "$imageGalleryResourceGroupName"

}

function createDevCenterProject() {
    local location="$1"
    local subscriptionId="$2"
    local resourceGroupName="$3"
    local devCenterName="$4"
    
    # Check if the necessary parameters are provided
    if [[ -z "$location" || -z "$subscriptionId" || -z "$resourceGroupName" || -z "$devCenterName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createDevCenterProject <location> <subscriptionId> <resourceGroupName> <devCenterName>"
        return 1
    fi
    
    # Validate if the createDevCenterProject.sh script exists before executing
    if [[ ! -f "./devBox/devCenter/createDevCenterProject.sh" ]]; then
        echo "Error: createDevCenterProject.sh script not found!"
        return 1
    fi
    
    ./devBox/devCenter/createDevCenterProject.sh "$location" "$subscriptionId" "$resourceGroupName" "$devCenterName"
}


# Declaring Variables

# Resources Organization
subscriptionName=$1
subscriptionId=$(az account show --query id --output tsv)
devBoxResourceGroupName='eShop-DevBox-rg'
imageGalleryResourceGroupName='eShop-DevBox-ImgGallery-rg'
identityResourceGroupName='eShop-DevBox-Identity-rg'
networkResourceGroupName='eShop-DevBox-network-rg'
location='WestUS3'

# Identity
identityName='eShopDevBoxImgBldId'
customRoleName='eShopImgBuilderRole'

# Dev Box 
imageGalleryName='eShopDevBoxImageGallery'
frontEndImageName='eShop-DevBox-FrontEnd'
backEndImageName='eShop-DevBox-BackEnd'
devCenterName='eShop-DevBox-DevCenter'

# network
vnetName='eShop-DevBox-VNet'
subNetName='eShop-DevBox-SubNet'
networkConnectionName='eShop-DevBox-Network-Connection'

# Management
managementResourceGroupName='eShop-DevBox-Management-rg'

# Login to Azure
login $subscriptionName

# Deploying Resources Group
createResourceGroup $devBoxResourceGroupName $location
createResourceGroup $imageGalleryResourceGroupName $location
createResourceGroup $identityResourceGroupName $location
createResourceGroup $networkResourceGroupName $location
createResourceGroup $managementResourceGroupName $location

# Deploying Identity
createIdentity $identityName $identityResourceGroupName $subscriptionId $customRoleName $location

# Deploying network
deploynetwork $vnetName $subNetName $networkConnectionName $networkResourceGroupName $subscriptionId $location

# Deploying Compute Gallery
deployComputeGallery $imageGalleryName $location $imageGalleryResourceGroupName

# Deploying Dev Center
deployDevCenter $devCenterName $networkConnectionName $imageGalleryName $location $identityName $devBoxResourceGroupName $networkResourceGroupName $identityResourceGroupName $imageGalleryResourceGroupName

# Creating Dev Center Project
createDevCenterProject $location $subscriptionId $devBoxResourceGroupName $devCenterName