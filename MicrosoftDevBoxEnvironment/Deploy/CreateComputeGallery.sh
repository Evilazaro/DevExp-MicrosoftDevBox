#!/bin/bash

# Assign input arguments to variables
galleryResourceGroup=$1
location=$2

# Define the template file URL and the output file name
galleryTemplateFile=https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/MicrosoftDevBoxEnvironment/Deploy/Compute-Gallery-Template.json
outputFile=./DownloadedFiles/Create-Gallery-Template-Output.json

# Notify the user that the template is being downloaded
echo "Downloading template file from: $galleryTemplateFile"

# Download the template file
curl $galleryTemplateFile -o $outputFile

# Notify the user that placeholders in the template are being replaced
echo "Replacing placeholders in the template with provided values..."

# Replace <resourceGroup> with the provided resource group name
sed -i -e "s%<resourceGroup>%$galleryResourceGroup%g" $outputFile

# Replace <Location> with the provided location value
sed -i -e "s%<Location>%$location%g" $outputFile

# Notify the user that the resource is being created in Azure
echo "Creating resource in Azure with the provided information..."

# Create the resource in Azure using the Azure CLI
az resource create \
    --resource-group $galleryResourceGroup \
    --properties @$outputFile \
    --is-full-object \
    --resource-type Microsoft.Compute/galleries \
    -n Contoso-Gallery

# Notify the user that the operation has been completed
echo "Operation completed!"