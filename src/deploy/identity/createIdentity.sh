#!/bin/bash

# Function to display usage information
displayUsage() {
    echo "Usage: $0 <resourceGroupName> <location> <identityName>"
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

# Function to assign arguments to variables
assignArguments() {
    resourceGroupName="$1"
    location="$2"
    identityName="$3"

    echo "Resource Group Name: ${resourceGroupName}"
    echo "Location: ${location}"
    echo "Identity Name: ${identityName}"
}

# Function to create an Azure identity
createAzureIdentity() {
    echo "Creating identity '${identityName}' in resource group '${resourceGroupName}' located in '${location}'..."

    # Capture the output and error message
    if output=$(az identity create --resource-group "${resourceGroupName}" --name "${identityName}" --location "${location}" 2>&1); then
        echo "Identity '${identityName}' successfully created."
    else
        echo "Error occurred while creating identity '${identityName}': ${output}"
        exit 1
    fi
}

# Main script execution
createIdentity() {
    checkArguments "$@"
    assignArguments "$@"
    createAzureIdentity
}

# Execute the main function with all script arguments
createIdentity "$@"