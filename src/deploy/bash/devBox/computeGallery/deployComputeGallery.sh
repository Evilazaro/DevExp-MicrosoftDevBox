#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Display usage information
displayUsage() {
    echo "Usage: $0 <imageGalleryName> <location> <imageGalleryResourceGroupName>"
}

# Validate the number of arguments
validateArgs() {
    if [ "$#" -ne 3 ]; then
        displayUsage
        exit 1
    fi
}

# Assign command-line arguments to variables
assignArgumentsToVariables() {
    imageGalleryName="$1"
    location="$2"
    imageGalleryResourceGroupName="$3"
}

# Inform the user about the initialization process
informUserAboutInitialization() {
    echo "Initializing the creation of a Shared Image Gallery named '$imageGalleryName' in resource group '$imageGalleryResourceGroupName' located in '$location'."
}

# Confirm the creation of the Shared Image Gallery
confirmCreation() {
    echo "Shared Image Gallery '$imageGalleryName' successfully created in resource group '$imageGalleryResourceGroupName' located in '$location'."
}

# Main function to orchestrate the script execution
deployComputeGallery() {
    validateArgs "$@"
    assignArgumentsToVariables "$@"
    informUserAboutInitialization
    
    echo "Executing Azure CLI command to create the Shared Image Gallery..."
    az sig create \
        --gallery-name "$imageGalleryName" \
        --resource-group "$imageGalleryResourceGroupName" \
        --location "$location" \
        --tags  "division=petv2-Platform" \
                "Environment=Prod" \
                "offer=petv2-DevWorkstation-Service" \
                "Team=Engineering" \
                "solution=ContosoFabricDevWorkstation" \
                "businessUnit=e-Commerce"
    
    # Check the status of the last command
    if [ $? -eq 0 ]; then
        echo "Azure CLI command executed successfully."
    else
        echo "Error: Azure CLI command failed."
        exit 1
    fi

    confirmCreation
}

# Execute the main function with all command-line arguments
deployComputeGallery "$@"