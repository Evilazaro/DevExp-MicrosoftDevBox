#!/bin/bash

echo "Deploying to Azure"

# Constants Parameters
readonly branch="main"
readonly location="WestUS3"

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

    # Check if resource group name and location are provided
    if [[ -z "$resourceGroupName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createResourceGroup <resourceGroupName> <location>"
        return 1
    fi

    echo "Creating Azure Resource Group..."
    echo "Resource Group Name: $resourceGroupName"
    echo "Location: $location"

    # Create the resource group with specified tags
    if az group create --name "$resourceGroupName" --location "$location" --tags "division=petv2-Platform" "Environment=Prod" "offer=petv2-DevWorkstation-Service" "Team=Engineering" "division=petv2-Platform" "solution=ContosoFabricDevWorkstation"; then
        echo "Resource group '$resourceGroupName' created successfully."
    else
        echo "Error: Failed to create resource group '$resourceGroupName'."
        return 1
    fi
}

# Function to create an identity
function createIdentity {
    # Check if all required parameters are provided
    if [[ -z "$identityName" || -z "$identityResourceGroupName" || -z "$subscriptionId" || -z "$customRoleName" || -z "$location" ]]; then
        echo "Error: Missing required parameters."
        echo "Usage: createIdentity <identityName> <resourceGroupName> <subscriptionId> <customRoleName> <location>"
        return 1
    fi

    # Execute the script to create the identity
    echo "Creating identity..."
    if ! ./identity/createIdentity.sh "$identityResourceGroupName" "$location" "$identityName"; then
        echo "Error: Failed to create identity."
        return 1
    fi

    # Execute the script to register features
    echo "Registering features..."
    if ! ./identity/registerFeatures.sh; then
        echo "Error: Failed to register features."
        return 1
    fi

    # Execute the script to create a user-assigned managed identity
    echo "Creating user-assigned managed identity..."
    if ! ./identity/createUserAssignedManagedIdentity.sh "$identityResourceGroupName" "$subscriptionId" "$identityName" "$customRoleName"; then
        echo "Error: Failed to create user-assigned managed identity."
        return 1
    fi

    echo "Identity and features successfully created and registered."
}

# Function to deploy a virtual network
function deploynetwork() {

    # Check if the deployVnet.sh script exists
    if [ ! -f "./network/deployVnet.sh" ]; then
        echo "Error: deployVnet.sh script not found."
        return 1
    fi

    # Check if the createNetWorkConnection.sh script exists
    if [ ! -f "./network/createNetWorkConnection.sh" ]; then
        echo "Error: createNetWorkConnection.sh script not found."
        return 1
    fi

    # Execute the script to deploy the virtual network
    echo "Deploying virtual network..."
    if ! ./network/deployVnet.sh "$networkResourceGroupName" "$location" "$vnetName" "$subNetName"; then
        echo "Error: Failed to deploy virtual network."
        return 1
    fi

    # Execute the script to create the network connection
    echo "Creating network connection..."
    if ! ./network/createNetWorkConnection.sh "$location" "$networkResourceGroupName" "$vnetName" "$subNetName" "$networkConnectionName"; then
        echo "Error: Failed to create network connection."
        return 1
    fi

    echo "Virtual network and network connection deployed successfully."
}

# Function to deploy a Compute Gallery
function deployComputeGallery {
    local imageGalleryName="$1"            
    local galleryResourceGroupName="$2"  

    # Execute the script to deploy the Compute Gallery
    ./devBox/computeGallery/deployComputeGallery.sh "$imageGalleryName" "$location" "$galleryResourceGroupName"
}

# Function to deploy a Dev Center
function deployDevCenter() {
    local devCenterName="$1"
    local networkConnectionName="$2"
    local imageGalleryName="$3"
    local identityName="$4"
    local devBoxResourceGroupName="$5"
    local networkResourceGroupName="$6"
    local identityResourceGroupName="$7"
    local imageGalleryResourceGroupName="$8"

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
    local subscriptionId="$1"
    local resourceGroupName="$2"
    local devCenterName="$3"
    
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
    local identityName="$3"
    local galleryName="$4"
    local identityResourceGroupName="$5"
    local devBoxResourceGroupName="$6"
    local networkConnectionName="$7"

    # Declare an associative array to store image parameters
    declare -A image_params

    # Define image parameters
    image_params["BackEnd-Docker-Img"]="VS22-BackEnd-Docker petv2-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplateDocker.json Contoso"

    # Loop through the image parameters and execute scripts to create VM image templates and DevBox definitions
    for imageName in "${!image_params[@]}"; do
        IFS=' ' read -r imgSKU offer outputFile imageTemplateFile publisher <<< "${image_params[$imageName]}"
        ./devBox/computeGallery/createVMImageTemplate.sh "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher" "$identityResourceGroupName"
        ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$location" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" "$buildImage"
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

    echo "The Subscription ID is: " $subscriptionId
    
    # Create necessary resource groups
    createResourceGroup "$devBoxResourceGroupName"
    createResourceGroup "$imageGalleryResourceGroupName"
    createResourceGroup "$identityResourceGroupName"
    createResourceGroup "$networkResourceGroupName"
    createResourceGroup "$managementResourceGroupName"

    # Create identity
    createIdentity

    # Deploy network
    deploynetwork

    # # Deploy Compute Gallery
    # deployComputeGallery $imageGalleryName $location $imageGalleryResourceGroupName

    # # Deploy Dev Center
    # deployDevCenter $devCenterName $networkConnectionName $imageGalleryName $location $identityName $devBoxResourceGroupName $networkResourceGroupName $identityResourceGroupName $imageGalleryResourceGroupName

    # # Create Dev Center project
    # createDevCenterProject $location $subscriptionId $devBoxResourceGroupName $devCenterName

    # echo "Skipping image build..."
    # echo "Creating DevBox Definition for Back End Developers with Visual Studio 2022"
    # imageName="microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2"
    # galleryName=$devCenterName
    # ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$location" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" false

    # echo "Creating DevBox Definition for Front End Developers"
    # imageName="microsoftvisualstudio_windowsplustools_base-win11-gen2"
    # ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$location" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName" false
    
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
    #     buildImage $subscriptionId $imageGalleryResourceGroupName $location $identityName $imageGalleryName $identityResourceGroupName $devBoxResourceGroupName $networkConnectionName
    # else
    #     echo "Deployment Completed Successfully!"
    #     echo "You can start creating DevBoxes for your team."
    # fi
}

# Start the deployment process
deployMicrosoftDevBox "$@"