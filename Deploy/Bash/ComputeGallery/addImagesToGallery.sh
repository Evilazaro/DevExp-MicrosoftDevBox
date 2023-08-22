#!/bin/bash

# Ensure the script stops on any error
set -e

# Check if the necessary number of arguments are provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <imageGalleryName> <imageName> <location> <sku> <devBoxResourceGroupName> <imageResourceGroupName> <subscriptionId>"
    exit 1
fi

# Capture input arguments
imageGalleryName=$1
imageName=$2
location=$3
sku=$4
devBoxResourceGroupName=$5
imageResourceGroupName=$6
subscriptionId=$7

# Define URLs and paths
galleryTemplateFile="https://github.com/Evilazaro/MicrosoftDevBox/blob/main/Deploy/ARMTemplates/Add-Images-To-Gallery-Template.json"
outputFile="./DownloadedFiles/Add-Images-To-Gallery-Template-Output.json"

echo "Starting deployment to add image to gallery..."

# Download the template file (if necessary)
echo "Checking and downloading the template file..."
[ -f "$outputFile" ] || curl -L $galleryTemplateFile -o $outputFile

# Create deployment with Azure CLI
echo "Deploying the image to the gallery..."
az deployment group create --resource-group $devBoxResourceGroupName --template-file $outputFile \
    --parameters \
        imageGalleryName=$imageGalleryName \
        imageName=$imageName \
        location=$location \
        sku=$sku \
        imageResourceGroupName=$imageResourceGroupName \
        subscriptionId=$subscriptionId

# Inform user of successful execution
echo "Image added to gallery successfully!"
