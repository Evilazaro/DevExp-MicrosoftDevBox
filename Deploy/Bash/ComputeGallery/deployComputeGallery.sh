#!/bin/bash

# Exit on any error to ensure the script stops if there's a problem
set -e

# Check if the correct number of arguments are provided
if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 <galleryName> <location> <galleryResourceGroup>"
    exit 1
fi

# Assign input arguments to descriptive variable names
galleryName="$1"
location="$2"
galleryResourceGroup="$3"

# Define the template file URL and the output file name for clarity
galleryTemplateURL="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Compute-Gallery-Template.json"
outputFilePath="./DownloadedTempTemplates/Compute-Gallery-Template-Output.json"

# Notify the user that the template is being downloaded
echo "Downloading template file from: $galleryTemplateURL"

# Download the template file 
if ! wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" "$galleryTemplateURL" -O "$outputFilePath"; then
    echo "Error downloading the template file!"
    exit 1
fi

# Replace placeholders with provided values in the downloaded template
sed -i -e "s%<galleryName>%$galleryName%g" "$outputFilePath"
sed -i -e "s%<location>%$location%g" "$outputFilePath"

# Notify the user that the resource is about to be created in Azure
echo "Creating resource in Azure with the provided details..."

# Create resource in Azure
if ! az deployment group create \
    --name "$galleryName" \
    --template-file "$outputFilePath" \
    --resource-group "$galleryResourceGroup"; then
    echo "Error creating the resource in Azure!"
    exit 1
fi

# Notify the user that the entire operation has been completed
echo "Operation completed successfully!"
