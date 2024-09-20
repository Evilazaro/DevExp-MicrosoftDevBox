#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Constants
readonly branch="main"
readonly templateFileUri="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$branch/src/deploy//ARMTemplates/devBox/devCentertemplate.json"

# Display usage information
displayUsage() {
    echo "Usage: $0 <devCenterName> <networkConnectionName> <imageGalleryName> <location> <identityName> <devBoxResourceGroupName> <networkResourceGroupName> <identityResourceGroupName> <imageGalleryResourceGroupName>"
}

# Validate the number of arguments
validateNumberOfArguments() {
    if [ "$#" -ne 9 ]; then
        displayUsage
        exit 1
    fi
}

# Assign command-line arguments to variables
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

# Display deployment parameters
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

# Fetch the network connection ID
fetchNetworkConnectionId() {
    echo "Fetching network connection ID..."
    networkConnectionId=$(az devcenter admin network-connection list --resource-group "$networkResourceGroupName" --query [0].id --output tsv)
    if [ -z "$networkConnectionId" ]; then
        echo "Error: Unable to fetch network connection ID."
        exit 1
    fi
}

# Fetch the compute gallery ID
fetchComputeGalleryId() {
    echo "Fetching compute gallery ID..."
    computeGalleryId=$(az sig show --resource-group "$imageGalleryResourceGroupName" --gallery-name "$imageGalleryName" --query id --output tsv)
    if [ -z "$computeGalleryId" ]; then
        echo "Error: Unable to fetch compute gallery ID."
        exit 1
    fi
}

# Fetch the user identity ID
fetchUserIdentityId() {
    echo "Fetching user identity ID..."
    userIdentityId=$(az identity show --resource-group "$identityResourceGroupName" --name "$identityName" --query id --output tsv)
    if [ -z "$userIdentityId" ]; then
        echo "Error: Unable to fetch user identity ID."
        exit 1
    fi
}

# Create the deployment group
createDeploymentGroup() {
    echo "Creating deployment group..."
    az deployment group create \
        --name "$devCenterName" \
        --resource-group "$devBoxResourceGroupName" \
        --template-uri "$templateFileUri" \
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
deployDevCenter() {
    validateNumberOfArguments "$@"
    assignArgumentsToVariables "$@"
    displayDeploymentParameters
    fetchNetworkConnectionId
    fetchComputeGalleryId
    fetchUserIdentityId
    createDeploymentGroup
}

deployDevCenter "$@"