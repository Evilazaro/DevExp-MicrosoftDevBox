#!/bin/bash

set -e

validateNumberOfArguments() {
    if [ "$#" -ne 9 ]; then
        echo "Usage: $0 <devCenterName> <networkConnectionName> <imageGalleryName> <location> <identityName> <devBoxResourceGroupName> <networkResourceGroupName> <identityResourceGroupName> <imageGalleryResourceGroupName>"
        exit 1
    fi
}

assignArgumentsToVariables() {
    devCenterName="$1"
    networkConnectionName="$2"
    imageGalleryName="$3"
    location="$4"
    identityName="$5"
    devBoxResourceGroupName="$6"
    networkResourceGroupName="$7"
    identityResourceGroupName="$8"
    imageGalleryResourceGroupName="$9"
}

displayDeploymentParameters() {
    echo "Starting to deploy Dev Center with the following parameters:"
    echo "Dev Center Name: $devCenterName"
    echo "Network Connection Name: $networkConnectionName"
    echo "Image Gallery Name: $imageGalleryName"
    echo "Location: $location"
    echo "Identity Name: $identityName"
    echo "DevBox Resource Group Name: $devBoxResourceGroupName"
    echo "Network Resource Group Name: $networkResourceGroupName"
    echo "Identity Resource Group Name: $identityResourceGroupName"
    echo "Image Gallery Resource Group Name: $imageGalleryResourceGroupName"
}

fetchNetworkConnectionId() {
    echo "Fetching network connection id..."
    networkConnectionId=$(az devcenter admin network-connection list --resource-group $networkResourceGroupName --query [0].id --output tsv)
}

fetchComputeGalleryId() {
    echo "Fetching compute gallery id..."
    computeGalleryId=$(az sig show --resource-group $imageGalleryResourceGroupName --gallery-name $imageGalleryName --query id --output tsv)
}

fetchUserIdentityId() {
    echo "Fetching user identity id..."
    userIdentityId=$(az identity show --resource-group $identityResourceGroupName --name $identityName --query id --output tsv)
}

createDeploymentGroup() {
    echo "Creating deployment group..."
    az deployment group create \
        --name "$devCenterName" \
        --resource-group "$devBoxResourceGroupName" \
        --template-uri $templateFileUri \
        --parameters \
            devCenterName="$devCenterName" \
            networkConnectionId="$networkConnectionId" \
            computeGalleryId="$computeGalleryId" \
            location="$location" \
            networkConnectionName="$networkConnectionName" \
            userIdentityId="$userIdentityId" \
            computeGalleryImageName="$imageGalleryName"

    echo "Deployment of Dev Center is complete."
}

# Main script execution starts here
validateNumberOfArguments "$@"
assignArgumentsToVariables "$@"
displayDeploymentParameters

# Constants
branch="main"
templateFileUri="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/Deploy/ARMTemplates/devBox/devCenterTemplate.json"

fetchNetworkConnectionId
fetchComputeGalleryId
fetchUserIdentityId
createDeploymentGroup
