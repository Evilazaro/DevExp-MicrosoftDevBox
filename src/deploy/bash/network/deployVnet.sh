#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -o nounset
# Prevent errors in a pipeline from being masked
set -o pipefail

# Constants
BRANCH="main"
TEMPLATE_FILE_URI="https://raw.githubusercontent.com/Evilazaro/MicrosoftDevBox/$BRANCH/src/deploy/ARMTemplates/network/vNet/vNetTemplate.json"

# Function to display usage information
usage() {
    echo "Usage: $0 <networkResourceGroupName> <location> <vnetName> <subnetName>"
    exit 1
}

# Function to ensure the correct number of arguments are passed
ensureArgumentsPassed() {
    if [ "$#" -ne 4 ]; then
        echo "Error: Invalid number of arguments."
        usage
    fi
}

# Function to create a virtual network and subnet
createVirtualNetworkAndSubnet() {
    local networkResourceGroupName="$1"
    local location="$2"
    local vnetName="$3"
    local subnetName="$4"
    local vnetAddressPrefix="10.0.0.0/16"
    local subnetAddressPrefix="10.0.0.0/24"

    echo "Starting the creation of Virtual Network and Subnet..."
    echo "Creating Virtual Network: $vnetName in Resource Group: $networkResourceGroupName with address prefix: $vnetAddressPrefix..."

    if ! az deployment group create \
        --name "$vnetName" \
        --resource-group "$networkResourceGroupName" \
        --template-uri $TEMPLATE_FILE_URI \
        --parameters vNetName="$vnetName" \
                     location="$location"; then
        echo "Error: Failed to create Virtual Network and Subnet."
        exit 1
    fi

    echo "Virtual Network $vnetName and Subnet $subnetName have been created successfully in Resource Group $networkResourceGroupName."
}

# Main script execution
deployVnet() {
    ensureArgumentsPassed "$@"
    createVirtualNetworkAndSubnet "$@"
}

# Execute the main function with all script arguments
deployVnet "$@"