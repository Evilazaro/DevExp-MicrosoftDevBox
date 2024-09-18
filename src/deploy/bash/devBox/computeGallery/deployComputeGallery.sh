#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Display usage information
function displayUsage() {
    echo "Usage: $0 <computeGalleryName> <location> <galleryResourceGroupName>"
}

# Validate the number of arguments
function validateArgs() {
    if [ "$#" -ne 3 ]; then
        displayUsage
        exit 1
    fi
}

# Assign command-line arguments to variables
function assignArgumentsToVariables() {
    computeGalleryName="$1"
    location="$2"
    galleryResourceGroupName="$3"
}

# Inform the user about the initialization process
function informUserAboutInitialization() {
    echo "Initializing the creation of a Shared Image Gallery named '$computeGalleryName' in resource group '$galleryResourceGroupName' located in '$location'."
}

# Execute the Azure CLI command to create the Shared Image Gallery
function executeAzureCommand() {
    echo "Executing Azure CLI command to create the Shared Image Gallery..."
    az sig create \
        --gallery-name "$computeGalleryName" \
        --resource-group "$galleryResourceGroupName" \
        --location "$location" \
        --tags  "division=petv2-Platform" \
                "Environment=Prod" \
                "offer=petv2-DevWorkstation-Service" \
                "Team=Engineering" \
                "solution=ContosoFabricDevWorkstation" \
                "businessUnit=e-Commerce"
}

# Confirm the creation of the Shared Image Gallery
function confirmCreation() {
    echo "Shared Image Gallery '$computeGalleryName' successfully created in resource group '$galleryResourceGroupName' located in '$location'."
}

# Main function to orchestrate the script execution
function main() {
    validateArgs "$@"
    assignArgumentsToVariables "$@"
    informUserAboutInitialization
    executeAzureCommand
    confirmCreation
}

# Execute the main function with all command-line arguments
main "$@"