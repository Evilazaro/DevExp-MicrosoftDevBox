#!/bin/bash

# Exit immediately if a command exits with a non-zero status, and treat unset variables as an error.
set -euo pipefail

function displayUsage() {
    echo "Usage: $0 <computeGalleryName> <location> <galleryResourceGroupName>"
}

function validateArgs() {
    if [ "$#" -ne 3 ]; then
        displayUsage
        exit 1
    fi
}

function assignArgumentsToVariables() {
    computeGalleryName="$1"
    location="$2"
    galleryResourceGroupName="$3"
}

function informUserAboutInitialization() {
    echo "Initializing the creation of a Shared Image Gallery named '$computeGalleryName' in resource group '$galleryResourceGroupName' located in '$location'."
}

function executeAzureCommand() {
    echo "Executing Azure CLI command to create the Shared Image Gallery..."
    az sig create \
        --gallery-name "$computeGalleryName" \
        --resource-group "$galleryResourceGroupName" \
        --location "$location" \
        --tags  "division=Pet-Platform" \
                "Environment=Prod" \
                "offer=Pet-DevWorkstation-Service" \
                "Team=Engineering" \
                "solution=ContosoFabricDevWorkstation" \
                "businessUnit=e-Commerce"
}

function confirmCreation() {
    echo "Shared Image Gallery '$computeGalleryName' successfully created in resource group '$galleryResourceGroupName' located in '$location'."
}

function main() {
    validateArgs "$@"
    assignArgumentsToVariables "$@"
    informUserAboutInitialization
    executeAzureCommand
    confirmCreation
}

main "$@"
