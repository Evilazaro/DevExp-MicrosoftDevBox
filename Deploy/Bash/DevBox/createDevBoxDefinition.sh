#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <subscriptionId> <location> <resourceGroupName> <devCenterName> <galleryName> <imageName>"
    exit 1
fi

# Assigning input arguments to variables
subscriptionId="$1"
location="$2"
resourceGroupName="$3"
devCenterName="$4"
galleryName="$5"
imageName="$6"

# Echoing the initialization message
echo "Initializing the creation of DevBox Definition with the following parameters:"
echo "Subscription ID: $subscriptionId"
echo "Location: $location"
echo "Image Resource Group Name: $resourceGroupName"
echo "Dev Center Name: $devCenterName"
echo "Gallery Name: $galleryName"
echo "Image Name: $imageName"

imageVersion="1.0.0"
imageReferenceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/${galleryName}/images/$imageName/versions/$imageVersion" 
devBoxDefinitionName="devBox-$imageName-def"
networkConnectionName="Contoso-Network-Connection-DevBox"
projectName="eShop"

# Creating the DevBox Definition
echo "Creating DevBox Definition..."
az devcenter admin devbox-definition create --location "$location" \
    --image-reference id="$imageReferenceId" \
    --os-storage-type "ssd_256gb" \
    --sku name="general_i_8c32gb256ssd_v2" \
    --name "$devBoxDefinitionName" \
    --dev-center-name "$devCenterName" \
    --resource-group "$resourceGroupName" \
    --devbox-definition-name "devBox-$imageName-definition" \
    --tags  "division=Contoso-Platform" \
                "Environment=Prod" \
                "offer=Contoso-DevWorkstation-Service" \
                "Team=Engineering" \
                "division=Contoso-Platform" \
                "solution=eShop" \
                "businessUnit=e-Commerce"

# Echoing the completion message
echo "DevBox Definition creation completed successfully."

./DevBox/createDevBoxPools.sh "$location" "$devBoxDefinitionName" "$networkConnectionName" "$imageName-devbox-pool" "$projectName" "$resourceGroupName"

