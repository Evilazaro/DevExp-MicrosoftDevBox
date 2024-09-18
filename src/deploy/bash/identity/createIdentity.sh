#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Function to display usage information
displayUsage() {
    echo "Usage: $0 <identityResourceGroupName> <location> <identityName>"
    echo "Example: $0 myResourceGroup EastUS myIdentity"
    exit 1
}

# Function to check for the correct number of arguments
checkArguments() {
    if [ "$#" -ne 3 ]; then
        echo "Error: Invalid number of arguments."
        displayUsage
    fi
}

# Function to create an Azure identity
createAzureIdentity() {
    local identityResourceGroupName="$1"
    local location="$2"
    local identityName="$3"

    echo "Creating identity '${identityName}' in resource group '${identityResourceGroupName}' located in '${location}'..."

    # Capture the output and error message
    if output=$(az identity create --resource-group "${identityResourceGroupName}" --name "${identityName}" --location "${location}" 2>&1); then
        echo "Identity '${identityName}' successfully created."
    else
        echo "Error occurred while creating identity '${identityName}': ${output}"
        exit 1
    fi
}

# Main script execution
main() {
    checkArguments "$@"
    createAzureIdentity "$@"
}

# Execute the main function with all script arguments
main "$@"