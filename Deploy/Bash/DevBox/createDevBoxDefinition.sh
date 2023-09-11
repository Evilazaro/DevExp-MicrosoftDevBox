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

# Creating the DevBox Definition
echo "Creating DevBox Definition..."
az devcenter admin devbox-definition create --location "$location" \
    --image-reference id="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DevCenter/devcenters/$devCenterName/galleries/$galleryName/images/$imageName/version/latest" \
    --os-storage-type "ssd_1024gb" \
    --sku name="general_a_8c32gb_v1" \
    --name "WebDevBox" \
    --dev-center-name "$devCenterName" \
    --resource-group "$resourceGroupName" \
    --devbox-definition-name "devBox-$imageName-definition"

# Echoing the completion message
echo "DevBox Definition creation completed successfully."

