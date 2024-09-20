#!/bin/bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and propagate errors in pipelines.
set -euo pipefail

# Function to display usage instructions
showUsage() {
    echo "Usage: $0 <location> <devBoxDefinitionName> <networkConnectionName> <poolName> <projectName> <devBoxResourceGroupName>"
}

# Validate the number of arguments passed to the script
validateArguments() {
    if [ "$#" -ne 6 ]; then
        echo "Error: Incorrect number of arguments"
        showUsage
        exit 1
    fi
}

# Assign arguments to camelCase variables with meaningful names
assignArguments() {
    location="$1"
    devBoxDefinitionName="$2"
    networkConnectionName="$3"
    poolName="$4"
    projectName="$5"
    devBoxResourceGroupName="$6"
}

# Function to create a DevCenter admin pool
createDevCenterAdminPool() {
    echo "Creating DevCenter admin pool with the following parameters:"
    echo "Location: $location"
    echo "DevBox Definition Name: $devBoxDefinitionName"
    echo "Network Connection Name: $networkConnectionName"
    echo "Pool Name: $poolName"
    echo "Project Name: $projectName"
    echo "Resource Group: $devBoxResourceGroupName"
    
    az devcenter admin pool create \
        --location "$location" \
        --devbox-definition-name "$devBoxDefinitionName" \
        --network-connection-name "$networkConnectionName" \
        --pool-name "$poolName" \
        --project-name "$projectName" \
        --resource-group "$devBoxResourceGroupName" \
        --local-administrator "Enabled" \
        --tags "Division=petv2-Platform" \
               "Environment=Prod" \
               "Offer=petv2-DevWorkstation-Service" \
               "Team=Engineering" \
               "Solution=$projectName" \
               "BusinessUnit=e-Commerce"
               
    # Check the exit status of the last command and echo a message accordingly
    if [ "$?" -eq 0 ]; then
        echo "DevCenter admin pool created successfully."
    else
        echo "Error: Failed to create DevCenter admin pool. Please check the parameters and try again." >&2
        exit 1
    fi
}

# Main script execution
createDevBoxPools() {
    validateArguments "$@"
    assignArguments "$@"
    createDevCenterAdminPool
}

createDevBoxPools "$@"