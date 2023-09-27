#!/bin/bash
# This script creates an identity on Microsoft Azure.
# It expects three parameters in the exact order:
# 1. Resource Group Name
# 2. Location
# 3. Identity Name

# Function to display usage information
function usage() {
    echo "Usage: $0 <resourceGroupName> <location> <identityName>"
    echo "Example: $0 myResourceGroup EastUS myIdentity"
    exit 1
}

# Check if the correct number of arguments is provided, if not, display usage information and exit.
if [ "$#" -ne 3 ]; then
    echo "Error: Invalid number of arguments."
    usage
fi

# Assigning passed arguments to variables and echoing the assignments.
resourceGroupName="$1"
echo "Resource Group Name: ${resourceGroupName}"

location="$2"
echo "Location: ${location}"

identityName="$3"
echo "Identity Name: ${identityName}"

# Informing the user about the identity creation step
echo "Creating identity '${identityName}' in resource group '${resourceGroupName}' located in '${location}'..."

# Executing the Azure CLI command to create an identity and storing the output in a variable.
output=$(az identity create \
    --resource-group "${resourceGroupName}" \
    --name "${identityName}" \
    --location "${location}" 2>&1)

# Checking the exit status of the last command executed and echoing appropriate messages.
if [ "$?" -eq 0 ]; then
    echo "Identity '${identityName}' successfully created."
else
    echo "Error occurred while creating identity '${identityName}': ${output}"
    exit 1
fi
