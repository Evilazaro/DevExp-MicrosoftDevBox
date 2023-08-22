#!/bin/bash

# This script automates various Azure tasks like resource group creation, image creation, and deployment.

# Start: Logging into Azure.
echo "========================"
echo "Logging into Azure..."
echo "========================"
./login.sh "$1"

# Setting up initial variables for the process.
echo
echo "========================"
echo "Setting Up Variables..."
echo "========================"

# Defining the resource group name.
imageResourceGroup='Contoso-Base-Images-Engineers-rg'

# Defining the Azure region where resources will be deployed.
location='WestUS3'

# Defining the identity name for the image builder.
identityName='contosoIdentityIBuilderUserDevBox'

# Fetching the subscription ID for the logged-in account.
subscriptionID=$(az account show --query id --output tsv)

# Creating the resource group in the defined location.
echo
echo "Creating resource group: $imageResourceGroup in location: $location..."
az group create -n "$imageResourceGroup" -l "$location"

# Creating a new managed identity within the resource group.
echo "Creating managed identity: $identityName..."
az identity create --resource-group "$imageResourceGroup" -n "$identityName"

# Fetching the principal ID of the newly created managed identity.
identityId=$(az identity show --resource-group "$imageResourceGroup" -n "$identityName" --query principalId --output tsv)

# Displaying the set variables for user confirmation.
echo
echo "=========================="
echo "Configuration Summary:"
echo "=========================="
echo "Image Resource Group: $imageResourceGroup"
echo "Location: $location"
echo "Subscription ID: $subscriptionID"
echo "Identity Name: $identityName"
echo "Identity ID: $identityId"
echo "=========================="

# Registering necessary Azure features.
echo "Registering necessary features..."
./Register-Features.sh

# Creating a user-assigned managed identity.
echo "Creating user-assigned managed identity..."
./CreateUserAssignedManagedIdentity.sh "$imageResourceGroup" "$subscriptionID" "$identityId"

# Function for creating images - to reduce redundancy.
create_image() {
    local imageName=$1
    local imageTemplateURL=$2
    local outputFilePath=$3

    echo
    echo "==============================="
    echo "Creating Image: $imageName"
    echo "==============================="
    echo "Image Template URL: $imageTemplateURL"
    echo "Output File: $outputFilePath"
    echo

    ./CreateImage.sh "$outputFilePath" "$subscriptionID" "$imageResourceGroup" "$location" "$imageName" "$identityName" "$imageTemplateURL"
}

# Creating images for both front-end and back-end engineers.
create_image 'Win11EntBaseImageFrontEndEngineers' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/MicrosoftDevBoxEnvironment/Deploy/Win11-Ent-Base-Image-FrontEnd-Template.json' './DownloadedFiles/Win11-Ent-Base-Image-FrontEnd-Template-Output.json'
create_image 'Win11EntBaseImageBackEndEngineers' 'https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/main/MicrosoftDevBoxEnvironment/Deploy/Win11-Ent-Base-Image-BackEnd-Template.json' './DownloadedFiles/Win11-Ent-Base-Image-BackEnd-Template-Output.json'

# Deploy Microsoft DevBox
echo "Deploying Microsoft DevBox..."
./DeployAzureDevBox.sh "$subscriptionID" "$imageResourceGroup" "$location" 'Win11EntBaseImageFrontEndEngineers' 'Win11EntBaseImageBackEndEngineers'
