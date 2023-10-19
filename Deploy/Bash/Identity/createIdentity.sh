#!/bin/bash

# This script creates an identity on Microsoft Azure.
# It expects three parameters in the exact order:
# 1. Resource Group Name
# 2. Location
# 3. Identity Name

# Function to display usage information
displayUsage() {
    echo "Usage: $0 <resourceGroupName> <location> <identityName>"
    echo "Example: $0 myResourceGroup EastUS myIdentity"
    exit 1
}

# Check for the correct number of arguments. If incorrect, display usage.
checkArguments() {
    if [ "$#" -ne 3 ]; then
        echo "Error: Invalid number of arguments."
        displayUsage
    fi
}

# Assign passed arguments to variables and display them.
assignArguments() {
    resourceGroupName="$1"
    echo "Resource Group Name: ${resourceGroupName}"

    location="$2"
    echo "Location: ${location}"

    identityName="$3"
    echo "Identity Name: ${identityName}"
}

# Create an identity on Azure.
createAzureIdentity() {
    echo "Creating identity '${identityName}' in resource group '${resourceGroupName}' located in '${location}'..."

    output=$(az identity create \
        --resource-group "${resourceGroupName}" \
        --name "${identityName}" \
        --location "${location}" 2>&1)
}

# Check the result of the identity creation and display appropriate messages.
checkCreationResult() {
    if [ "$?" -eq 0 ]; then
        echo "Identity '${identityName}' successfully created."
    else
        echo "Error occurred while creating identity '${identityName}': ${output}"
        exit 1
    fi
}

# Main execution starts here
checkArguments "$@"
assignArguments "$@"
createAzureIdentity
checkCreationResult
