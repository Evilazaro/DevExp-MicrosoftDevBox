#!/bin/bash

echo "Deploying to Azure"

# Constants Parameters
readonly branch="main"
readonly location="WestUS3"
readonly locationComputeGallery=$location
readonly locationDevCenter=$location

# Azure Resource Group Names Constants
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

# Build Image Parameter to inform if the image should be built
buildImage=$2

# Function to log in to Azure
azureLogin() {
    local subscriptionName="$1"

    # Check if subscription name is provided
    if [[ -z "$subscriptionName" ]]; then
        echo "Error: Subscription name is missing!"
        echo "Usage: azureLogin <subscriptionName>"
        return 1
    fi
    
    echo "Attempting to login to Azure subscription: $subscriptionName"

    local scriptPath="./identity/login.sh"
    
    # Check if the login script exists and is executable
    if [[ ! -x "$scriptPath" ]]; then
        echo "Error: The login script $scriptPath does not exist or is not executable."
        return 1
    fi
    
    # Execute the login script
    "$scriptPath" "$subscriptionName"
    
    # Check if login was successful
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
    local location="$2"

    # Check if resource group name and location are provided
    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        exit 1
    fi

    echo "Creating Azure Resource Group..."
    echo "Resource Group Name: $resourceGroupName"
    echo "Location: $location"

    # Create the resource group with specified tags
    az group create --name "$resourceGroupName" --location "$location" --tags "division=petv2-Platform" "Environment=Prod" "offer=petv2-DevWorkstation-Service" "Team=Engineering" "division=petv2-Platform" "solution=ContosoFabricDevWorkstation"
    echo "Resource group '$resourceGroupName' created successfully."
}

# Function to create an identity
function createIdentity {
    local identityName=$1
    local resourceGroupName=$2
    local subscriptionId=$3
    local customRoleName=$4
    local location=$5

    # Check if all required parameters are provided
    if [[ -z $identityName || -z $resourceGroupName || -z $subscriptionId || -z $customRoleName || -z $location ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createIdentity <identityName> <resourceGroupName> <subscriptionId> <customRoleName> <location>"
        return 1
    fi
    
    # Execute scripts to create identity and register features
    ./identity/createIdentity.sh "$resourceGroupName" "$location" "$identityName"
    ./identity/registerFeatures.sh
    ./identity/createUserAssignedManagedIdentity.sh "$resourceGroupName" "$subscriptionId" "$identityName" "$customRoleName"
}

# Function to deploy a virtual network
function deploynetwork() {
    local vnetName="$1"
    local subNetName="$2"
    local networkConnectionName="$3"
    local resourceGroupName="$4"
    local subscriptionId="$5"
    local location="$6"

    # Check if the deployVnet.sh script exists
    if [ ! -f "./network/deployVnet.sh" ]; then
        echo "Error: deployVnet.sh script not found."
        return 1
    fi

    # Execute scripts to deploy the virtual network and create network connection
    ./network/deployVnet.sh "$resourceGroupName" "$location" "$vnetName" "$subNetName"
    ./network/createNetWorkConnection.sh "$location" "$resourceGroupName" "$vnetName" "$subNetName" "$networkConnectionName"
    local exitCode="$?"

    # Check if the deployment was successful
    if [ "$exitCode" -ne 0 ]; then
        echo "Error: Deployment of Vnet failed with exit code $exitCode."
        return 1
    fi
}

# Function to deploy a Compute Gallery
function deployComputeGallery {
    local imageGalleryName="$1"  
    local location="$2"           
    local galleryResourceGroupName="$3"  

    # Execute the script to deploy the Compute Gallery
    ./devBox/computeGallery/deployComputeGallery.sh "$imageGalleryName" "$location" "$galleryResourceGroupName"
}

# Function to deploy a Dev Center
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

    # Check if all required parameters are provided
    if [ -z "$devCenterName" ] || [ -z "$networkConnectionName" ] || [ -z "$imageGalleryName" ] || [ -z "$location" ] || [ -z "$identityName" ] || [ -z "$devBoxResourceGroupName" ] || [ -z "$networkResourceGroupName" ] || [ -z "$identityResourceGroupName" ] || [ -z "$imageGalleryResourceGroupName" ]; then
        echo "Error: Missing required parameters."
        return 1 
    fi
    
    # Execute the script to deploy the Dev Center
    ./devBox/devCenter/deployDevCenter.sh "$devCenterName" "$networkConnectionName" "$imageGalleryName" "$location" "$identityName" "$devBoxResourceGroupName" "$networkResourceGroupName" "$identityResourceGroupName" "$imageGalleryResourceGroupName"
}

# Function to create a Dev Center project
function createDevCenterProject() {
    local location="$1"
    local subscriptionId="$2"
    local resourceGroupName="$3"
    local devCenterName="$4"
    
    # Check if all required parameters are provided
    if [[ -z "$location" || -z "$subscriptionId" || -z "$resourceGroupName" || -z "$devCenterName" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createDevCenterProject <location> <subscriptionId> <resourceGroupName> <devCenterName>"
        return 1
    fi
    
    # Check if the createDevCenterProject.sh script exists
    if [[ ! -f "./devBox/devCenter/createDevCenterProject.sh" ]]; then
        echo "Error: createDevCenterProject.sh script not found!"
        return 1
    fi
    
    # Execute the script to create the Dev Center project
    ./devBox/devCenter/createDevCenterProject.sh "$location" "$subscriptionId" "$resourceGroupName" "$devCenterName"
}

# Function to build images
function buildImage {
    local subscriptionId="$1"
    local imageGalleryResourceGroupName="$2"
    local location="$3"
    local identityName="$4"
    local galleryName="$5"
    local identityResourceGroupName="$6"
    local devBoxResourceGroupName="$7"
    local networkConnectionName="$8"

    # Declare an associative array to store image parameters
    declare -A image_params

    # Define image parameters
    image_params["BackEnd-Docker-Img"]="VS22-BackEnd-Docker petv2-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"

    # Loop through the image parameters and execute scripts to create VM image templates and DevBox definitions
    for imageName in "${!image_params[@]}"; do
        IFS=' ' read -r imgSKU offer outputFile imageTemplateFile publisher <<< "${image_params[$imageName]}"
        ./devBox/computeGallery/createVMImageTemplate.sh "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$locationComputeGallery" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher" "$identityResourceGroupName"
        ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$locationDevCenter" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" "$buildImage"
    done
}

# Main function to deploy Microsoft DevBox
deployMicrosoftDevBox() {
    clear
    set -e

    local subscriptionName="$1"
    local subscriptionId

    echo "Starting Deployment..."

    # Log in to Azure
    azureLogin "$subscriptionName"

    # Get the subscription ID
    subscriptionId=$(az account show --query id --output tsv)
    
    # # Create necessary resource groups
    # createResourceGroup "$devBoxResourceGroupName" "$location"
    # createResourceGroup "$imageGalleryResourceGroupName" "$location"
    # createResourceGroup "$identityResourceGroupName" "$location"
    # createResourceGroup "$networkResourceGroupName" "$location"
    # createResourceGroup "$managementResourceGroupName" "$location"

    # # Create identity
    # createIdentity $identityName $identityResourceGroupName $subscriptionId $customRoleName $location

    # # Deploy network
    # deploynetwork $vnetName $subNetName $networkConnectionName $networkResourceGroupName $subscriptionId $location

    # # Deploy Compute Gallery
    # deployComputeGallery $imageGalleryName $locationComputeGallery $imageGalleryResourceGroupName

    # # Deploy Dev Center
    # deployDevCenter $devCenterName $networkConnectionName $imageGalleryName $locationDevCenter $identityName $devBoxResourceGroupName $networkResourceGroupName $identityResourceGroupName $imageGalleryResourceGroupName

    # # Create Dev Center project
    # createDevCenterProject $locationDevCenter $subscriptionId $devBoxResourceGroupName $devCenterName

    # echo "Skipping image build..."
    # echo "Creating DevBox Definition for Back End Developers with Visual Studio 2022"
    # imageName="microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2"
    # galleryName=$devCenterName
    # ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$locationDevCenter" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" false

    # echo "Creating DevBox Definition for Front End Developers"
    # imageName="microsoftvisualstudio_windowsplustools_base-win11-gen2"
    # ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$locationDevCenter" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" false
    
    # # Check if the deployment was successful
    # if [[ $? -ne 0 ]]; then
    #     echo "Error: Deployment failed. Error: $?"
    #     exit 1
    # fi

    # clear
      
    # # Check if images should be built
    # if [[ "$buildImage" == "true" ]]; then
    #     echo "Deployment Completed Successfully! Building images..."
    #     echo "You can start creating DevBoxes for your team."
    #     buildImage $subscriptionId $imageGalleryResourceGroupName $locationComputeGallery $identityName $imageGalleryName $identityResourceGroupName $devBoxResourceGroupName $networkConnectionName
    # else
    #     echo "Deployment Completed Successfully!"
    #     echo "You can start creating DevBoxes for your team."
    # fi
}

# Start the deployment process
deployMicrosoftDevBox "$@"