#!/bin/bash

# This script initializes and creates a DevBox Definition in Azure

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display the usage of the script
usage() {
    echo "Usage: $0 <subscriptionId> <location> <resourceGroupName> <devCenterName> <galleryName> <imageName>"
    exit 1
}

# Function to initialize the creation of DevBox Definition
initialize_creation() {
    echo "Initializing the creation of DevBox Definition with the following parameters:"
    echo "Subscription ID: $subscriptionId"
    echo "Location: $location"
    echo "Image Resource Group Name: $resourceGroupName"
    echo "Dev Center Name: $devCenterName"
    echo "Gallery Name: $galleryName"
    echo "Image Name: $imageName"
    echo "Image Reference ID: $imageReferenceId"
    echo "DevBox Definition Name: $devBoxDefinitionName"
    echo "Network Connection Name: $networkConnectionName"
    echo "Project Name: $projectName"
    echo "Pool Name: $poolName"
    echo "DevBox Name: $devBoxName"
}

# Function to create the DevBox Definition
create_devbox_definition() {
    echo "Creating DevBox Definition..."
    az devcenter admin devbox-definition create --location "$location" \
        --image-reference id="$imageReferenceId" \
        --os-storage-type "ssd_256gb" \
        --sku name="general_i_8c32gb256ssd_v2" \
        --name "$devBoxDefinitionName" \
        --dev-center-name "$devCenterName" \
        --resource-group "$resourceGroupName" \
        --devbox-definition-name "devBox-$imageName" \
        --hibernation-enabled "true" \
        --tags  "division=Contoso-Platform" \
                    "Environment=Prod" \
                    "offer=Contoso-DevWorkstation-Service" \
                    "Team=Engineering" \
                    "solution=eShop" \
                    "businessUnit=e-Commerce"
    echo "DevBox Definition creation completed successfully."
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    usage
fi

# Assigning input arguments to variables
subscriptionId="$1"
location="$2"
resourceGroupName="$3"
devCenterName="$4"
galleryName="$5"
imageName="$6"

# Construct necessary variables
imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/${imageName}-def/"
devBoxDefinitionName="devBox-$imageName"
networkConnectionName="Contoso-Network-Connection-DevBox"
projectName="eShop"
poolName="$imageName-pool"
devBoxName="$imageName-devbox"

# Call functions
initialize_creation
create_devbox_definition

# Execute additional scripts
./DevBox/createDevBoxPools.sh "$location" "$devBoxDefinitionName" "$networkConnectionName" "$poolName" "$projectName" "$resourceGroupName"
./DevBox/createDevBoxforEngineers.sh "$poolName" "$devBoxName" "$devCenterName" "$projectName"

