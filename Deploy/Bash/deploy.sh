#!/bin/bash

clear

# Functions

function login() {
    # Declaring 'local' makes 'subscriptionName' a local variable, restricting its scope to within this function.
    local subscriptionName="$1"  # $1 represents the first argument passed to the function.
    
    # Check if the subscriptionName is empty and print a helpful message if it is.
    if [[ -z "$subscriptionName" ]]; then
        echo "Error: Subscription name is missing!"
        echo "Usage: login <subscriptionName>"
        return 1
    fi
    
    echo "Attempting to login to Azure subscription: $subscriptionName"

    # The path to 'login.sh' script. This script presumably handles Azure CLI login details.
    local scriptPath='./identity/login.sh'
    
    # Check if the login.sh script exists and is executable, if not print a helpful message.
    if [[ ! -x "$scriptPath" ]]; then
        echo "Error: The login script $scriptPath does not exist or is not executable."
        return 1
    fi
    
    # Execute the login script with the provided subscription name.
    "$scriptPath" "$subscriptionName"
    
    # Check the exit status of the last command (login.sh) and print appropriate message.
    if [[ $? -eq 0 ]]; then
        echo "Successfully logged in to $subscriptionName."
    else
        echo "Failed to log in to $subscriptionName."
        return 1
    fi
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

function buildImage
{
    local subscriptionId="$1"
    local imageGalleryResourceGroupName="$2"
    local location="$3"
    local identityName="$4"
    local galleryName="$5"
    local identityResourceGroupName="$6"
    local devBoxResourceGroupName="$7"
    local networkConnectionName="$8"

    declare -A image_params
    image_params["FrontEnd-Docker-Img"]="VSCode-FrontEnd-Docker Contoso-Fabric ./DownloadedTempTemplates/FrontEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/computeGallery/frontEndEngineerImgTemplate.json Contoso"
    #image_params["BackEnd-Docker-Img"]="VS22-BackEnd-Docker Contoso-Fabric ./DownloadedTempTemplates/BackEnd-Docker-Output.json https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/computeGallery/backEndEngineerImgTemplate.json Contoso"

    for imageName in "${!image_params[@]}"; do
        IFS=' ' read -r imgSKU offer outputFile imageTemplateFile publisher <<< "${image_params[$imageName]}"
        ./devBox/computeGallery/createVMImageTemplate.sh "$outputFile" "$subscriptionId" "$imageGalleryResourceGroupName" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher" "$identityResourceGroupName"
        ./devBox/devCenter/createDevBoxDefinition.sh "$subscriptionId" "$location" "$devBoxResourceGroupName" "$devCenterName" "$galleryName" "$imageName" "$networkConnectionName"
    done
}


set -e

# Variables
branch="main"
location='WestUS3'

# Validate if subscriptionName is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <subscriptionName>"
    exit 1
fi

subscriptionName=$1
subscriptionId=$(az account show --query id --output tsv)

# Resource Group names
devBoxResourceGroupName='ContosoFabric-DevBox-RG'
imageGalleryResourceGroupName='ContosoFabric-ImageGallery-RG'
identityResourceGroupName='ContosoFabric-Identity-DevBox-RG'
networkResourceGroupName='eShop-Network-Connectivity-RG'
managementResourceGroupName='ContosoFabric-DevBox-Management-RG'

# Identity Variables
identityName='ContosoFabricDevBoxImgBldId'
customRoleName='ContosoFabricBuilderRole'

# Image and DevCenter Names
imageGalleryName='ContosoFabricImageGallery'
frontEndImageName='eShop-FrontEnd'
backEndImageName='eShop-BackEnd'
devCenterName='DevBox-DevCenter'

# Network Variables
vnetName='eShop-Vnet'
subNetName='eShop-SubNet'
networkConnectionName='eShop-DevBox-Network-Connection'

# Execute the script with proper sequence
echo "Starting Deployment..."

# Login to Azure
login "$subscriptionName"

# Deploy Resource Groups
createResourceGroup "$devBoxResourceGroupName" "$location"
createResourceGroup "$imageGalleryResourceGroupName" "$location"
createResourceGroup "$identityResourceGroupName" "$location"
createResourceGroup "$networkResourceGroupName" "$location"
createResourceGroup "$managementResourceGroupName" "$location"

# ... Here you would call the other functions in a similar fashion

echo "Deployment Completed Successfully!"


# Deploy Identity
createIdentity $identityName $identityResourceGroupName $subscriptionId $customRoleName $location

# Deploy network
deploynetwork $vnetName $subNetName $networkConnectionName $networkResourceGroupName $subscriptionId $location

# Deploy Compute Gallery
deployComputeGallery $imageGalleryName $location $imageGalleryResourceGroupName

# Deploy Dev Center
deployDevCenter $devCenterName $networkConnectionName $imageGalleryName $location $identityName $devBoxResourceGroupName $networkResourceGroupName $identityResourceGroupName $imageGalleryResourceGroupName

# Creating Dev Center Project
createDevCenterProject $location $subscriptionId $devBoxResourceGroupName $devCenterName

# Building Images
buildImage $subscriptionId $imageGalleryResourceGroupName $location $identityName $imageGalleryName $identityResourceGroupName $devBoxResourceGroupName $networkConnectionName