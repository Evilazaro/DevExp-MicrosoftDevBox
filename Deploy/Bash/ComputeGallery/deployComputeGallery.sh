#!/bin/bash

# Exit on any error to ensure the script stops if there's a problem
set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <galleryResourceGroup> <location> <galleryName> <frontEndImageName> <backEndImageName> <subscriptionId>"
    exit 1
fi

# Assign input arguments to descriptive variable names
galleryResourceGroup="$1"
location="$2"
galleryName="$3"
frontEndImageName="$4"
backEndImageName="$5"
subscriptionId="$6"
imageResourceGroupName="$7"


# Define the template file URL and the output file name for clarity
galleryTemplateURL="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Compute-Gallery-Template.json"
outputFilePath="././DownloadedTempTemplates/Compute-Gallery-Template-Output.json"

# Notify the user that the template is being downloaded
echo "Downloading template file from: $galleryTemplateURL"

# Download the template file using wget --header="Cache-Control: no-cache" --header="Pragma: no-cache" 
wget --header="Cache-Control: no-cache" --header="Pragma: no-cache"  $galleryTemplateURL -O $outputFilePath

sed -i -e "s%<galleryName>%$galleryName%g" "$outputFilePath"
sed -i -e "s%<location>%$location%g" "$outputFilePath"
sed -i -e "s%<frontEndImageName>%$frontEndImageName%g" "$outputFilePath"
sed -i -e "s%<backEndImageName>%$backEndImageName%g" "$outputFilePath"
sed -i -e "s%<subscriptionId>%$subscriptionId%g" "$outputFilePath"
sed -i -e "s%<resourceGroupName>%$imageResourceGroupName%g" "$outputFilePath"

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    echo "Error downloading the template file!"
    exit 1
fi

# Notify the user that the resource is about to be created in Azure
echo "Creating resource in Azure with the provided details..."

az deployment group create \
    --name $galleryName \
    --template-file "$outputFilePath" \
    --resource-group "$galleryResourceGroup" 

# Check if the Azure CLI command succeeded
if [ $? -ne 0 ]; then
    echo "Error creating the resource in Azure!"
    exit 1
fi

# Notify the user that the entire operation has been completed
echo "Operation completed successfully!"
