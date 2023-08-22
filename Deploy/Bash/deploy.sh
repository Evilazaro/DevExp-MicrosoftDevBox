#!/bin/bash

# This script automates various Azure tasks like resource group creation, image creation, and deployment.

# Function to display headers in a consistent format
display_header() {
    echo
    echo "========================"
    echo "$1"
    echo "========================"
}

# Logging into Azure.
display_header "Logging into Azure"
./Identity/login.sh "$1"

# Setting up initial variables for the process.
display_header "Setting Up Variables"

# Defining the resource group name.
imageResourceGroup='Contoso-Base-Images-Engineers-rg'

# Defining the Azure region where resources will be deployed.
location='WestUS3'

# Defining the identity name for the image builder.
identityName='contosoIdentityIBuilderUserDevBox'

# Fetching the subscription ID for the logged-in account.
subscriptionID=$(az account show --query id --output tsv)

# Creating the resource group in the defined location.
echo "Creating resource group: $imageResourceGroup in location: $location..."
az group create -n "$imageResourceGroup" -l "$location"

# Creating a new managed identity within the resource group.
echo "Creating managed identity: $identityName..."
az identity create --resource-group "$imageResourceGroup" -n "$identityName"

# Fetching the principal ID of the newly created managed identity.
identityId=$(az identity show --resource-group "$imageResourceGroup" -n "$identityName" --query principalId --output tsv)

# Displaying the set variables for user confirmation.
display_header "Configuration Summary"
echo "Image Resource Group: $imageResourceGroup"
echo "Location: $location"
echo "Subscription ID: $subscriptionID"
echo "Identity Name: $identityName"
echo "Identity ID: $identityId"
echo "=========================="

# Registering necessary Azure features.
echo "Registering necessary features..."
./Identity/registerFeatures.sh

# Creating a user-assigned managed identity.
echo "Creating user-assigned managed identity..."
./Identity/createUserAssignedManagedIdentity.sh "$imageResourceGroup" "$subscriptionID" "$identityId"

# Function for creating images - to reduce redundancy.
build_image() {
    local imageName=$1
    local imageTemplateURL=$2
    local outputFilePath=$3

    display_header "Creating Image: $imageName"
    echo "Image Template URL: $imageTemplateURL"
    echo "Output File: $outputFilePath"
    echo

    #./VMImages/buildVMImage.sh "$outputFilePath" "$subscriptionID" "$imageResourceGroup" "$location" "$imageName" "$identityName" "$imageTemplateURL"
}

# Creating images for both front-end and back-end engineers.
build_image 'Win11EntBaseImageFrontEndEngineers' 'https://github.com/Evilazaro/MicrosoftDevBox/blob/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-FrontEnd-Template.json' '././DownloadedFiles/Win11-Ent-Base-Image-FrontEnd-Template-Output.json'
build_image 'Win11EntBaseImageBackEndEngineers' 'https://github.com/Evilazaro/MicrosoftDevBox/blob/main/Deploy/ARMTemplates/Win11-Ent-Base-Image-BackEnd-Template.json' '././DownloadedFiles/Win11-Ent-Base-Image-BackEnd-Template-Output.json'

# Deploying Microsoft DevBox
display_header "Deploying Microsoft DevBox"
./DevBox/deployDevBox.sh "$subscriptionID" "$location" 'Win11EntBaseImageFrontEndEngineers' 'Win11EntBaseImageBackEndEngineers' "$imageResourceGroup"