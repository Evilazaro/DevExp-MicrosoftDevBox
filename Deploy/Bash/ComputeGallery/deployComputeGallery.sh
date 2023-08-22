#!/bin/bash

# Exit on any error to ensure the script stops if there's a problem
set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <galleryResourceGroup> <location> <imageGalleryName>"
    exit 1
fi

# Assign input arguments to descriptive variable names
galleryResourceGroup="$1"
location="$2"
imageGalleryName="$3"

# Define the template file URL and the output file name for clarity
galleryTemplateURL="https://github.com/Evilazaro/MicrosoftDevBox/blob/main/Deploy/ARMTemplates/Compute-Gallery-Template.json"
outputFilePath="././DownloadedFiles/Create-Gallery-Template-Output.json"

# Notify the user that the template is being downloaded
echo "Downloading template file from: $galleryTemplateURL"

# Download the template file using curl
curl "$galleryTemplateURL" -o "$outputFilePath"

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    echo "Error downloading the template file!"
    exit 1
fi

# Notify the user that the resource is about to be created in Azure
echo "Creating resource in Azure with the provided details..."

az deployment group create \
    --name $imageGalleryName \
    --template-file "$outputFilePath" \
    --resource-group "$galleryResourceGroup" \
    --parameters \
        '<imageGalleryName>'="$imageGalleryName" \
        '<location>'="$location"

# Check if the Azure CLI command succeeded
if [ $? -ne 0 ]; then
    echo "Error creating the resource in Azure!"
    exit 1
fi

# Notify the user that the entire operation has been completed
echo "Operation completed successfully!"
