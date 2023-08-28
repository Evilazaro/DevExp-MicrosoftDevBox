#!/bin/bash

# This script automates various Azure tasks like resource group creation, image creation, and deployment.

display_header() {
    echo
    echo "========================"
    echo "$1"
    echo "========================"
}

build_image() {
    local outputFile="$1"
    local subscriptionID="$2"
    local galleryResourceGroup="$3"
    local location="$4"
    local imageName="$5"
    local identityName="$6"
    local imageTemplateFile="$7"
    local galleryName="$8"
    local offer="$9"
    local imgSKU="${10}"
    local publisher="${11}"

    display_header "Creating Image: $imageName"
    echo "Image Template URL: $imageTemplateFile"
    echo "Output File: $outputFile"
    echo "Subscription ID: $subscriptionID"
    echo "Gallery Resource Group: $galleryResourceGroup"
    echo "Location: $location"
    echo "Image Name: $imageName"
    echo "Identity Name: $identityName"
    echo "Gallery Name: $galleryName"
    echo "Offer: $offer"
    echo "SKU: $imgSKU"
    echo "Publisher: $publisher"
    echo

    VMImages/buildVMImage.sh "$outputFile" "$subscriptionID" "$galleryResourceGroup" "$location" "$imageName" "$identityName" "$imageTemplateFile" "$galleryName" "$offer" "$imgSKU" "$publisher"
}

display_header "Logging into Azure"
./Identity/login.sh "$1"

display_header "Setting Up Variables"
galleryResourceGroup='Contoso-Base-Images-Engineers-rg'
location='WestUS3'
identityName='contosoIdentityIBuilderUserDevBox'
subscriptionID=$(az account show --query id --output tsv)

echo "Creating resource group: $galleryResourceGroup in location: $location..."
az group create -n "$galleryResourceGroup" -l "$location"

echo "Creating managed identity: $identityName..."
az identity create --resource-group "$galleryResourceGroup" -n "$identityName"
identityId=$(az identity show --resource-group "$galleryResourceGroup" -n "$identityName" --query principalId --output tsv)

display_header "Configuration Summary"
echo "Image Resource Group: $galleryResourceGroup"
echo "Location: $location"
echo "Subscription ID: $subscriptionID"
echo "Identity Name: $identityName"
echo "Identity ID: $identityId"
echo "=========================="

echo "Registering necessary features..."
./Identity/registerFeatures.sh

echo "Creating user-assigned managed identity..."
./Identity/createUserAssignedManagedIdentity.sh "$galleryResourceGroup" "$subscriptionID" "$identityId"

echo "Starting the process..."
echo "Deploying Compute Gallery ${galleryName}..."
galleryName="ContosoImageGallery"
./ComputeGallery/deployComputeGallery.sh "$galleryName" "$location" "$galleryResourceGroup"

imagesku='base-win11-gen2'
publisher='microsoftvisualstudio'
offer='windowsplustools'
build_image './DownloadedTempTemplates/Win11-Ent-Base-Image-FrontEnd-Template-Output.json' "$subscriptionID" "$galleryResourceGroup" "$location" 'Win11EntBaseImageFrontEndEngineers' 'contosoIdentityIBuilderUserDevBox' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-FrontEnd-Template.json' "$galleryName" "$offer" "$imagesku" "$publisher" 

# imagesku='vs-2022-ent-general-win11-m365-gen2'
# publisher='microsoftvisualstudio'
# offer='visualstudioplustools'
# build_image './DownloadedTempTemplates/Win11-Ent-Base-Image-BackEnd-Template-Output.json' "$subscriptionID" "$galleryResourceGroup" "$location" 'Win11EntBaseImageBackEndEngineers' 'contosoIdentityIBuilderUserDevBox' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Template.json' "$galleryName" "$offer" "$imagesku" "$publisher"

display_header "Deploying Microsoft DevBox"
# Uncomment the line below once you have the correct parameters for deployment
./DevBox/deployDevBox.sh "$subscriptionID" "$location" 'Win11EntBaseImageFrontEndEngineers' 'Win11EntBaseImageBackEndEngineers' "$galleryResourceGroup"
