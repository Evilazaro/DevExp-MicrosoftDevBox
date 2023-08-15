#!/bin/bash

# This script logs into Azure, sets up resource groups, and creates images using given templates.

# Initiating the Azure login process.
echo "Logging into Azure..."
./login.sh $1

# Setting up initial variables for the process.
echo "-----------------"
echo "Setting Variables"
echo "-----------------"

# Define the resource group name.
imageResourceGroup='Contoso-Base-Images-Engineers-rg'

# Define the Azure region where resources will be deployed.
location='WestUS3'

# Define the identity name for the image builder.
identityName=contosoIdentityIBuilderUserDevBox

# Fetching the subscription ID for the logged-in account.
subscriptionID=$(az account show --query id --output tsv)

# Creating the resource group in the defined location.
echo "Creating resource group: $imageResourceGroup in location: $location..."
az group create -n $imageResourceGroup -l $location

# Creating a new managed identity within the resource group.
echo "Creating managed identity: $identityName..."
az identity create --resource-group $imageResourceGroup -n $identityName

# Fetching the principal ID of the newly created managed identity.
identityId=$(az identity show --resource-group $imageResourceGroup -n $identityName --query principalId --output tsv)

# Displaying the set variables for the user.
echo "-----------------"
echo "imageResourceGroup: $imageResourceGroup"
echo "location: $location"
echo "Subscription ID: $subscriptionID"
echo "Identity Name: $identityName"
echo "Identity ID: $identityId"
echo "-----------------"

# Registering necessary Azure features.
echo "Registering necessary features..."
./Register-Features.sh

# Creating a user-assigned managed identity.
echo "Creating user-assigned managed identity..."
./CreateUserAssignedManagedIdentity.sh $imageResourceGroup $subscriptionID $identityId

# Preparing for the front-end image creation.
echo "-----------------"
imageName='Win11EntBaseImageFrontEndEngineers'
echo "Creating Image: $imageName"
imageTemplateFile=https://raw.githubusercontent.com/Evilazaro/DigitalAppInnovation-Demos/main/DevOps/Continuous-Operations/DevBox/Deploy/Win11-Ent-Base-Image-FrontEnd-Template.json
outputFile='./DownloadedFiles/Win11-Ent-Base-Image-FrontEnd-Template-Output.json'
echo "imageTemplateFile: $imageTemplateFile"
echo "outputFile: $outputFile"

# Initiating the image creation process.
./CreateImage.sh $outputFile $subscriptionID $imageResourceGroup $location $imageName $identityName $imageTemplateFile


# Preparing for the back-end image creation.
echo "-----------------"
imageName='Win11EntBaseImageBackEndEngineers'
echo "Creating Image: $imageName"
imageTemplateFile=https://raw.githubusercontent.com/Evilazaro/DigitalAppInnovation-Demos/main/DevOps/Continuous-Operations/DevBox/Deploy/Win11-Ent-Base-Image-BackEnd-Template.json
outputFile='./DownloadedFiles/Win11-Ent-Base-Image-BackEnd-Template-Output.json'
echo "imageTemplateFile: $imageTemplateFile"
echo "outputFile: $outputFile"

# Initiating the back-end image creation process.
./CreateImage.sh $outputFile $subscriptionID $imageResourceGroup $location $imageName $identityName $imageTemplateFile

# Deploy Microsoft DevBox
./Deploy-DevBox.sh $subscriptionID $imageResourceGroup $location $imageName $identityName
