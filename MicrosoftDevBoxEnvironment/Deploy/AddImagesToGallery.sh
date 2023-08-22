#!/bin/bash

imageGalleryName=$1
imageName=$2
location=$3
sku=$4
devBoxResourceGroupName=$5
imageResourceGroupName=$6
subscriptionId=$7

galleryTemplateFile=https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/MicrosoftDevBoxEnvironment/Deploy/Add-Images-To-Gallery-Template.json
outputFile=./DownloadedFiles/Add-Images-To-Gallery-Template-Output.json

az deployment group create --resource-group $resourceGroup --template-file $outputFile  \
    --parameters \
        imageGalleryName=$imageGalleryName \
        imageName=$imageName \
        location=$location \
        sku=$sku \
        imageResourceGroupName=$imageResourceGroupName \
        subscriptionId=$subscriptionId

echo "Image added to gallery successfully!"
